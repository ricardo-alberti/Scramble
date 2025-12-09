; game.asm

; status HUD
INCLUDE status.asm  ; barra de status
INCLUDE sectors.asm ; inicializacao de setores
INCLUDE collide.asm ; deteccao de colisao

; atribuir dimensão de sprite em al e offset do sprite em si
; Input: 
; si = offset elemento
; Output:
; al = dimensão sprite
; si = offset sprite
SET_SPRITE proc
    cmp si, JET_OFFSET
    je SET_JET_SPRITE
    cmp si, PLANET_OFFSET
    jb SET_OBSTACLE_SPRITE

SET_PLANET_SPRITE:
    mov al, PLANET_DIM
    mov si, [block_type + si - PLANET_OFFSET]
    jmp EXIT_SET_SPRITE

SET_JET_SPRITE:
    mov al, ENTITY_DIM
    mov si, offset jet
    jmp EXIT_SET_SPRITE

SET_OBSTACLE_SPRITE:
    mov al, ENTITY_DIM
    mov si, [obstacle_str_offset]

EXIT_SET_SPRITE:
    ret
SET_SPRITE endp

DRAW_GAME proc

NEXT_SECTOR:
    mov bl, [current_sector]
    xor bh, bh
    cmp bx, 4
    jne INC_CURR_SECTOR
    jmp END_WINNER
INC_CURR_SECTOR:
    add bl, 2
    mov [current_sector], bl
    mov bx, [sectors + bx]
    call bx

; -----------------------
; UPDATE_GAME
; -----------------------
SECTOR_LOOP:
    call RESOLVE_INPUT
    call UPDATE_TIMER
    
    ; se jogador sem vidas = terminar jogo
    mov bl, [lives]
    xor bh, bh
    cmp bx, 0
    je END_GAME_OVER

    ; se timer for 0 = proximo nivel
    mov bl, [current_timer]
    xor bh, bh
    cmp bx, 0
    je NEXT_SECTOR

    ; atualizar entidades e redesenhar elas
    xor si, si
    mov cx, MAX_ELEMENTS
UPDATE_ELEMENTS:
    call UPDATE_POS        ; atualizar posicao do elemento
    call RESOLVE_COLLISION ; atualizar direcao do jet
    
    call UPDATE_BULLETS
    call CHECK_BULLET_COLLISION
    
    mov bl, [has_moved]    ; somente redesenhar entidade se ela tiver sido atualizada
    cmp bl, 0           
    je CONTINUE

    push si
    push cx
    mov bx, [pos_x_high + si]
    mov cx, [pos_y_high + si]
    call SET_SPRITE
    call DRAW_SPRITE
    pop cx
    pop si
CONTINUE:
    add si, 2
    loop UPDATE_ELEMENTS
    jmp SECTOR_LOOP
; -----------------------

END_WINNER:
    mov ax, 1
    call END_SCREEN
    jmp EXIT_UPD_GAME
END_GAME_OVER:
    mov ax, 0
    call END_SCREEN
    
EXIT_UPD_GAME:
    ret
DRAW_GAME endp

; disparar tiro
FIRE_BULLET proc
    push ax
    push bx
    push cx
    push si
    
    ; Encontrar bala inativa
    xor si, si
    mov cx, MAX_BULLETS
FIND_INACTIVE:
    cmp [bullet_active + si], 0
    je FOUND_INACTIVE
    add si, 2
    loop FIND_INACTIVE
    jmp EXIT_FIRE  ; todas balas ativas
    
FOUND_INACTIVE:
    ; Posicionar bala na frente do jato
    mov ax, [pos_x_high]   ; X do jato
    add ax, ENTITY_WIDTH   ; frente do jato
    mov [bullet_x_high + si], ax
    
    mov ax, [pos_y_high]   ; Y do jato
    add ax, ENTITY_HEIGHT/2 ; centro vertical
    mov [bullet_y + si], ax
    
    ; Ativar bala
    mov [bullet_active + si], 1
    
EXIT_FIRE:
    pop si
    pop cx
    pop bx
    pop ax
    ret
FIRE_BULLET endp

; Atualizar e desenhar balas
UPDATE_BULLETS proc
    push ax
    push bx
    push cx
    push si
    
    xor si, si
    mov cx, MAX_BULLETS
