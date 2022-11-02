#include <SDL2/SDL_ttf.h>

.data
scoreFmtString:                     .asciz "Score: %d"
highestFmtString:                   .asciz "Highest: %d"
livesFmtString:                     .asciz "Lives: IIIII"

gameOverString:                     .asciz "Game Over! Press any keys to restart."

currentScoreTexture: .quad 0# pointer of an SDL_Texture
currentScoreSurface: .quad 0 # pointer of an SDL_Surface
highestScoreTexture: .quad 0 # pointer of an SDL_Texture
highestScoreSurface: .quad 0 # pointer of an SDL_Surface
livesTexture:        .quad 0 # pointer of an SDL_Texture
livesSurface:        .quad 0 # pointer of an SDL_Surface
gameOverTexture:     .quad 0 # pointer of an SDL_Texture
gameOverSurface:     .quad 0 # pointer of an SDL_Surface

highestScoreBuffer: .skip 32 # string buffer for printing current score
currentScoreBuffer: .skip 32 # string buffer for printing highest score
livesBuffer:        .skip 32 # string buffer for printing lives

.global currentScoreBuffer
.global highestScoreBuffer


.global score
.global lives
.global highestScore

font:               .quad 0 # pointer of a TTF_Font

# rectangles for the texts

currentScoreRect:
    currentScoreRect_x: .long 0
    currentScoreRect_y: .long 0
    currentScoreRect_w: .long 0
    currentScoreRect_h: .long 0

highestScoreRect:
    highestScoreRect_x: .long 0
    highestScoreRect_y: .long 0
    highestScoreRect_w: .long 0
    highestScoreRect_h: .long 0

livesRect:
    livesRect_x:    .long 0
    livesRect_y:    .long 0
    livesRect_w:    .long 0
    livesRect_h:    .long 0

gameOverRect:
    gameOverRect_x: .long 278
    gameOverRect_y: .long 300
    gameOverRect_w: .long 0
    gameOverRect_h: .long 0

textColor:
    textColor_r:    .byte 0
    textColor_g:    .byte 103
    textColor_b:    .byte 78
    textColor_a:    .byte 255

fontPath: .asciz "../resources/JetBrainsMono-Regular.ttf"
ttfFailureString: .asciz "TTF_OpenFont failed.\n"
.text


initFont:
    pushq %rbp
    movq %rsp, %rbp

    call TTF_Init

    # open font
    leaq fontPath, %rdi
    movq $0, %rax
    movq $20, %rsi
    call TTF_OpenFont
    # store font pointer
    movq %rax, font

    # check if font is loaded
    cmpq $0, %rax
    jne skipFailure
        movq $ttfFailureString, %rdi # print error message
        movq $0, %rax
        call printf

        movq $1, %rdi # exit(1)
        call exit
    skipFailure:


    # render game over
    # textSurface = TTF_RenderText_Blended(font, "Game Over", textColor))
    movq font, %rdi
    movq $gameOverString, %rsi
    movl textColor, %edx
    call TTF_RenderText_Blended

    # set width and height of the text
    movl 16(%rax), %r8d
    movl %r8d, gameOverRect_w # width
    movl 20(%rax), %r8d
    movl %r8d, gameOverRect_h # height (from SDL_Surface)

    # save textSurface pointer
    movq %rax, gameOverSurface

    # SDL_CreateTextureFromSurface(renderer, %rax surface)
    movq renderer,   %rdi
    movq %rax, %rsi
    call SDL_CreateTextureFromSurface
    movq %rax, gameOverTexture


    # return
    movq %rbp, %rsp
    popq %rbp
    ret
.global initFont


