; sectors.asm

DRAW_TERRAIN proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; verificar se eh fase 3
    mov al, [current_sector]
    cmp al, 4  
    je DRAW_PHASE3_TERRAIN
    
    ; planet
    mov bx, 0
    mov cx, 180
    mov dl, 6      
    call FILL_REC  
    
    ; montanhas
    mov bx, 30
    mov cx, 156
    mov si, offset mountain
    mov al, PLANET_DIM
    call DRAW_SPRITE
    
    mov bx, 90
    mov cx, 164
    mov si, offset mountain
    call DRAW_SPRITE
    
    mov bx, 150
    mov cx, 172
    mov si, offset mountain
    call DRAW_SPRITE
    
    ; repetir para mais posicoes
    mov bx, 210
    mov cx, 156
    mov si, offset mountain
    call DRAW_SPRITE
    
    mov bx, 270
    mov cx, 164
    mov si, offset mountain
    call DRAW_SPRITE
    
    jmp TERRAIN_DONE
    
DRAW_PHASE3_TERRAIN:
    call DRAW_BRICK_PLATFORMS
    
TERRAIN_DONE:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DRAW_TERRAIN endp

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
    mov [obstacle_str_offset], offset meteor
    mov [current_timer], SECTOR_TIME
    mov [wrap_screen], 0
    mov [sector_bonus_points], 10
    mov [str_int_color], 02h

    ; status bar
    call SETUP_STATUS_BAR
    
    ; desenhar terreno
    call DRAW_TERRAIN

    ; jet
    mov [score_points], 0
    mov [direction], IDLE
    mov [speed_low], 2000
    mov [pos_x_high], 20
    mov [pos_y_high], 100 ; middle screen_height
    mov bx, [pos_x_high]
    mov cx, [pos_y_high]
    mov al, ENTITY_DIM
    mov si, offset jet
    call DRAW_SPRITE

    ; planet
    mov si, 2 ; offset
    mov [pos_x_high + si], 0
    mov [pos_y_high + si], 180
    mov cx, [pos_y_high + si]
    mov bl, 06h   ; color
    call FILL_REC
    mov [speed_low + si], 0

    ; meteor
    mov si, 4 ; offset
    mov [speed_low + si], 1200
    mov [pos_x_high + si], SCREEN_WIDTH - ENTITY_WIDTH ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; meteor
    add si, 2 ; offset
    mov [speed_low + si], 1200
    mov [pos_x_high + si], SCREEN_WIDTH - 50 ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; meteor
    add si, 2 ; offset
    mov [speed_low + si], 1200
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

    mov [obstacle_str_offset], offset alien
    mov [current_timer], SECTOR_TIME
    mov [sector_bonus_points], 15
    mov [str_int_color], 02h

    ; status bar
    call SETUP_STATUS_BAR
    
    ; desenhar terreno
    call DRAW_TERRAIN

    ; jet
    mov [direction], IDLE
    mov [speed_low], 2000
    mov [pos_x_high], 20
    mov [pos_y_high], 100 ; middle screen_height
    mov bx, [pos_x_high]
    mov cx, [pos_y_high]
    mov al, ENTITY_DIM
    mov si, offset jet
    call DRAW_SPRITE

    ; planet
    mov si, 2 ; offset
    mov [pos_x_high + si], 0
    mov [pos_y_high + si], 180
    mov cx, [pos_y_high + si]
    mov bl, 06h   ; color
    call FILL_REC
    mov [speed_low + si], 0

    ; meteor
    mov si, 4 ; offset
    mov [speed_low + si], 1200
    mov [pos_x_high + si], SCREEN_WIDTH - ENTITY_WIDTH ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; meteor
    add si, 2 ; offset
    mov [speed_low + si], 1200
    mov [pos_x_high + si], SCREEN_WIDTH - 50 ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; meteor
    add si, 2 ; offset
    mov [speed_low + si], 1200
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

    mov [obstacle_str_offset], offset meteor
    mov [current_timer], SECTOR_TIME
    mov [sector_bonus_points], 20
    mov [str_int_color], 02h

    ; status bar
    call SETUP_STATUS_BAR
    
    ; desenhar cenario final de tijolos
    call DRAW_BRICK_PLATFORMS

    ; jet
    mov [direction], IDLE
    mov [speed_low], 2000
    mov [pos_x_high], 20
    mov [pos_y_high], 100 ; middle screen_height
    mov bx, [pos_x_high]
    mov cx, [pos_y_high]
    mov al, ENTITY_DIM
    mov si, offset jet
    call DRAW_SPRITE

    ; planet
    mov si, 2 ; offset
    mov [pos_x_high + si], 0
    mov [pos_y_high + si], 180
    ;mov cx, [pos_y_high + si]
    ;mov bl, 06h   ; color
    ;call FILL_REC
    mov [speed_low + si], 0

    ; meteor
    mov si, 4 ; offset
    mov [speed_low + si], 1200
    mov [pos_x_high + si], SCREEN_WIDTH - ENTITY_WIDTH ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; meteor
    add si, 2 ; offset
    mov [speed_low + si], 1200
    mov [pos_x_high + si], SCREEN_WIDTH - 50 ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    ; meteor
    add si, 2 ; offset
    mov [speed_low + si], 1200
    mov [pos_x_high + si], SCREEN_WIDTH - 100 ; y
    mov [pos_y_high + si], 76 ; y
    mov [direction + si], LEFT    ; move left

    pop cx
    pop bx
    pop si
    pop bp
    pop ax
    ret
    ret
