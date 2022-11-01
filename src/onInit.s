.data;

.text

.global resetGame

resetGame:
    pushq %rbp
    movq %rsp, %rbp

    # reset the game
    movl $3, (lifes)
    movl $0, (score)

    # reset all enemies

    # update time
    call updateTime

    # send the first enemy
    movq currentTimeNs, %rax
    addq $1000000000, %rax
    movq %rax, nextEnemyShouldBeSentAt


    movq $0, %r8
    resetLoopStart:
        cmpq $enemySize, %r8
        je resetLoopEnd

        movq $enemies, %r9
        addq %r8, %r9
        movl $0, 4(%r9) # reset vx
        movl $0, 6(%r9) # reset vy

        addq $enemySize, %r8
        jmp resetLoopStart
    resetLoopEnd:

    movq %rbp, %rsp
    popq %rbp
    ret

