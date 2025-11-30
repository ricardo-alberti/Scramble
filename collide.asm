; AABB Collision Detection or "Axis-Aligned Bounding Box" Collision detection
; reference: https://tutorialedge.net/gamedev/aabb-collision-detection-tutorial/

; Resolve colisões
; Input:
; si -> offset do elemento
RESOLVE_COLLISION proc
    push ax
    push bx
    push dx
    push cx
    push si

    cmp si, JET_OFFSET  
    je RES_DETECTION   ; se objeto for player não executa

; checar se objeto colide com player:
cmp si, PLANET_OFFSET
je SET_PLANET_DIM

SET_OBSTACLE_DIM:
    mov di, ENTITY_DIM
    jmp SET_DIM

SET_PLANET_DIM:
    mov di, PLANET_DIM

SET_DIM:
    mov dl, [sprites_dim + ENTITY_DIM]     ; jet player dimension width
    mov dh, [sprites_dim + ENTITY_DIM + 1] ; jet player dimension height
    mov cl, [sprites_dim + di]             ; obstacle dimension width
    mov ch, [sprites_dim + di + 1]         ; obstacle dimension height

; player1.x >= player2.x + player2.width
; jet
mov ax, [pos_x_high]
; obstacle
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
mov al, [pos_y_high]
; obstacle
push cx
mov bl, [pos_y_high + si]
mov ch, cl
add bl, cl
pop cx
cmp ax, bx
jae RES_DETECTION

; player1.y + player1.height <= player2.y
; jet
mov al, [pos_y_high]
mov dh, dl
add al, dl
; obstacle
mov bl, [pos_y_high + si]
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
