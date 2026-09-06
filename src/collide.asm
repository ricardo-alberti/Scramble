; AABB Collision Detection or "Axis-Aligned Bounding Box" Collision detection
; reference: https://tutorialedge.net/gamedev/aabb-collision-detection-tutorial/

; Resolve colisoes
; Input:
; si -> offset do elemento
; 1 x 1 
RESOLVE_COLLISION proc 
    push ax
    push bx
    push dx
    push cx
    push si

    ; se objeto for jet
    cmp si, JET_OFFSET  
    je RES_DETECTION   ; se objeto for player nao executa

    ; se objeto for planet
    cmp si, PLANET_OFFSET
    jae SET_PLANET_DIM

    ; se objeto for planet
    cmp si, OBSTACLE_OFFSET
    jae SET_OBSTACLE_DIM

    ; se objeto for bullet
    call CHECK_BULLET_COLLISION
    jmp RES_DETECTION

SET_OBSTACLE_DIM:
    mov di, ENTITY_DIM
    jmp SHORT SET_DIM

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
    cmp si, PLANET_OFFSET
    jae RESPAWN
    jmp RES_DETECTION
RESPAWN:
    mov bx, [pos_y_high + si]
    call RESPAWN_PLAYER  ; reposicionar jet ao colidir

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
    mov si, BULLET_OFFSET  ; Start at the first bullet's global offset

BULLET_BULLET_LOOP:
    ; Check if bullet is active using local index in BX
    mov bx, si
    sub bx, BULLET_OFFSET
    cmp [bullet_active + bx], 0
    je NEXT_BULLET_CHECK

    ; Get bullet position using global offset SI
    mov ax, [pos_x_high + si]
    mov bx, [pos_y_high + si]
    
    ; Verify collision with each alien
    mov di, OBSTACLE_OFFSET
    mov cx, MAX_OBSTACLES  ; 3 aliens
    
ALIEN_LOOP:
    mov dx, [pos_x_high + di]
    cmp ax, dx
    jb NO_COLLISION_SHORT
    
    add dx, ENTITY_WIDTH
    cmp ax, dx
    ja NO_COLLISION_SHORT
    
    mov dx, [pos_y_high + di]
    cmp bx, dx
    jb NO_COLLISION_SHORT
    
    add dx, ENTITY_HEIGHT
    cmp bx, dx
    ja NO_COLLISION_SHORT
    
    ; --- COLLISION FOUND ---
    push si
    push di
    
    ; Respawn alien
    mov si, di
    call SPAWN_RIGHT
    pop di
    pop si
    
    call INACTIVATE_BULLET
    
    jmp ADD_POINTS
    
NO_COLLISION_SHORT:
    add di, 2  ; Next alien offset
    dec cx
    jnz ALIEN_LOOP
    jmp NEXT_BULLET_CHECK

ADD_POINTS:
    ; Add points based on sector
    mov al, [current_sector]
    cmp al, 4  ; phase 3
    je FASE3_POINTS
    mov al, 100
    jmp DO_UPDATE_SCORE
FASE3_POINTS:
    mov al, 150
DO_UPDATE_SCORE:
    call UPDATE_SCORE

NEXT_BULLET_CHECK:
    add si, 2  ; Next bullet global offset
    cmp si, BULLET_OFFSET + (MAX_BULLETS * 2)
    jl BULLET_BULLET_LOOP
    
FINISH_CHECK:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
CHECK_BULLET_COLLISION endp