UPDATE_BULLET_LOOP:
    push cx
    cmp [bullet_active + si], 0
    je NEXT_BULLET
    
    ; mover bala para direita
    add [bullet_x_low + si], bullet_speed
    adc [bullet_x_high + si], 0
    
    ; verificar se saiu da tela
    cmp [bullet_x_high + si], SCREEN_WIDTH - BULLET_WIDTH
    jae CLEAR
    jmp DRAW_BULLET
    
DRAW_BULLET:
    ; desenhar bala
    mov bx, [bullet_x_high + si]
    mov cx, [bullet_y + si]
    
    ; usar DRAW_SPRITE com dimensoes do tiro
    push si
    mov si, offset bullet_sprite
    mov al, BULLET_DIM
    call DRAW_SPRITE
    pop si

    jmp NEXT_BULLET

CLEAR:
    mov bx, [bullet_x_high + si]
    mov cx, [bullet_y + si]
    mov al, BULLET_DIM
    mov [bullet_active + si], 0
    push si
    mov si, offset empty_sprite
    call DRAW_SPRITE
    pop si
    
NEXT_BULLET:
    add si, 2
    pop cx
    loop UPDATE_BULLET_LOOP
    
    pop si
    pop cx
    pop bx
    pop ax
    ret
UPDATE_BULLETS endp

; mapear input para troca de direcao do player
RESOLVE_INPUT proc
    push ax

    mov ax, [direction]  ; manter direcao antiga por padrao

READ_KEYS:
    ; checar se tem input no teclado
    mov ah, 01h
    int 16h
    jz RESOLVED

    ; Read key (AH=00h)
    mov ah, 00h
    int 16h               ; AL = ASCII, AH = scan code

    ; ----- direction keys -----
    cmp ah, KEY_RIGHT
    jne RES_LEFT
    or  al, RIGHT
RES_LEFT:
    cmp ah, KEY_LEFT
    jne RES_UP
    or  al, LEFT
RES_UP:
    cmp ah, KEY_UP
    jne RES_DOWN
    or  al, UP
RES_DOWN:
    cmp ah, KEY_DOWN
    jne RES_SPACE
    or  al, DOWN

    ; ----- space key -----
RES_SPACE:
    cmp ah, KEY_SPACE
    jne READ_KEYS
    call FIRE_BULLET
    mov ax, [direction]
    jmp RESOLVED

RESOLVED:
    xor ah, ah
    mov [direction], ax   ; apply movement mask
    pop ax
    ret
RESOLVE_INPUT endp

; Atualizar posição elemento si
; Input:
; SI = offset (index * 2)
; Output:
; has_moved = 1 or 0 (elementos que foram movidos sao redesenhados)
UPDATE_POS PROC
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov [has_moved], 0

    ;----------------------------------
    ; LOAD DIRECTION for this object
    ;----------------------------------
    mov bx, [direction + si]

    ;----------------------------------
    ; HORIZONTAL MOVEMENT
    ;----------------------------------
    mov ax, [pos_x_low  + si]
    mov dx, [pos_x_high + si]

CHECK_RIGHT:
    test bx, RIGHT
    jz CHECK_LEFT

    add ax, [speed_low  + si]
    adc dx, [speed_high + si]

    cmp dx, SCREEN_WIDTH - ENTITY_WIDTH
    jae block_right
    jmp STORE_X

wrap_left:
    cmp dx, SCREEN_WIDTH
    jb STORE_X
    xor dx, dx
    jmp STORE_X

block_right:
    mov cx, [wrap_screen]
    cmp cx, si
    jne wrap_left
    mov dx, SCREEN_WIDTH - ENTITY_WIDTH
    jmp STORE_X

CHECK_LEFT:
    test bx, LEFT
    jz STORE_X

    sub ax, [speed_low  + si]
    sbb dx, [speed_high + si]

    js wrap_right
    jmp STORE_X

wrap_right:
    mov cx, [wrap_screen]
    cmp cx, si
    je block_left
    mov dx, SCREEN_WIDTH
    call SPAWN_RIGHT
    jmp STORE_X

block_left:
    xor dx, dx
    jmp STORE_X

STORE_X:
    mov cx, [pos_x_high + si]
    cmp cx, dx
    je SAVE_X
    mov [has_moved], 1

