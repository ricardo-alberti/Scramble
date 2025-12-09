; AABB Collision Detection or "Axis-Aligned Bounding Box" Collision detection
; reference: https://tutorialedge.net/gamedev/aabb-collision-detection-tutorial/

; Resolve colisoes
; Input:
; si -> offset do elemento
RESOLVE_COLLISION proc
    push ax
    push bx
    push dx
    push cx
    push si

    cmp si, JET_OFFSET  
    je RES_DETECTION   ; se objeto for player nao executa

; checar se objeto colide com player:
cmp si, PLANET_OFFSET
jae SET_PLANET_DIM

SET_OBSTACLE_DIM:
    mov di, ENTITY_DIM
    jmp SHORT SET_DIM

SET_PLANET_DIM:
    mov di, PLANET_DIM
    jmp RES_DETECTION  ; por enquanto ignorar colisao com terreno

SET_DIM:
    mov dl, [sprites_dim + ENTITY_DIM]     ; jet player dimension width
    mov dh, [sprites_dim + ENTITY_DIM + 1] ; jet player dimension height
    mov cl, [sprites_dim + di]             ; obstacle dimension width
    mov ch, [sprites_dim + di + 1]         ; obstacle dimension height

; player1.x >= player2.x + player2.width
; jet
mov ax, [pos_x_high]
; obstaculo
push cx
mov bx, [pos_x_high + si]
xor ch, ch
add bx, cx
pop cx
cmp ax, bx
jae RES_DETECTION

; player1.x + player1.width <= player2.x
; jet
mov ax, [pos_x_high]
push dx
xor dh, dh
add ax, dx
pop dx
; obstacle
mov bx, [pos_x_high + si]
cmp ax, bx
jbe RES_DETECTION

; player1.y >= player2.y + player2.height
; jet
mov ax, [pos_y_high]
; obstaculo
mov bx, [pos_y_high + si]
add bl, ch
cmp ax, bx
jae RES_DETECTION

; player1.y + player1.height <= player2.y
; jet
mov ax, [pos_y_high]
add al, dh
; obstaculo
mov bx, [pos_y_high + si]
cmp ax, bx
jbe RES_DETECTION

COLLISION:
    call SPAWN_RIGHT
    call UPDATE_LIVES    

RES_DETECTION:
    pop si
    pop cx
    pop dx
    pop bx
    pop ax
    ret
RESOLVE_COLLISION endp

CHECK_BULLET_COLLISION proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov si, [obstacle_str_offset]
    cmp si, offset meteor
    jne CONTINUE_CHECK
    jmp FINISH_CHECK

CONTINUE_CHECK:
    xor si, si  ; indice da bala
BULLET_LOOP:
    cmp [bullet_active + si], 0
    je NEXT_BULLET_CHECK
    ; posicao da bala
    mov ax, [bullet_x_high + si]
    mov bx, [bullet_y + si]
    ; verificar colisao com cada alien (offsets 4, 6, 8)
    mov di, OBSTACLE_OFFSET
    mov cx, 3  ; 3 aliens
    
ALIEN_LOOP:
    ; verificar sobreposicao 
    ; bala.x >= alien.x && bala.x <= alien.x + largura
    mov dx, [pos_x_high + di]
    cmp ax, dx
    jb NO_COLLISION_WITH_THIS
    
    add dx, ENTITY_WIDTH
    cmp ax, dx
    ja NO_COLLISION_WITH_THIS
    
    ; bala.y >= alien.y && bala.y <= alien.y + altura
    mov dx, [pos_y_high + di]
    cmp bx, dx
    jb NO_COLLISION_WITH_THIS
    
    add dx, ENTITY_HEIGHT
    cmp bx, dx
    ja NO_COLLISION_WITH_THIS
    
    ; destruir alien
    push si
    push di
    mov bx, [bullet_x_high + si]
    mov cx, [bullet_y + si]
    mov si, offset empty_sprite
    mov al, BULLET_Dim
    call DRAW_SPRITE
    ; limpar sprite do alien
    mov bx, [pos_x_high + di]
    mov cx, [pos_y_high + di]
    mov al, ENTITY_DIM
    call DRAW_SPRITE
    ; reposicionar alien
    mov si, di  ; indice do alien
    call SPAWN_RIGHT
    pop di
    pop si
    
    ; desativar bala
    mov [bullet_active + si], 0
    
    ; adicionar pontos (100 fase 2, 150 fase 3)
    mov al, [current_sector]
    cmp al, 4  ; fase 3
    je FASE3_POINTS
    
    ; fase 2 - 100 pontos
    mov al, 100
    jmp ADD_POINTS
    
FASE3_POINTS:
    ; fase 3 - 150 pontos
    mov al, 150
    
ADD_POINTS:
    call UPDATE_SCORE
    jmp NEXT_BULLET_CHECK
    
NO_COLLISION_WITH_THIS:
    add di, 2  ; proximo alien
    loop ALIEN_LOOP
    
NEXT_BULLET_CHECK:
    add si, 2
    cmp si, MAX_BULLETS
    jl BULLET_LOOP
    
FINISH_CHECK:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
CHECK_BULLET_COLLISION endp
