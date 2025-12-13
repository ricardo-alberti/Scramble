; sectors.asm

; initialize sectors
START_SECTOR_ONE proc
    push ax
    push bp
    push si
    push bx
    push cx

    mov bp, offset sector1
    call PRINT_PHASE

    
    mov [sector_additional_height], 0
    mov [active_count], 15
    mov [lives], 3
    mov [obstacle_str_offset], offset alien
    mov [current_timer], SECTOR_TIME
    mov [wrap_screen], 0
    mov [sector_bonus_points], 10
    mov [str_int_color], 02h

    ; status bar
    call SETUP_STATUS_BAR
    
    ; desenhar terreno
    call SET_TERRAIN

    ; jet
    mov [score_points], 0
    mov [direction], IDLE
    mov [speed_low], 30000
    mov [pos_x_high], 20
    mov [pos_y_high], 100 ; middle screen_height
    mov bx, [pos_x_high]
    mov cx, [pos_y_high]
    mov al, ENTITY_DIM
    mov si, offset jet
    call DRAW_SPRITE

    ; alien 1
    mov si, OBSTACLE_OFFSET ; offset
    mov [speed_low + si], 25000
    mov [pos_x_high + si], SCREEN_WIDTH - ENTITY_WIDTH ; y
    mov [pos_y_high + si], SCREEN_TOP_LIMIT ; y
    mov [direction + si], LEFT    ; move left

    ; alien 2
    add si, 2 ; offset
    mov [speed_low + si], 25000
    mov [pos_x_high + si], SCREEN_WIDTH - 60 ; y
    mov [pos_y_high + si], SCREEN_TOP_LIMIT + ENTITY_HEIGHT ; y
    mov [direction + si], LEFT    ; move left

    ; alien 3
    add si, 2 ; offset
    mov [speed_low + si], 25000
    mov [pos_x_high + si], SCREEN_WIDTH - 120 ; y
    mov [pos_y_high + si], SCREEN_TOP_LIMIT + ENTITY_HEIGHT*2 ; y
    mov [direction + si], LEFT    ; move left

    pop cx
    pop bx
    pop si
    pop bp
    pop ax
    ret
START_SECTOR_ONE endp

START_SECTOR_TWO proc
    push ax
    push bp
    push si
    push bx
    push cx

    mov bp, offset sector2
    call PRINT_PHASE

    mov [obstacle_str_offset], offset meteor
    mov [current_timer], SECTOR_TIME
    mov [sector_bonus_points], 15
    mov [str_int_color], 02h

    ; status bar
    call SETUP_STATUS_BAR
    
    ; desenhar terreno
    call SET_TERRAIN

    ; jet
    mov [direction], IDLE
    add [speed_low], SPEED_ADD_SECTOR
    mov [pos_x_high], 20
    mov [pos_y_high], 100 ; middle screen_height
    mov bx, [pos_x_high]
    mov cx, [pos_y_high]
    mov al, ENTITY_DIM
    mov si, offset jet
    call DRAW_SPRITE

    ; meteor
    mov si, OBSTACLE_OFFSET ; offset
    add [speed_low + si], SPEED_ADD_SECTOR
    mov [pos_x_high + si], SCREEN_WIDTH - ENTITY_WIDTH ; y
    mov [pos_y_high + si], SCREEN_TOP_LIMIT ; y
    mov [direction + si], LEFT    ; move left

    ; meteor
    add si, 2 ; offset
    add [speed_low + si], SPEED_ADD_SECTOR
    mov [pos_x_high + si], SCREEN_WIDTH - 60 ; y
    mov [pos_y_high + si], SCREEN_TOP_LIMIT + ENTITY_HEIGHT + 5; y
    mov [direction + si], LEFT    ; move left

    ; meteor
    add si, 2 ; offset
    add [speed_low + si], SPEED_ADD_SECTOR
    mov [pos_x_high + si], SCREEN_WIDTH - 120 ; y
    mov [pos_y_high + si], SCREEN_TOP_LIMIT + ENTITY_HEIGHT*2 + 5 ; y
    mov [direction + si], LEFT    ; move left

    pop cx
    pop bx
    pop si
    pop bp
    pop ax
    ret