START_SECTOR_THREE endp

DRAW_BRICK_COLUMN proc
    push ax
    push bx
    push cx
    push dx
    push si
    
    push ax  ; salvar altura
    
    ; Desenhar topo
    mov si, offset brick_top
    mov al, PLANET_DIM
    call DRAW_SPRITE
    
    ; Desenhar blocos abaixo
    mov si, offset brick
    pop dx   
    dec dx   
    
DRAW_COLUMN_LOOP:
    cmp dx, 0
    jle COLUMN_DONE
    
    ; Mover para baixo
    add cx, BLOCK_HEIGHT
    
    ; Verificar se ultrapassou o solo (Y=180)
    cmp cx, 180
    jge COLUMN_DONE  
    
    call DRAW_SPRITE
    dec dx
    jmp DRAW_COLUMN_LOOP
    
COLUMN_DONE:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
DRAW_BRICK_COLUMN endp

DRAW_BRICK_PLATFORMS proc
    push ax
    push bx
    push cx
    
    ; Plataforma 1: 2 colunas
    ;mov bx, 0
    ;mov cx, 100    ; Topo em Y=100 (100px do topo)
    ;mov al, 5      ; 5 blocos de altura (at? Y=180)
    ;call DRAW_BRICK_COLUMN
    ;add bx, BLOCK_WIDTH
    ;mov cx, 100    ; Resetar Y para nova coluna
    ;call DRAW_BRICK_COLUMN
    
    mov cx, 80     ; Y=80
    mov al, 3      ; 6 blocos
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 80
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 80
    call DRAW_BRICK_COLUMN
    
    ; Plataforma 2: 3 colunas
    ;mov cx, 100
    ;call DRAW_BRICK_COLUMN
    ;add bx, BLOCK_WIDTH
    ;mov cx, 100
    ;call DRAW_BRICK_COLUMN
    ;add bx, BLOCK_WIDTH
    ;mov cx, 100
    ;call DRAW_BRICK_COLUMN
    
    mov cx, 80     ; Y=80
    mov al, 2      ; 6 blocos
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 80
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 80
    call DRAW_BRICK_COLUMN
    
    
    ; Plataforma 3: 4 colunas
    ;mov cx, 100
    ;call DRAW_BRICK_COLUMN
    ;add bx, BLOCK_WIDTH
    ;mov cx, 100
    ;call DRAW_BRICK_COLUMN
    ;add bx, BLOCK_WIDTH
    ;mov cx, 100
    ;call DRAW_BRICK_COLUMN
    ;add bx, BLOCK_WIDTH
    ;mov cx, 100
    ;call DRAW_BRICK_COLUMN
    
    mov cx, 120    ; Y=120
    mov al, 4      ; 4 blocos
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 120
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 120
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 120
    call DRAW_BRICK_COLUMN
    
    ; Plataforma 4: 2 colunas
    ;mov cx, 100
    ;call DRAW_BRICK_COLUMN
    ;add bx, BLOCK_WIDTH
    ;mov cx, 100
    ;call DRAW_BRICK_COLUMN
    
    mov bx, 0
    mov cx, 50     ; Y=50
    mov al, 8      ; 8 blocos
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 50
    call DRAW_BRICK_COLUMN
    
    ; Plataforma 5: 3 colunas
    mov cx, 100
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 100
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 100
    call DRAW_BRICK_COLUMN
    
    ; Plataforma 6: 3 colunas
    mov cx, 80     ; Y=80
    mov al, 10      ; 6 blocos
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 80
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 80
    call DRAW_BRICK_COLUMN
    
    ; Plataforma 7: 3 colunas
    mov cx, 80     ; Y=80
    mov al, 8      ; 6 blocos
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 80
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 80
    call DRAW_BRICK_COLUMN
    
    ; Plataforma 8: 4 colunas
    mov cx, 120    ; Y=120
    mov al, 5      ; 4 blocos
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 120
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 120
    call DRAW_BRICK_COLUMN
    add bx, BLOCK_WIDTH
    mov cx, 120
    call DRAW_BRICK_COLUMN
    
    pop cx
    pop bx
    pop ax
    ret
DRAW_BRICK_PLATFORMS endp
