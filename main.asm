.model small

.stack 100H 

.data 

; constants --------------------------

CR            equ 13       ; carriage return
LF            equ 10       ; line feed
VIDEO_SEG     equ 0A000h   ; video segment start
SPRITE_WIDTH  equ 24
SPRITE_HEIGHT equ 16
SCREEN_WIDTH  equ 320
SCREEN_HEIGHT equ 200
MAX_ELEMENTS  equ 10

; flags 
DOWN          equ 1000b
UP            equ 0100b
LEFT          equ 0010b
RIGHT         equ 0001b

; keys
KEY_DOWN      equ 's'
KEY_UP        equ 'w'
KEY_LEFT      equ 'a'
KEY_RIGHT     equ 'd'

; ------------------------------------

; strings ----------------------------

box_corners db "┌┐└┘─│$"
start db "Start$"
exit db "Exit$"

scramble_title db "    ___                    _    _      ", CR, LF
               db "   / __| __ _ _ __ _ _ __ | |__| |___  ", CR, LF
               db "   \__ \/ _| '_/ _` | '  \| '_ \ / -_) ", CR, LF
               db "   |___/\__|_| \__,_|_|_|_|_.__/_\___| $", CR, LF

; ------------------------------------

; variables --------------------------

menu_active db 1
exit_game db 0

pos_x_high dw MAX_ELEMENTS DUP(10)         ; position of elements
pos_x_low dw MAX_ELEMENTS DUP(0)          
pos_y_high dw MAX_ELEMENTS DUP(10)         
pos_y_low dw MAX_ELEMENTS DUP(0)          
;active_count db 1 DUP(1)        ; active elements

direction db MAX_ELEMENTS DUP(0001b)
speed_high dw 0
speed_low dw 10000   ; 20000/65535

; ------------------------------------

; sprites ----------------------------
INCLUDE sprites.asm
; -----------------------------------

.code  

; procs are pasted here by the linker
INCLUDE platform.asm ; platform layer
INCLUDE game.asm     ; game logic

MAIN:   
    mov ax, @data
    mov ds, ax
    mov es, ax

    call INIT_WINDOW

    MAIN_LOOP:
        call UPDATE_GAME

        mov al, exit_game
        cmp al, 1
        je EXIT_LOOP
        jmp MAIN_LOOP
    EXIT_LOOP:
        mov ah, 4Ch
        int 21h
end MAIN