START_SECTOR_TWO endp

START_SECTOR_THREE proc
    push ax
    push bp
    push si
    push bx
    push cx

    mov bp, offset sector3
    call PRINT_PHASE

    mov [obstacle_str_offset], offset alien
    mov [current_timer], SECTOR_TIME
    mov [sector_bonus_points], 20
    mov [str_int_color], 02h

    ; status bar
    call SETUP_STATUS_BAR
    
    ; desenhar terreno
    call SET_TERRAIN

    ; jet
    mov [direction], IDLE
    add [speed_low], SPEED_ADD_SECTOR
    mov [pos_x_high], 20
    mov [pos_y_high], 100 ; middle screen_height
    mov bx, [pos_x_high]
    mov cx, [pos_y_high]
    mov al, ENTITY_DIM
    mov si, offset jet
    call DRAW_SPRITE

    ; alien 1
    mov si, OBSTACLE_OFFSET ; offset
    add [speed_low + si], SPEED_ADD_SECTOR
    mov [pos_x_high + si], SCREEN_WIDTH - ENTITY_WIDTH ; y
    mov [pos_y_high + si], SCREEN_TOP_LIMIT ; y
    mov [direction + si], LEFT    ; move left

    ; alien 2
    add si, 2 ; offset
    add [speed_low + si], SPEED_ADD_SECTOR
    mov [pos_x_high + si], SCREEN_WIDTH - 60 ; y
    mov [pos_y_high + si], SCREEN_TOP_LIMIT + ENTITY_HEIGHT ; y
    mov [direction + si], LEFT    ; move left

    ; alien 3
    add si, 2 ; offset
    add [speed_low + si], SPEED_ADD_SECTOR
    mov [pos_x_high + si], SCREEN_WIDTH - 120 ; y
    mov [pos_y_high + si], SCREEN_TOP_LIMIT + ENTITY_HEIGHT*2 ; y
    mov [direction + si], LEFT    ; move left

    pop cx
    pop bx
    pop si
    pop bp
    pop ax
    ret
    ret
START_SECTOR_THREE endp


; atribui posições para os blocos (terreno)
; incrementa active_count com base no incremento de altura por setor
SET_TERRAIN proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    mov si, PLANET_OFFSET
    add [sector_additional_height], 1
    add [active_count], 13

    mov cx, TERRAIN_LENGTH
    mov ax, - BLOCK_WIDTH  ; x
SET_COLUMN:
    push cx

    add ax, BLOCK_WIDTH   ; x
    mov bx, SCREEN_HEIGHT ; y

    mov di, cx
    dec di
    mov cl, [terrain_heights + di]
    add cl, [sector_additional_height]
    xor ch, ch
SET_COLUMN_BLOCKS:
    push ax
    mov al, [current_sector]
    xor ah, ah
    cmp ax, LAST_SECTOR
    je SET_BRICK

SET_MOUNTAIN:
    mov di, MOUNTAIN_TYPE
    jmp SET_BLOCK

SET_BRICK:
    mov di, BRICK_TYPE

SET_BLOCK:
    ; montanhas
    pop ax
    sub bx, BLOCK_HEIGHT

    push di
    mov di, [block_types + di]
    mov [block_type + si - PLANET_OFFSET], di
    pop di

    mov [pos_x_high + si], ax
    mov [pos_y_high + si], bx
    mov [speed_high + si], 0
    mov [speed_low + si], SPEED_PLANET
    mov [direction + si], LEFT
    add si, 2
    dec cl
    jnz SET_COLUMN_BLOCKS

    mov di, [block_types + di + 2]
    mov [block_type + si - PLANET_OFFSET - 2], di
    pop cx
    loop SET_COLUMN

TERRAIN_DONE:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
SET_TERRAIN endp

