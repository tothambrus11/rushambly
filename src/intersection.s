.data
plusPoint: .asciz " + score\n"
minusPoint: .asciz " - score\n"
fmtStringLifes: .asciz "Lifes Left: %d\n"
fmtStringScore: .asciz "Points: %d\n"

.text
.global anyIntersect


# rdi has offset of enemy which intersected with a padle
onUserIntersected:
    pushq %rbp
    movq %rsp, %rbp
    pushq %r12
    pushq %r12

    movq %rdi, %r12

    # check the enemy's color and change score correspondingly
    # first, check if enemy is in the center of the screen

    call isMiddle
    cmpb $1, %axl

    jne awardPoints

    # penalize since it is in the middle

    ## PENALIZE POINTS

    decl (lifes)

    movq $0, %rax
    movq $fmtStringLifes, %rdi
    movq $0, %rsi
    movl lifes, %esi
    call printf

    cmpl $0, (lifes)
    jne doneAwarding

    # reset game, out of lifes!
    call resetGame

    jmp doneAwarding

    # if not, check if enemy is in the left or right side of the screen
    awardPoints:
        ## AWARD POINTS

        incl (score)

        movq $0, %rax
        movq $fmtStringScore, %rdi
        movq $0, %rsi
        movl score, %esi
        call printf

    doneAwarding:

    # set the enemy to be inactive
    movw $0, 4(%r12) # set vx to
    movw $0, 6(%r12) # set vy to

    popq %r12
    popq %r12 # caller saved registers

    movq %rbp, %rsp
    popq %rbp
    ret


anyIntersect:
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
            cmpw $20, %r13w
            jg intersectLoopContinue

            # get p1_x
            movq $8, %r14
            movw enemies(%r12, %r14, 1), %r13w
            movq $racketTop, %r14
            movw (%r14), %r14w
            cmpw %r13w, %r14w
            jg intersectLoopContinue
            addw $200, %r14w
            cmpw %r13w, %r14w
            jl intersectLoopContinue


            movq %r12, %rdi
            leaq enemies(%rip), %rcx
            addq %rcx, %rdi
            call onUserIntersected

            jmp intersectLoopContinue
        movingDown:
            # get p1_y
            movq $14, %r14
            movw enemies(%r12, %r14, 1), %r13w
            movq windowHeight, %r14
            subq $20, %r14
            cmpw %r14w, %r13w
            jl intersectLoopContinue

            # get p1_x
            movq $8, %r14
            movw enemies(%r12, %r14, 1), %r13w
            movq $racketBottom, %r14
            movw (%r14), %r14w
            cmpw %r13w, %r14w
            jg intersectLoopContinue
            addw $200, %r14w
            cmpw %r13w, %r14w
            jl intersectLoopContinue


            movq %r12, %rdi
            leaq enemies(%rip), %rcx
            addq %rcx, %rdi
            call onUserIntersected

            jmp intersectLoopContinue
        movingLeft:
            # get p1_x
            movq $8, %r14
            movw enemies(%r12, %r14, 1), %r13w
            cmpw $20, %r13w
            jg intersectLoopContinue

            # get p1_y
            movq $14, %r14
            movw enemies(%r12, %r14, 1), %r13w
            movq $racketLeft, %r14
            movw 4(%r14), %r14w
            cmpw %r13w, %r14w
            jg intersectLoopContinue
            addw $200, %r14w
            cmpw %r13w, %r14w
            jl intersectLoopContinue

            movq %r12, %rdi
            leaq enemies(%rip), %rcx
            addq %rcx, %rdi
            call onUserIntersected

            jmp intersectLoopContinue
        movingRight:
            # get p1_x
            movq $8, %r14
            movw enemies(%r12, %r14, 1), %r13w
            movq windowWidth, %r14
            subq $20, %r14
            cmpw %r14w, %r13w
            jl intersectLoopContinue

            # get p1_y
            movq $14, %r14
            movw enemies(%r12, %r14, 1), %r13w
            movq $racketRight, %r14
            movw 4(%r14), %r14w
            cmpw %r13w, %r14w
            jg intersectLoopContinue
            addw $200, %r14w
            cmpw %r13w, %r14w
            jl intersectLoopContinue


            movq %r12, %rdi
            leaq enemies(%rip), %rcx
            addq %rcx, %rdi
            call onUserIntersected

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

