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

    mov [lives], 3
    mov [active_count], 5
    mov [obstacle_str_offset], offset meteor
    mov [current_timer], SECTOR_TIME
    mov [wrap_screen], 0
    mov [sector_bonus_points], 15
    mov [str_int_color], 02h

    ; status bar
    call SETUP_STATUS_BAR

    ; jet
    mov [score_points], 0
    mov [direction], IDLE
    mov [speed_low], 20000
    mov [pos_x_high], 20
    mov [pos_y_high], 100 ; middle screen_height
    mov bx, [pos_x_high]
    mov cl, [pos_y_high]
    mov si, offset jet
    call DRAW_SPRITE

    ; planet
    mov si, 2 ; offset

    mov [pos_x_high + si], 0
    mov [pos_y_high + si], 180

    mov cl, [pos_y_high + si]
    mov bl, 06h   ; color
    call FILL_REC

    mov [pos_y_high + si], 167
    mov [speed_low + si], 10000
    mov [direction + si], LEFT    ; move left
    mov bx, [pos_x_high + si]
    mov cl, [pos_y_high + si]
    mov si, offset planet
    call DRAW_SPRITE

    ; meteor
    mov si, 4 ; offset
    mov [speed_low + si], 12000
    mov [pos_x_high + si], SCREEN_WIDTH - ENTITY_WIDTH ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; meteor
    add si, 2 ; offset
    mov [speed_low + si], 12000
    mov [pos_x_high + si], SCREEN_WIDTH - 50 ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; meteor
    add si, 2 ; offset
    mov [speed_low + si], 12000
    mov [pos_x_high + si], SCREEN_WIDTH - 100 ; y
    mov [pos_y_high + si], 76 ; y
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

    mov [active_count], 5
    mov [obstacle_str_offset], offset alien
    mov [current_timer], SECTOR_TIME
    mov [wrap_screen], 0
    mov [sector_bonus_points], 20
    mov [str_int_color], 02h

    ; status bar
    call SETUP_STATUS_BAR

    ; jet
    mov [direction], IDLE
    mov [speed_low], 20000
    mov [pos_x_high], 20
    mov [pos_y_high], 100 ; middle screen_height
    mov bx, [pos_x_high]
    mov cl, [pos_y_high]
    mov si, offset jet
    call DRAW_SPRITE

    ; planet
    mov si, 2 ; offset

    mov [pos_x_high + si], 0
    mov [pos_y_high + si], 180

    mov cl, [pos_y_high + si]
    mov bl, 06h   ; color
    call FILL_REC

    mov [pos_y_high + si], 167
    mov [direction + si], LEFT    ; move left
    mov bx, [pos_x_high + si]
    mov cl, [pos_y_high + si]
    mov si, offset planet
    call DRAW_SPRITE

    ; meteor
    mov si, 4 ; offset
    mov [pos_x_high + si], SCREEN_WIDTH - ENTITY_WIDTH ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; meteor
    add si, 2 ; offset
    mov [pos_x_high + si], SCREEN_WIDTH - 50 ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; meteor
    add si, 2 ; offset
    mov [pos_x_high + si], SCREEN_WIDTH - 100 ; y
    mov [pos_y_high + si], 76 ; y
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

    mov [active_count], 5
    mov [obstacle_str_offset], offset meteor
    mov [current_timer], SECTOR_TIME
    mov [wrap_screen], 0
    mov [sector_bonus_points], 10
    mov [str_int_color], 02h

    ; status bar
    call SETUP_STATUS_BAR

    ; jet
    mov [direction], IDLE
    mov [speed_low], 20000
    mov [pos_x_high], 20
    mov [pos_y_high], 100 ; middle screen_height
    mov bx, [pos_x_high]
    mov cl, [pos_y_high]
    mov si, offset jet
    call DRAW_SPRITE

    ; planet
    mov si, 2 ; offset

    mov [pos_x_high + si], 0
    mov [pos_y_high + si], 180

    mov cl, [pos_y_high + si]
    mov bl, 06h   ; color
    call FILL_REC

    mov [pos_y_high + si], 167
    mov [speed_low + si], 1000
    mov [direction + si], LEFT    ; move left
    mov bx, [pos_x_high + si]
    mov cl, [pos_y_high + si]
    mov si, offset planet
    call DRAW_SPRITE

    ; meteor
    mov si, 4 ; offset
    mov [pos_x_high + si], SCREEN_WIDTH - ENTITY_WIDTH ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; meteor
    add si, 2 ; offset
    mov [pos_x_high + si], SCREEN_WIDTH - 50 ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; meteor
    add si, 2 ; offset
    mov [pos_x_high + si], SCREEN_WIDTH - 100 ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    pop cx
    pop bx
    pop si
    pop bp
    pop ax
    ret
START_SECTOR_THREE endp
