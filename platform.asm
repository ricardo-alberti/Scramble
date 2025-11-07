; platform.asm
; - User Input functions
; - Video Output
; - Sound Output
; - Custom interruptions
; - File I/O

;CLEAR_SPRITE proc

; fill screen with black 
CLEAR_SCREEN proc
    push ax
    push cx
    push di
    
    mov ax, VIDEO_SEG ; ES = 0A000h (video memory)
    mov es, ax
    xor di, di        ; start at beginning of video memory
    xor al, al        ; color 0 (black)
    ;mov al, 7
    mov cx, 64000     ; 320 * 200 = 64,000 pixels
    rep stosb
    
    pop di
    pop cx
    pop ax
    ret
endp

; SI = sprite data pointer
; bx = column on screen (0-320)
; cl= row on screen (0-200)
DRAW_SPRITE proc
    push ax
    push bx
    push cx
    push dx
    push di
    push si

    mov ax, VIDEO_SEG
    mov es, ax

    ; calculate DI = row*320 + column
    xor ax, ax    
    mov al, cl
    mov dx, 320
    mul dx        ; AX = row*320
    add ax, bx
    mov di, ax

    mov cx, SPRITE_HEIGHT   ; outer loop: rows
DRAW_ROW:
    mov dx, SPRITE_WIDTH    ; inner loop: columns
DRAW_PIXEL:
    lodsb                   ; AL = sprite byte, SI++
    cmp al, 0
    je SKIP_PIXEL
    stosb                   ; write pixel
    jmp NEXT_PIXEL
SKIP_PIXEL:
    inc di                   ; skip transparent pixel
NEXT_PIXEL:
    dec dx
    jnz DRAW_PIXEL

    add di, 320 - SPRITE_WIDTH  ; move DI to next screen row
    loop DRAW_ROW

    pop si
    pop di
    pop dx
    pop cx
    pop ax
    pop bx
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
; DL = column
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
