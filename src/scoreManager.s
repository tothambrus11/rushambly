.data
_score: .long 0
_lives: .long 0
_highestScore: .long 0
.equ initialLives, 5

.text

incrementScore:
    pushq %rbp
    movq %rsp, %rbp

    # increment score value
    incl _score

    # decrement delay between enemies
    subq $50000000, timeDelayBetweenEnemies(%rip)



    # set current score to highest score if it is higher
    movl _highestScore, %eax
    cmpl %eax, _score
    jle notNewHighScore

    # set the new high score
    movl _score, %eax
    movl %eax, _highestScore

    notNewHighScore:

    movq %rbp, %rsp
    popq %rbp
    ret
.global incrementScore


decreaseLives:
    pushq %rbp
    movq %rsp, %rbp

    decl _lives
    cmpb $0, _lives
    jle gameOver
    jmp notGameOver
    gameOver:
        call onGameOver

    notGameOver:
    movq %rbp, %rsp
    popq %rbp
    ret
.global decreaseLives

# returns the contents of the local variable _lives
getLives:
    pushq %rbp
    movq %rsp, %rbp

    movl _lives, %eax

    movq %rbp, %rsp
    popq %rbp
    ret
.global getLives

# returns the contents of the local variable _score
getScore:
    pushq %rbp
    movq %rsp, %rbp

    movl _score, %eax

    movq %rbp, %rsp
    popq %rbp
    ret
.global getScore

# returns the contents of the local variable __highestScore
getHighestScore:
    pushq %rbp
    movq %rsp, %rbp

    movl _highestScore, %eax

    movq %rbp, %rsp
    popq %rbp
    ret
.global getHighestScore

resetScore:
    pushq %rbp
    movq %rsp, %rbp

    # reset score to 0
    movl $0, _score

    movq %rbp, %rsp
    popq %rbp
    ret
.global resetScore

resetLives:
    pushq %rbp
    movq %rsp, %rbp

    # reset lives to initialLives
    movl $initialLives, %eax
    movl %eax, _lives

    movq %rbp, %rsp
    popq %rbp
    ret
.global resetLives
