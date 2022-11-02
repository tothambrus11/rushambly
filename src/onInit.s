#include "SDL2/SDL_mixer.h"

.data;

.text

.global maxLives
onInit:
    pushq %rbp
    movq %rsp, %rbp

    # reset the game
    call resetLives
    call resetScore

    # update time
    call updateTime

    # reset all enemies

    movq $0, %r8
    resetLoopStart:
        cmpq $enemiesSize, %r8
        je resetLoopEnd

        movq $enemies, %r9
        addq %r8, %r9
        movw $0, 4(%r9) # reset vx
        movw $0, 6(%r9) # reset vy

        addq $enemySize, %r8
        jmp resetLoopStart
    resetLoopEnd:


    # send the first enemy
    movq currentTimeNs, %rax
    addq $1000000000, %rax
    movq %rax, nextEnemyShouldBeSentAt

    # Mix_ResumeMusic();
    call Mix_ResumeMusic

    # start game
    movb $1, isGameRunning

    # reset the time delay between enemies
    movq $initialTimeDelayBetweenEnemies, timeDelayBetweenEnemies

    movq %rbp, %rsp
    popq %rbp
    ret
.global onInit

