; platform.asm
; - User Input functions
; - Video Output
; - Sound Output
; - Custom interruptions
; - File I/O

; functions implemented:
; CLEAR_SCREEN proc
; PRINT_STR proc
; CALCULA_TAM_STRING proc
; INIT_WINDOW proc


; scroll window with video memory directly
CLEAR_SCREEN proc
    push ax
    push cx
    push di
    
    mov ax, offset VIDEO_SEG
    mov es, ax
    xor di, di
    xor al, al
    mov cx, 64000
    rep stosb
    
    pop di
    pop cx
    pop ax
    ret
endp

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
; DH = row
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

;------------------------------------

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

