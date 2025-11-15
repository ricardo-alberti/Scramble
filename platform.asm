; platform.asm
; - User Input functions
; - Video Output
; - Sound Output
; - Custom interruptions

; resets variables
; RESET_GAME

; fill screen with black 
CLEAR_SCREEN proc
    push ax
    push cx
    push di
    
    mov ax, VIDEO_SEG ; ES = 0A000h (video memory)
    mov es, ax
    xor di, di        ; start at beginning of video memory
    xor al, al        ; color 0 (black)
    mov cx, 64000     ; 320 * 200 = 64,000 pixels
    rep stosb
    
    pop di
    pop cx
    pop ax
    ret
endp

; UPDATE_POS
; Input:
;   SI = index (of object)
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
    test bl, RIGHT
    jz CHECK_LEFT
    add ax, [speed_low]
    adc dx, [speed_high]
    cmp dx, SCREEN_WIDTH
    jb STORE_X               ; if < width, keep it
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

    ; Move up
    test bl, UP
    jz CHECK_DOWN
    sub ax, [speed_low]
    sbb dx, [speed_high]
    js WRAP_BOTTOM
    jmp STORE_Y
WRAP_BOTTOM:
    mov dx, SCREEN_HEIGHT
    jmp STORE_Y

CHECK_DOWN:
    test bl, DOWN
    jz STORE_Y
    add ax, [speed_low]
    adc dx, [speed_high]
    cmp dx, SCREEN_HEIGHT
    jb STORE_Y
    xor dx, dx               ; wrap to 0

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
; bx = x
; cx = y 
; Output:
; di = address in video segment
CALC_ADDRESS proc 
    push ax
    push dx

    xor ax, ax    
    mov ax, cx
    mov dx, 320
    mul dx        ; AX = row*320
    add ax, bx
    mov di, ax

    pop dx
    pop ax
    ret
CALC_ADDRESS endp

; Input:
; si = sprite source index
; bx = x
; cx = y
DRAW_SPRITE proc
    push ax
    push bx
    push cx
    push dx
    push di
    push si

    mov ax, VIDEO_SEG
    mov es, ax

    call CALC_ADDRESS ; di = address

    mov cx, SPRITE_HEIGHT   ; outer loop: rows
DRAW_ROW:
    mov dx, SPRITE_WIDTH    ; inner loop: columns
DRAW_PIXEL:
    movsb                   ; AL = sprite byte, SI++
    jmp NEXT_PIXEL
NEXT_PIXEL:
    dec dx
    jnz DRAW_PIXEL

    add di, 320 - SPRITE_WIDTH  ; move DI to next screen row
    loop DRAW_ROW

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DRAW_SPRITE endp

; video mode 320 × 200 (video mode = 13h)
; 1 pixel = 1 byte
; memory used by the video screen = 320 × 200 = 64.000 bytes.
INIT_WINDOW proc
    push ax
    mov ah, 00H
    mov al, 13H
    int 10H
    pop aX
    ret
INIT_WINDOW endp

; Input:
; BL = color
; DH = row (text lines)
; DL = column (text lines)
; BP = string address
PRINT_STR proc
    push es
    push ax
    push bx
    push dx
    push si
    push cx
    
    mov ax, ds
    mov es, ax          ; ES = DS (text source in same segment)
    mov bh, 0           ; video page 0
    mov si, bp          ; SI -> string

    call GET_STR_SIZE   ; returns CX = string length

    mov ah, 13h         ; write string
    mov al, 1           ; update cursor, write mode
    int 10h

    pop cx
    pop si
    pop dx
    pop bx
    pop ax
    pop es
    ret
PRINT_STR endp

; Input:  SI = string address
; Output: CX = string length (up to '$')
GET_STR_SIZE proc
    push ax
    xor cx, cx
count_loop:
    mov al, [si]
    cmp al, '$'
    je done
    inc cx
    inc si
    jmp count_loop
done:
    pop ax
    ret
GET_STR_SIZE endp
