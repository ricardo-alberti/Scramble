.model small

.stack 100H 

.data 

; constants --------------------------

CR        equ 13       ; carriage return
LF        equ 10       ; line feed
VIDEO_SEG equ 0A000h   ; video segment start

; ------------------------------------

; strings ----------------------------

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

; ------------------------------------

; sprites ----------------------------

; -

; ------------------------------------

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
