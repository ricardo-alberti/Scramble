.model small

.stack 100H 

.data 

; constants --------------------------

CR            equ 13       ; carriage return
LF            equ 10       ; line feed
VIDEO_SEG     equ 0A000h   ; video segment start
SPRITE_WIDTH  equ 24
SPRITE_HEIGHT equ 16

; ------------------------------------

; strings ----------------------------

box_corners db "┌┐└┘─│$"
start db "Start$"
exit db "Exit$"

scramble_title db "  ___                    _    _      ", CR, LF
               db " / __| __ _ _ __ _ _ __ | |__| |___  ", CR, LF
               db " \__ \/ _| '_/ _` | '  \| '_ \ / -_) ", CR, LF
               db " |___/\__|_| \__,_|_|_|_|_.__/_\___|$", CR, LF


; ------------------------------------

; variables --------------------------

menu_active db 1
exit_game db 0

positions dw 100 DUP(0)        ; position of elements
active_count db 1 DUP(1)       ; active elements

; ------------------------------------

; sprites ----------------------------

jet db   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
    db   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
    db 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
    db   0,  0,  0,0Ch,0Ch,0Ch,0Ch,0Ch,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
    db   0,  0,  0,0Ch,0Ch,0Ch,  0,  0,  0,  0,0Fh,0Fh,0Fh,0Fh,0Fh,  0,  0,  0,  0,  0,  0,  0,  0,  0
    db   0,  0,  0,  0,0Ch,0Ch,0Ch,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,  0,  0,  0,  0,  0,  0,  0,  0
    db   0,  0,  0,0Ch,0Ch,0Ch,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Ch,0Ch,0Fh,0Fh,0Fh,  0,  0,  0,  0,  0,  0,  0
    db 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Fh,0Fh,0Ch,0Ch,0Ch,0Ch,0Fh,0Fh,  0,  0,  0,  0,  0,  0,  0
    db 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Fh,0Fh,0Ch,0Ch,0Ch,0Ch,0Fh,0Fh,  0,  0,  0,  0,  0,  0,  0
    db   0,  0,  0,0Ch,0Ch,0Ch,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Ch,0Ch,0Fh,0Fh,0Fh,  0,  0,  0,  0,  0,  0,  0
    db   0,  0,  0,  0,0Ch,0Ch,0Ch,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,  0,  0,  0,  0,  0,  0,  0,  0
    db   0,  0,  0,0Ch,0Ch,0Ch,  0,  0,  0,  0,0Fh,0Fh,0Fh,0Fh,0Fh,  0,  0,  0,  0,  0,  0,  0,  0,  0
    db   0,  0,  0,0Ch,0Ch,0Ch,0Ch,0Ch,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
    db 0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,0Ch,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
    db   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
    db   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0

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

        ; TODO: 
        ; - create proc to get input of a exit key
        ; - exit MAIN_LOOP if key is pressed
        mov al, exit_game
        cmp al, 1
        je EXIT_LOOP
        jmp MAIN_LOOP

    EXIT_LOOP:
        mov ah, 4Ch
        int 21h
end MAIN