SAVE_X:
    mov [pos_x_low  + si], ax
    mov [pos_x_high + si], dx

    ;----------------------------------
    ; VERTICAL MOVEMENT
    ;----------------------------------
    mov ax, [pos_y_low  + si]
    mov dx, [pos_y_high + si]

CHECK_UP:
    test bx, UP
    jz CHECK_DOWN

    sub ax, [speed_low  + si]
    sbb dx, [speed_high + si]

    cmp dx, SCREEN_TOP_LIMIT
    jae STORE_Y
    mov dx, SCREEN_TOP_LIMIT

CHECK_DOWN:
    test bx, DOWN
    jz STORE_Y

    add ax, [speed_low  + si]
    adc dx, [speed_high + si]

    cmp dx, SCREEN_HEIGHT - ENTITY_HEIGHT
    jb STORE_Y
    mov dx, SCREEN_HEIGHT - ENTITY_HEIGHT

STORE_Y:
    mov cx, [pos_y_high + si]
    cmp cx, dx
    je SAVE_Y
    mov [has_moved], 1

SAVE_Y:
    mov [pos_y_low  + si], ax
    mov [pos_y_high + si], dx

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
UPDATE_POS endp

; Escreve fase
; Input:
; bp = str offset
PRINT_PHASE proc
    push bx
    push dx

    call CLEAR_SCREEN

    mov bl, 05h ; color 
    mov dh, 12   ; line 
    mov dl, 16  ; column 
    call PRINT_STR

    mov dx, 0
    mov cx, 1EH
    call DELAY
    call CLEAR_SCREEN

    pop dx
    pop bx
    ret
PRINT_PHASE endp

; Tela de game over ou vencedor
; Input:
; ax = 1 win or 0 loss
END_SCREEN proc
    push bx
    push dx

    call CLEAR_SCREEN

    mov [str_int_color], 0Fh
    mov [current_sector], FIRST_SECTOR   ; restart from first level

    cmp ax, 1
    je SET_WINNER
SET_GAME_OVER:
    mov bl, 04h ; color 
    mov bp, offset game_over
    mov dh, 10   ; line 
    mov dl, 0  ; column 
    call PRINT_STR
    jmp EXIT_END_SCREEN
SET_WINNER:
    mov bl, 02h ; color 
    mov bp, offset winner
    mov dh, 10   ; line 
    mov dl, 0  ; column 
    call PRINT_STR

    mov bl, 0Fh ; color
    mov bp, offset score_foreground
    mov dh, 18  ; row
    mov dl, 17 ; column
    call PRINT_STR 

    mov dh, 18  ; row
    mov dl, 21 ; column
    call SET_POS_CURSOR

    mov bx, [score_points]
    add ax, bx
    mov [score_points], ax
    mov bl, 0Fh
    call ESC_UINT16

EXIT_END_SCREEN:
    mov CX, 1EH
    call DELAY

    call CLEAR_SCREEN
    mov [menu_active], 1

    pop dx
    pop bx
    ret
END_SCREEN endp

; clean sprite on the left and sets random position on the right
; Input:
; si = element index
SPAWN_RIGHT proc
    push bx
    push ax
    push si


    mov al, [menu_active]  ; if on menu does not spawn
    cmp al, 1
    je END_SPAWN
    cmp si, PLANET_OFFSET    ; if planet offset returns
    jae END_SPAWN

    push bx
    push cx
    push si
    mov bx, [pos_x_high + si]
    mov cx, [pos_y_high + si]
    mov al, ENTITY_DIM
    mov si, offset empty_sprite 
    call DRAW_SPRITE

    pop si
    pop cx
    pop bx

    mov bx, 5  ; limit random number
    call GET_RANDOM_VALUE  ; ax = random value
    mov bx, ENTITY_HEIGHT + ENTITY_HEIGHT + 5   ; distance between obstacles
    mul bx
    add ax, SCREEN_TOP_LIMIT
    mov dx, SCREEN_WIDTH - ENTITY_WIDTH
    mov [pos_y_high + si], ax
    mov [pos_x_high + si], SCREEN_WIDTH - ENTITY_WIDTH

END_SPAWN:
    pop si
    pop ax
    pop bx
    ret
SPAWN_RIGHT endp
