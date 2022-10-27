#include "math.h"
#include "SDL2/SDL_mixer.h"
#include "SDL2/SDL.h"
#include "SDL2/SDL_timer.h"
#include "stdbool.h"
#include "SDL2/SDL2_gfxPrimitives.h"
#include "time.h"
#include "SDL2/SDL_ttf.h"
#include "stdio.h"
#include "f2fs_fs.h"

.global main

.data
.equ MIX_DEFAULT_FORMAT, 0x8010
.equ SDL_INIT_EVERYTHING, 0x0000FFFF
.equ SDL_WINDOWPOS_CENTERED, 0x2FFF0000
.equ SDL_WINDOW_SHOWN, 0x00000004
.equ SDL_RENDERER_ACCELERATED, 0x00000002
.equ MIX_INIT_MP3, 0x00000008

SDL_HINT_RENDER_SCALE_QUALITY: .asciz "SDL_RENDER_SCALE_QUALITY"
sdlInitFailedMessage: .asciz "SDL_Init failed. Exiting..."
title: .asciz "Geometry Semicolon 1.0"
musicPath: .asciz "../resources/zanobi.mp3"
musicError: .asciz "error loading music: %s\n"
music: .quad 0

win: .quad 0
one_string: .string "1"
isAppRunning: .byte 1 # bool
.global isAppRunning
.text
main:
    pushq %rbp
    movq %rsp, %rbp

    # if (SDL_Init(SDL_INIT_EVERYTHING) != 0) {
    #    printf("error initializing SDL: %s\n", SDL_GetError());
    # }
    movl $SDL_INIT_EVERYTHING, %edi
    movq $0, %rax
    call SDL_Init
    test %eax, %eax
    jnz errorSDLInit


    #  SDL_Window *win = SDL_CreateWindow("Geometry Semicolon 1.0",
    #                                        SDL_WINDOWPOS_CENTERED,
    #                                        SDL_WINDOWPOS_CENTERED,
    #                                        windowWidthInt, windowHeightInt, SDL_WINDOW_SHOWN); // done
     

    movq $title, %rdi
    movl $SDL_WINDOWPOS_CENTERED, %esi
    movl $SDL_WINDOWPOS_CENTERED, %edx
    movl windowWidth, %ecx
    movl windowHeight, %r8d
    movl $SDL_WINDOW_SHOWN, %r9d
    call SDL_CreateWindow
    movq %rax, win



    # renderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED);
    movq win, %rdi
    movq $-1, %rsi
    movl $SDL_RENDERER_ACCELERATED, %edx
    movq $0, %rax
    call SDL_CreateRenderer
    movq %rax, renderer(%rip)

    # Mix_Init(MIX_INIT_MP3);
    movl $MIX_INIT_MP3, %edi
    call Mix_Init

    # Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 1024);
    movl $44100, %edi
    movl $MIX_DEFAULT_FORMAT, %esi
    movl $2, %edx
    movl $1024, %ecx
    movq $0, %rax
    call Mix_OpenAudio

    # Mix_Music *music = Mix_LoadMUS("../../resources/zanobi.mp3");
    movq $musicPath, %rdi
    movq $0, %rax
    call Mix_LoadMUS
    movq %rax, music

    # if (music == NULL) {
    #   printf("error loading music: %s\n", Mix_GetError());
    # }
    cmpl $0, %eax
    je errorLoadingMusic


    # SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "1");
    movq $one_string, %rdi
    movq $SDL_HINT_RENDER_SCALE_QUALITY, %rsi
    movq $0, %rax
    call SDL_SetHint



    # SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "1");
    movq $SDL_HINT_RENDER_SCALE_QUALITY, %rdi
    movq $one_string, %rsi
    movq $0, %rax
    call SDL_SetHint


    # Mix_PlayMusic(music, -1);
    movq music, %rdi
    movq $-1, %rsi
    movq $0, %rax
    call Mix_PlayMusic

    # while (isAppRunning) {
    whileAppRunning:
        call onTick
        cmpb $1, isAppRunning(%rip)
        je whileAppRunning

    # end while

    jmp endMain

    # Error handling
    errorSDLInit:
        movq $sdlInitFailedMessage, %rdi
        movq $0, %rax
        call printf
        jmp endMain

    errorLoadingMusic:
        call SDL_GetError
        movq %rax, %rsi
        movq $0, %rax
        movq $musicError, %rdi
        call printf
        jmp endMain


    endMain:
    movq $0, %rax
    movq %rbp, %rsp
    popq %rbp
    ret

