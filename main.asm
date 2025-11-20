.model small

.stack 100H 

.data 

; sprites ----------------------------
INCLUDE sprites.asm
; -----------------------------------

; constants --------------------------

CR            equ 13       ; carriage return \r
LF            equ 10       ; line feed \n
VIDEO_SEG     equ 0A000h   ; video segment start

SCREEN_WIDTH  equ 320
SCREEN_HEIGHT equ 200

SPRITE_WIDTH  equ 29
SPRITE_HEIGHT equ 13
BLOCK_WIDTH   equ 24
BLOCK_HEIGHT  equ 16
MAX_ELEMENTS  equ 10
SECTOR_TIME   equ 5
FIRST_SECTOR  equ -2

SCREEN_TOP_LIMIT equ 20   ; limit movement
JET_OFFSET       equ 0    ; START POSITION = JET
OBSTACLE_OFFSET  equ 2    ; METEOR OR ALIEN

; movement flags 
DOWN          equ 1000b
UP            equ 0100b
LEFT          equ 0010b
RIGHT         equ 0001b
IDLE          equ 0000b

; keys
KEY_DOWN      equ 50h
KEY_UP        equ 48h
KEY_LEFT      equ 4Bh
KEY_RIGHT     equ 4Dh
KEY_SPACE     equ 39h
KEY_ENTER     equ 1Ch

; ------------------------------------

; variables --------------------------

menu_active db 1
exit_game db 0
active_button db 1, 0
button_colors db 0Fh, 0Ch
obstacle_str_offset dw 0                  ; sets which obstacle to draw
current_rtc db 0                          ; BIOS real time clock passed
current_timer dw SECTOR_TIME              ; game timer 60s

current_sector dw FIRST_SECTOR
sectors dw offset START_SECTOR_ONE, offset START_SECTOR_TWO, offset START_SECTOR_THREE
sector_bonus_points dw 0
            
wrap_screen dw 0
pos_x_high dw MAX_ELEMENTS DUP(0)         ; position of elements
pos_x_low dw MAX_ELEMENTS DUP(0)          
pos_y_high dw MAX_ELEMENTS DUP(0)         
pos_y_low dw MAX_ELEMENTS DUP(0)          

score_points dw 0
active_count dw 0     ; elements to draw/update
lives dw 3
shooting db 1

direction db MAX_ELEMENTS DUP(IDLE)
speed_high dw 0
speed_low dw 0   ; x/65535

; ------------------------------------

; strings ----------------------------

start db "Jogar$"
exit db "Sair$"

sector1 db "SETOR - 1$"
sector2 db "SETOR - 2$"
sector3 db "SETOR - 3$"
score db "Score: $"
score_foreground db "00000$"
timer db "Tempo: $"


scramble_title db "    ___                    _    _      ", CR, LF
               db "   / __| __ _ _ __ _ _ __ | |__| |___  ", CR, LF
               db "   \__ \/ _| '_/ _` | '  \| '_ \ / -_) ", CR, LF
               db "   |___/\__|_| \__,_|_|_|_|_.__/_\___| $", CR, LF

winner db "__   __                  _          ", CR, LF
       db "\ \ / /__ _ _  __ ___ __| |___ _ _  ", CR, LF
       db " \ V / -_) ' \/ _/ -_) _` / _ \ '_| ", CR, LF
       db "  \_/\___|_||_\__\___\__,_\___/_|  $", CR, LF

game_over db "  ___                   ___               ", CR, LF
          db " / __|__ _ _ __  ___   / _ \__ _____ _ _  ", CR, LF
          db "| (_ / _` | '  \/ -_) | (_) \ V / -_) '_| ", CR, LF
          db " \___\__,_|_|_|_\___|  \___/ \_/\___|_|  $", CR, LF

; ------------------------------------

.code  

; procs are pasted here by the linker
INCLUDE platform.asm ; platform layer
INCLUDE game.asm     ; game logic
INCLUDE menu.asm

MAIN:   
    mov ax, @data
    mov ds, ax
    mov es, ax

    call INIT_WINDOW

    MAIN_LOOP:
        mov al, [menu_active]
        cmp al, 1
        jz OPEN_MENU

    START_GAME:
        call DRAW_GAME

    OPEN_MENU:
        call DRAW_MENU

        mov al, exit_game
        cmp al, 1
        je EXIT_LOOP
        jmp MAIN_LOOP
    EXIT_LOOP:
        mov ah, 4Ch
        int 21h
end MAIN
