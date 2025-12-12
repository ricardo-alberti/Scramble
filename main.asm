.model small

.stack 100H 

.data 

INCLUDE sprites.asm ; matrizes desenhos dos elementos
INCLUDE ascii.asm   ; strings desenho ascii

CR            equ 13       ; carriage return \r
LF            equ 10       ; line feed \n
VIDEO_SEG     equ 0A000h   ; endereco segmento de video

; constantes de dimensoes
SCREEN_TOP_LIMIT equ 20   ; limitar movimento y
ENTITY_WIDTH     equ 29
ENTITY_HEIGHT    equ 13
BLOCK_WIDTH      equ 24
BLOCK_HEIGHT     equ 16
LIFE_WIDTH       equ 19
LIFE_HEIGHT      equ 7
BULLET_WIDTH     equ 4
BULLET_HEIGHT    equ 4
SCREEN_WIDTH     equ 320
SCREEN_HEIGHT    equ 200
ENTITY_DIM       equ 0
PLANET_DIM       equ 2
LIFE_DIM         equ 4
BULLET_DIM       equ 6
sprites_dim db ENTITY_WIDTH, ENTITY_HEIGHT
            db BLOCK_WIDTH, BLOCK_HEIGHT
            db LIFE_WIDTH, LIFE_HEIGHT
            db BULLET_WIDTH, BULLET_HEIGHT

; constantes do jogo
SECTOR_TIME        equ 60
FIRST_SECTOR       equ 0
LAST_SECTOR        equ 4
SPEED_ADD_SECTOR   equ 17500  ; aumento de velocidade por setor

; flags de movimentacao (direcao)
DOWN          equ 1000b
UP            equ 0100b
LEFT          equ 0010b
RIGHT         equ 0001b
IDLE          equ 0000b

; teclas
KEY_DOWN      equ 50h
KEY_UP        equ 48h
KEY_LEFT      equ 4Bh
KEY_RIGHT     equ 4Dh
KEY_SPACE     equ 39h
KEY_ENTER     equ 1Ch

; offset das entidades 
INITIAL_ACTIVE_COUNT equ 15
MAX_ELEMENTS         equ INITIAL_ACTIVE_COUNT + 39   ; max de elementos = elementos ativos inicio + 39 (aumento de altura do mapa 13 por setor)
JET_OFFSET           equ 0
OBSTACLE_OFFSET      equ 2
PLANET_OFFSET        equ 8
active_count         db  INITIAL_ACTIVE_COUNT    ; elementos ativos inicialmente
; componentes das entidades   
pos_x_high dw MAX_ELEMENTS DUP(0)
pos_x_low dw MAX_ELEMENTS DUP(0)          
pos_y_high dw MAX_ELEMENTS DUP(0)         
pos_y_low dw MAX_ELEMENTS DUP(0)          
direction dw MAX_ELEMENTS DUP(IDLE)
speed_high dw MAX_ELEMENTS DUP(0)
speed_low dw MAX_ELEMENTS DUP(0)

; vetores para balas
MAX_BULLETS    equ 3
bullet_active  dw MAX_BULLETS DUP(0)
bullet_x_high  dw MAX_BULLETS DUP(0)
bullet_x_low   dw MAX_BULLETS DUP(0)
bullet_y       dw MAX_BULLETS DUP(0)
BULLET_SPEED   equ 5000

; variaveis planeta
sector_additional_height db 0                             ; aumento de altura por setor
MOUNTAIN_TYPE   equ 0
BRICK_TYPE      equ 4
SPEED_PLANET    equ 10000
TERRAIN_LENGTH  equ 13
MAX_BLOCKS      equ 50                                    ; máximo de blocos
terrain_heights db 1, 0, 0, 0, 1, 3, 2, 1, 0, 0, 0, 2, 1  ; altura inicial = 11 blocos
block_type      dw MAX_BLOCKS DUP(0)                      ; tipo de bloco para desenhar
block_types     dw offset mountain, offset mountain_top
                dw offset brick, offset brick_top

; variaveis menu
menu_active db 1
exit_game db 0
active_button db 1, 0
button_colors db 0Fh, 0Ch
wrap_screen dw 0

; variaveis setor
current_timer db SECTOR_TIME              ; game timer 60s
current_sector db FIRST_SECTOR
sectors dw offset START_SECTOR_ONE, offset START_SECTOR_TWO, offset START_SECTOR_THREE
sector_bonus_points db 0
obstacle_str_offset dw 0                  ; qual objeto desenhar (meteoro ou alien)

; variaveis player
lives db 3
score_points dw 0

; cor texto
str_int_color db 02h

; BIOS real time clock passed (relógio BIOS)
current_rtc db 0
has_moved db 0            ; flag usada para otimizacao (apenas elementos movidos sao redesenhados)

; strings ----------------------------
start db "JOGAR$"
exit db "SAIR$"

score db "SCORE: $"
score_foreground db "00000$"
timer db "TEMPO: $"
; ------------------------------------

.code  

INCLUDE platform.asm ; procs basicas
INCLUDE game.asm     ; logica do jogo / desenhar elementos
INCLUDE menu.asm     ; proc para desenhar menu

MAIN:   
    mov ax, @data
    mov ds, ax
    mov es, ax

    call INIT_WINDOW

    MAIN_LOOP:
        mov al, [menu_active]
        cmp al, 1
        je OPEN_MENU

    START_GAME:
        call DRAW_GAME

    OPEN_MENU:
        call DRAW_MENU

        mov al, [exit_game]
        cmp al, 1
        je EXIT_LOOP
        jmp MAIN_LOOP
    EXIT_LOOP:
        mov ah, 4Ch
        int 21h
end MAIN
