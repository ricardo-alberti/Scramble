; platform.asm

; INT 1A,2 - Read Time From Real Time Clock
; Output:
; CF = 0 if successful
;    = 1 if error, RTC not operating
; CH = hours in BCD
; CL = minutes in BCD
; DH = seconds in BCD
; DL = 1 if daylight savings time option
READ_RTC proc
    push ax
    push cx
    mov ah, 02h         ; only return dx for now
    int 1Ah
    pop ax
    pop cx
    ret
READ_RTC endp

; Input:
; BX = limit
; Ouput:
; AX = random value
GET_RANDOM_VALUE proc
    push BX
    push CX
    push DX
    
    ; retrieves DOS maintained clock time
	; CH = hour (0-23)
	; CL = minutes (0-59)
	; DH = seconds (0-59)
	; DL = hundredths (0-99)
    mov ah, 2Ch 
    int 21h 
    
    mov AX, DX
    xor DX, DX
    
    div BX
    
    mov AX, DX
    
    pop DX
    pop CX
    pop BX
    ret
endp

; Input:
; dh = line
; dl = column
; bl = color
; bp = str offset
DRAW_BUTTON proc
    push dx

    ; draw rec
    sub dh, 1  ; line 
    sub dl, 2  ; column 
    call DRAW_REC

    ; write str
    pop dx
    call PRINT_STR

    ret
DRAW_BUTTON endp 

; Input:
; BL = color
; DH = line
; DL = column
DRAW_REC PROC
    push ax
    push cx
    push dx
    
    ; ┌
    xor BH, BH
    call SET_POS_CURSOR
    mov AL, 218     
    mov CX, 1
    mov AH, 0AH
    int 10h
    
    ; ──────── 
    inc DL
    call SET_POS_CURSOR
    mov AL, 196
    mov CX, 7
    mov AH, 0AH
    int 10h
    
    ; ┐
    add DL, CL
    call SET_POS_CURSOR
    mov AL, 191 
    mov CX, 1
    mov AH, 0AH
    int 10h
    
    ; │ (right)
    inc DH
    call SET_POS_CURSOR
    mov AL, 179 
    mov CX, 1
    mov AH, 0AH
    int 10h
    
    ; ┘
    inc DH
    call SET_POS_CURSOR
    mov AL, 217
    mov CX, 1
    mov AH, 0AH
    int 10h
    
    ; ──────── (bottom)
    mov CX, 8
    sub DL, CL
    call SET_POS_CURSOR
    mov AL, 196  
    mov AH, 0AH
    int 10h

    ; └
    mov CX, 1
    mov AL, 192  
    mov AH, 0AH
    int 10h

    ; | (left)
    dec DH
    call SET_POS_CURSOR
    mov CX, 1
    mov AL, 179  
    mov AH, 0AH
    int 10h
    
    pop dx
    pop cx
    pop ax
    ret
DRAW_REC endp

; Input: 
; cx = y
; bl = color
FILL_REC proc
    push ax
    push cx
    push dx
    push di
    
    xor ax, ax    
    mov ax, cx
    mov dx, 320
    mul dx
    mov di, ax
    mov dx, 64000
    sub dx, ax

    mov ax, VIDEO_SEG ; ES = 0A000h (video memory)
    mov es, ax
    mov al, bl
    mov cx, dx ; 64,000 - cx * 320
    rep stosb
    
    pop di
    pop dx
    pop cx
    pop ax
    ret
FILL_REC endp


; sets cursor position
; Input:
; BH = page number (0 for graphics modes)
; DH = row
; DL = column
SET_POS_CURSOR proc
    push ax
    push bx
    mov bh, 0
    mov ah, 02h
    int 10h
    pop bx
    pop ax
    ret
SET_POS_CURSOR endp

; Input:
; CX = high
; DX = low
; ex.:
; CX = 1Eh
; DX = 8480h
; Delay = 2s
DELAY proc
    push ax

    mov ah, 86h
    int 15h

    pop ax
DELAY endp

; Output:
; AL = ASCII, AH = scan code
GET_INPUT proc

    mov ah, 01h
    int 16h
    jz NO_KEY     ; If no key, skip

    mov ah, 00h
    int 16h

NO_KEY:
    ret
GET_INPUT endp


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

;------------------------------------------------------------
; ESC_UINT16
; Escreve AX como número decimal na posição atual do cursor
;------------------------------------------------------------
ESC_UINT16 proc
    push ax
    push bx
    push cx
    push dx

    mov bx, 10
    xor cx, cx        ; contador de dígitos

;--- converte número empilhando dígitos ---
conv_loop:
    xor dx, dx
    div bx            ; AX / 10 → quociente em AX, resto em DX
    push dx           ; empilha o dígito
    inc cx
    test ax, ax
    jnz conv_loop

;--- imprime os dígitos desempilhando ---
print_loop:
    pop dx
    add dl, '0'       ; converte para ASCII

    mov ah, 0Eh       ; teletype BIOS
    mov al, dl
    mov bh, 0         ; página
    mov bl, 02h         ; cor branca
    int 10h

    loop print_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp
