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
    mov [speed_low], 6000
    mov [active_count], 2
    mov [obstacle_str_offset], offset meteor
    mov [current_timer], SECTOR_TIME
    mov [wrap_screen], 0

    ; status bar
    call SETUP_STATUS_BAR

    ; jet
    mov [direction], IDLE
    mov [pos_x_high], 20 ; y
    mov [pos_y_high], 100 ; middle screen_height

    ; meteor
    mov si, 2 ; offset
    mov [pos_x_high + si], SCREEN_WIDTH - SPRITE_WIDTH ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; planet
    mov cx, 180 ; y
    mov bl, 6   ; color
    call FILL_REC

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
    mov [speed_low], 8000
    mov [active_count], 2
    mov [obstacle_str_offset], offset alien
    mov [current_timer], SECTOR_TIME

    ; status bar
    call SETUP_STATUS_BAR

    ; jet
    mov [direction], IDLE
    mov [pos_x_high], 20 ; y
    mov [pos_y_high], 100 ; middle screen_height

    ; meteor
    mov si, 2 ; offset
    mov [pos_x_high + si], SCREEN_WIDTH - SPRITE_WIDTH ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; planet
    mov cx, 140 ; y
    mov bl, 09h   ; color
    call FILL_REC

    pop cx
    pop bx
    pop si
    pop bp
    pop ax
    ret
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
    mov [speed_low], 20000
    mov [active_count], 2
    mov [obstacle_str_offset], offset meteor
    mov [current_timer], SECTOR_TIME
    mov [current_sector], FIRST_SECTOR

    ; status bar
    call SETUP_STATUS_BAR

    ; jet
    mov [direction], IDLE
    mov [pos_x_high], 20 ; y
    mov [pos_y_high], 70 ; middle screen_height

    ; meteor
    mov si, 2 ; offset
    mov [pos_x_high + si], SCREEN_WIDTH - SPRITE_WIDTH ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; planet
    mov cx, 100 ; y
    mov bl, 04h   ; color
    call FILL_REC

    pop cx
    pop bx
    pop si
    pop bp
    pop ax
    ret
    ret
    ret
START_SECTOR_THREE endp
