.data

.text
.global outOfBounds

userOutOfBounds:
    pushq %rbp
    movq %rsp, %rbp
    pushq %r12
    pushq %r13
    movq %rdi, %r13
    # rdi has offset of enemy which intersected with a padle

    # check if enemy is in the center of the screen

    addq $enemies, %rdi
    call isMiddle
    cmpb $0, %al
    jne middle

    call decreaseLives # lose a life if you miss one, mwahahaha!

    middle:

    # set the enemy to be inactive
    movq $4, %r12
    movw $0, enemies(%r13, %r12, 1)
    movq $6, %r12
    movw $0, enemies(%r13, %r12, 1)

    popq %r13
    popq %r12
    movq %rbp, %rsp
    popq %rbp
    ret

outOfBounds:
    pushq %rbp
    movq %rsp, %rbp
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r14


    movq $0, %r12
    intersectLoopStart:
        cmpq $enemiesSize, %r12
        je intersectLoopEnd
        movq $6, %r14
        movw enemies(%r12, %r14, 1), %r13w
        cmpw $0, %r13w
        jl movingUp
        jg movingDown
        movq $4, %r14
        movw enemies(%r12, %r14, 1), %r13w
        cmpw $0, %r13w
        jg movingRight
        jl movingLeft

        jmp intersectLoopContinue

        # check if the enemy is going up
        movingUp:
            # get p1_y
            movq $14, %r14
            movw enemies(%r12, %r14, 1), %r13w
            cmpw $-20, %r13w
            jg intersectLoopContinue

            movq %r12, %rdi
            call userOutOfBounds

            jmp intersectLoopContinue
        movingDown:
            # get p1_y
            movq $14, %r14
            movw enemies(%r12, %r14, 1), %r13w
            movq windowHeight, %r14
            addq $20, %r14
            cmpw %r14w, %r13w
            jl intersectLoopContinue

            movq %r12, %rdi
            call userOutOfBounds

            jmp intersectLoopContinue
        movingLeft:
            # get p1_x
            movq $8, %r14
            movw enemies(%r12, %r14, 1), %r13w
            cmpw $-20, %r13w
            jg intersectLoopContinue

            movq %r12, %rdi
            call userOutOfBounds

            jmp intersectLoopContinue
        movingRight:
            # get p1_x
            movq $8, %r14
            movw enemies(%r12, %r14, 1), %r13w
            movq windowWidth, %r14
            addq $20, %r14
            cmpw %r14w, %r13w
            jl intersectLoopContinue

            movq %r12, %rdi
            call userOutOfBounds

        intersectLoopContinue:

        addq $enemySize, %r12
        jmp intersectLoopStart
    intersectLoopEnd:

    popq %r14
    popq %r14
    popq %r13
    popq %r12
    movq %rbp, %rsp
    popq %rbp
    ret
