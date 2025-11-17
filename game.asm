; game.asm

; status HUD
INCLUDE status.asm

DRAW_GAME proc

; -----------------------
; INITIALIZE_SECTORS
; -----------------------
SETUP_SECTOR_ONE:
    mov bp, offset sector1
    call PRINT_PHASE
    mov [speed_low], 6000
    mov [active_count], 3
    mov [obstacle_str_offset], offset meteor

    ; status bar
    call SETUP_STATUS_BAR

    ; jet
    mov [direction], RIGHT
    mov [pos_y_high], 100 ; middle screen_height

    ; planet
    mov cx, 180 ; y
    mov bl, 6   ; color
    call FILL_REC

    ; meteor
    mov si, 2 ; offset
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    add si, 2 ; offset
    mov [pos_y_high + si], 90 ; y
    mov [direction + si], LEFT    ; move left

    jmp SECTOR_LOOP

SETUP_SECTOR_TWO:
    mov bp, offset sector2
    call PRINT_PHASE

    jmp SECTOR_LOOP

SETUP_SECTOR_THREE:
    mov bp, offset sector3
    call PRINT_PHASE

    jmp SECTOR_LOOP


; -----------------------
; UPDATE_GAME
; -----------------------
SECTOR_LOOP:
    call RESOLVE_INPUT

    ;call UPDATE_STATUS_BAR

    ; update positions and draw elements
    xor si, si
    mov cx, [active_count]
UPD_ELEMENTS:

    push si
    push cx
    mov bx, [pos_x_high + si]
    mov cx, [pos_y_high + si]

    cmp si, 0
    jnz OBSTACLE_SPRITE
JET_SPRITE:
    mov si, offset jet
    jmp DRAW 
OBSTACLE_SPRITE:
    mov si, [obstacle_str_offset]
DRAW:
    call DRAW_SPRITE

    pop cx
    pop si

    call UPDATE_POS
    add si, 2
    loop UPD_ELEMENTS
     
    jmp SECTOR_LOOP

EXIT_UPD_GAME:
    ret
DRAW_GAME endp




; maps user input to game actions
RESOLVE_INPUT proc
    call GET_INPUT
    jnz CHECK_KEY_RIGHT  
    ; if no key pressed
    ;mov [shooting], 0 
    ;mov al, IDLE    
    jmp RESOLVE

CHECK_KEY_RIGHT:
    xor al, al 
    cmp ah, KEY_RIGHT
    jnz CHECK_KEY_LEFT
    or al, RIGHT
CHECK_KEY_LEFT:
    cmp ah, KEY_LEFT
    jnz CHECK_KEY_UP
    or al, LEFT
CHECK_KEY_UP:
    cmp ah, KEY_UP
    jnz CHECK_KEY_DOWN
    or al, UP
CHECK_KEY_DOWN:
    cmp ah, KEY_DOWN
    jnz CHECK_KEY_SPACE
    or al, DOWN
CHECK_KEY_SPACE:
    cmp ah, KEY_SPACE
    jnz RESOLVE
    mov [shooting], 1 ; sets to shoot

RESOLVE:
    mov [direction], al ; change jet direction
    ret
RESOLVE_INPUT endp


; Input:
; SI = index (of object)
UPDATE_POS PROC
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Each position has low and high bytes stored in arrays:
    ; pos_x_low[], pos_x_high[], pos_y_low[], pos_y_high[]

    ; LOAD direction
    mov bl, [direction + si]

    mov cx, si               ; CX = index

    ; HORIZONTAL
    ; Load X position
    mov si, offset pos_x_low
    add si, cx
    mov ax, [si]


    mov di, offset pos_x_high
    add di, cx
    mov dx, [di]

    ; Move right
CHECK_RIGHT:
    test bl, RIGHT
    jz CHECK_LEFT
    add ax, [speed_low]
    adc dx, [speed_high]
    cmp dx, SCREEN_WIDTH
    jb STORE_X               ; if < width, keep it
WRAP_LEFT:
    xor dx, dx               ; wrap to 0
    jmp STORE_X

CHECK_LEFT:
    test bl, LEFT
    jz STORE_X
    sub ax, [speed_low]
    sbb dx, [speed_high]
    js WRAP_RIGHT            ; if negative
    jmp STORE_X
WRAP_RIGHT:
    mov dx, SCREEN_WIDTH

STORE_X:
    mov [si], ax
    mov [di], dx

    ; VERTICAL
    mov si, offset pos_y_low
    add si, cx
    mov ax, [si]

    mov di, offset pos_y_high
    add di, cx
    mov dx, [di]

CHECK_UP:
    test bl, UP
    jz CHECK_DOWN
    sub ax, [speed_low]
    sbb dx, [speed_high]
    cmp dx, 0
    js BLOCK_UP
    jmp STORE_Y
BLOCK_UP:
    mov dx, 0
    jmp STORE_Y

CHECK_DOWN:
    test bl, DOWN
    jz STORE_Y
    add ax, [speed_low]
    adc dx, [speed_high]
    cmp dx, SCREEN_HEIGHT - SPRITE_HEIGHT
    jb STORE_Y
BLOCK_DOWN:
    mov dx, SCREEN_HEIGHT - SPRITE_HEIGHT               ; wrap to 0

STORE_Y:
    mov [si], ax
    mov [di], dx

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
UPDATE_POS endp

; Input:
; bp = str offset
PRINT_PHASE proc
    push bx
    push cx
    push dx

    call CLEAR_SCREEN

    mov bl, 05h ; color 
    mov dh, 12   ; line 
    mov dl, 16  ; column 
    call PRINT_STR

    mov CX, 1EH
    call DELAY
    call CLEAR_SCREEN

    pop dx
    pop cx
    pop bx
    ret
PRINT_PHASE endp