updateText:
    pushq %rbp
    movq %rsp, %rbp

    # Destroy previous textures, so that we don't have memory leaks
    movq currentScoreTexture, %rdi
    call SDL_DestroyTexture
    movq highestScoreTexture, %rdi
    call SDL_DestroyTexture
    movq livesTexture, %rdi
    call SDL_DestroyTexture

    # Destroy previous surfaces, so that we don't have memory leaks
    movq currentScoreSurface, %rdi
    call SDL_FreeSurface
    movq highestScoreSurface, %rdi
    call SDL_FreeSurface
    movq livesSurface, %rdi
    call SDL_FreeSurface


    # Print text into buffers
    call getScore
    movl %eax, %ecx
    movq $currentScoreBuffer, %rdi
    movq $30, %rsi
    movq $scoreFmtString, %rdx
    call snprintf

    call getHighestScore
    movl %eax, %ecx
    movq $highestScoreBuffer, %rdi
    movq $30, %rsi
    movq $highestFmtString, %rdx
    call snprintf

    call getLives
    movq $0, %rsi
    movl %eax, %esi
    addl $8, %esi
    movq $livesBuffer, %rdi
    movq $livesFmtString, %rdx
    call snprintf

    # Render highest score
        # textSurface = TTF_RenderText_Blended(font, highestScoreBuffer, textColor))
        movq font, %rdi
        movq $highestScoreBuffer, %rsi
        movl textColor, %edx
        call TTF_RenderText_Blended

        # set width and height of the text
        movl 16(%rax), %r8d
        movl %r8d, highestScoreRect_w # width
        movl 20(%rax), %r8d
        movl %r8d, highestScoreRect_h # height (from SDL_Surface)

        movq %rax, highestScoreSurface # save textSurface pointer
        # SDL_CreateTextureFromSurface(renderer, %rax surface)
        movq renderer,   %rdi
        movq %rax, %rsi
        call SDL_CreateTextureFromSurface
        movq %rax, highestScoreTexture

    # Render current score
        # textSurface = TTF_RenderText_Blended(font, currentScoreBuffer, textColor))
        movq font, %rdi
        movq $currentScoreBuffer, %rsi
        movl textColor, %edx
        call TTF_RenderText_Blended

        # set width and height of the text
        movl 16(%rax), %r8d
        movl %r8d, currentScoreRect_w # width
        movl 20(%rax), %r8d
        movl %r8d, currentScoreRect_h # height (from SDL_Surface)

        movq %rax, currentScoreSurface # save textSurface pointer
        # SDL_CreateTextureFromSurface(renderer, %rax surface)
        movq renderer,   %rdi
        movq %rax, %rsi
        call SDL_CreateTextureFromSurface
        movq %rax, currentScoreTexture

    # Render lives
        # textSurface = TTF_RenderText_Blended(font, livesBuffer, textColor))
        movq font, %rdi
        movq $livesBuffer, %rsi
        movl textColor, %edx
        call TTF_RenderText_Blended

        # set width and height of the text
        movl 16(%rax), %r8d
        movl %r8d, livesRect_w # width
        movl 20(%rax), %r8d
        movl %r8d, livesRect_h # height (from SDL_Surface)

        # save textSurface pointer
        movq %rax, livesSurface

        # SDL_CreateTextureFromSurface(renderer, %rax surface)
        movq renderer,   %rdi
        movq %rax, %rsi
        call SDL_CreateTextureFromSurface
        movq %rax, livesTexture



    call setTextPosition

    movq %rbp, %rsp
    popq %rbp
    ret
.global updateText

setTextPosition:
    pushq %rbp
    movq %rsp, %rbp

    cmpb $1, isGameRunning
    jne setTextPositionGameOver
    # if game is running
        movl $25, livesRect_x
        movl $25, livesRect_y

        movl $25, currentScoreRect_x
        movl $949, currentScoreRect_y

        movl $949, highestScoreRect_y
        movl $975, %eax
        subl highestScoreRect_w, %eax
        movl %eax, highestScoreRect_x

        jmp setTextPositionEnd
    # if game is over
    setTextPositionGameOver:
        # dont display lives
        movl $4000, livesRect_x

        # display everything in the middle
        movl $400, currentScoreRect_x
        movl $500, currentScoreRect_y

        movl $400, highestScoreRect_x
        movl $560, highestScoreRect_y

    setTextPositionEnd:

    movq %rbp, %rsp
    popq %rbp
    ret

drawText:
    pushq %rbp
    movq %rsp, %rbp

    # SDL_RenderCopy(renderer, currentScoreTexture, NULL, &currentScoreRect)
    movq renderer, %rdi
    movq currentScoreTexture, %rsi
    movq $0, %rdx
    movq $currentScoreRect, %rcx
    call SDL_RenderCopy

    # SDL_RenderCopy(renderer, highestScoreTexture, NULL, &highestScoreRect)
    movq renderer, %rdi
    movq highestScoreTexture, %rsi
    movq $0, %rdx
    movq $highestScoreRect, %rcx
    call SDL_RenderCopy

    # SDL_RenderCopy(renderer, livesTexture, NULL, &livesRect)
    movq renderer, %rdi
    movq livesTexture, %rsi
    movq $0, %rdx
    movq $livesRect, %rcx
    call SDL_RenderCopy

    cmpb $1, isGameRunning
    jne drawTextGameOver
    # if game is running
        jmp drawTextEnd

    # if game is over
    drawTextGameOver:
        # SDL_RenderCopy(renderer, gameOverTexture, NULL, &gameOverRect)
        movq renderer, %rdi
        movq gameOverTexture, %rsi
        movq $0, %rdx
        movq $gameOverRect, %rcx
        call SDL_RenderCopy

    drawTextEnd:

    movq %rbp, %rsp
    popq %rbp
    ret

.global drawText