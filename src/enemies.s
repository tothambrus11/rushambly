.data
#enemy1:
#    x: .word 0     # 0
#    y: .word 0     # 2
#    vx: .word 0    # 4
#    vy: .word 0    # 6
#    pxes:
#        p1_x: .word 0   # 8
#        p2_x: .word 0   # 10
#        p3_x: .word 0   # 12
#    pys:
#        p1_y: .word 0   # 14
#        p2_y: .word 0   # 16
#        p3_y: .word 0   # 18

.equ enemyCount, 8
.equ enemySize, 20
.equ enemiesSize, 160
.global enemiesSize
.global enemySize
enemies: .skip enemiesSize

printSeq: .asciz "x_1 = %d \ty_2 = %d\nx_2 = %d \ty_2 = %d\nx_3 = %d \ty_3 = %d\n\n"

.text

lastEnemyPointer: .quad 0
.global enemies
# initializes first enemy to start from (0, 100) and have a velocity of (1, 0)
initFirstEnemy:
    pushq %rbp
    movq %rsp, %rbp

    movq $enemies, %rax # get address of first enemy
    # up:
    #movw $100, (%rax) # set x to 0
    #movw $1000, 2(%rax) # set y to 100
    #movw $0, 4(%rax) # set vx to 1 so that it initially goes to the right
    #movw $-1, 6(%rax) # set vy to 0

    # down:
    movw $100, (%rax) # set x to 0
    movw $100, 2(%rax) # set y to 100
    movw $0, 4(%rax) # set vx to 0
    movw $1, 6(%rax) # set vy to 1


    movq %rbp, %rsp
    popq %rbp
    ret

.global spawnEnemy
spawnEnemy:
    pushq %rbp
    movq %rsp, %rbp
    pushq %r12
    pushq %r12

    # Search for an enemy that is not moving, thus being an inactive one.
    # for r12 = 0; r12 != enemiesSize, r12 += enemySize:


    movq $0, %r12
    loopThroughEnemiesStart:
        cmpq $enemiesSize, %r12
        je addEnemyEnd # if r12 == enemiesSize, then we have looped through all enemies and found none that are inactive

        # check whether an enemy is inactive by checking whether vx and vy are both zero.
        # Check vx
        movq $4, %r8
        movw enemies(%r12, %r8, 1), %ax
        cmpw $0, %ax
        jne loopThroughEnemiesContinue

        # Check vy
        movq $6, %r8
        movw enemies(%r12, %r8, 1), %ax
        cmpw $0, %ax
        jne loopThroughEnemiesContinue

        # found & done with inactive enemy
        jmp loopThroughEnemiesEnd

        loopThroughEnemiesContinue:

        # increment loop counter
        addq $enemySize, %r12
        jmp loopThroughEnemiesStart
    loopThroughEnemiesEnd:


    # Randomize racket:
    call rand
    movw %ax, %dx
    andw $1, %dx
    cmpw $0, %dx
    je addHorizontalEnemy
    # else addVerticalEnemy

    addVerticalEnemy:
        movw %ax, %dx
        shrw $1, %dx
        andw $1, %dx
        cmpw $0, %dx
        je addUpEnemy
        # else addDownEnemy

        addDownEnemy:
            # set vx to 0
            movq $4, %r8
            movw $0, enemies(%r12, %r8, 1)

            # set vy to 1 so that it initially goes down
            movq $6, %r8
            movw $1, enemies(%r12, %r8, 1)

            # set x to mouseX
            movl mouseX, %eax
            movw %ax, enemies(%r12)

            # set y to $racketInnerO, so that it is just below the racket
            movq $2, %r8
            movw $racketInnerO, enemies(%r12, %r8, 1)

            jmp addEnemyEnd
        addUpEnemy:
            # set vx to 0
            movq $4, %r8
            movw $0, enemies(%r12, %r8, 1)

            # set vy to -1 so that it initially goes up
            movq $6, %r8
            movw $-1, enemies(%r12, %r8, 1)

            # set x to windowWidth - mouseX
            movl windowWidth, %eax
            subl mouseX, %eax
            movw %ax, enemies(%r12)

            # set y to windowHeight - $racketInnerO, so that it is just above the racket
            movl windowHeight, %eax
            subl $racketInnerO, %eax
            movq $2, %r8
            movw %ax, enemies(%r12, %r8, 1)

            jmp addEnemyEnd

    addHorizontalEnemy:
        movw %ax, %dx
        shrw $1, %dx
        andw $1, %dx
        cmpw $1, %dx
        je addRightEnemy
        # else addLeftEnemy

        addLeftEnemy:
            # set vx to -1 so that it initially goes left
            movq $4, %r8
            movw $-1, enemies(%r12, %r8, 1)

            # set vy to 0
            movq $6, %r8
            movw $0, enemies(%r12, %r8, 1)

            # set x to windowWidth - $racketInnerO, so that it is just to the left of the racket
            movl windowWidth, %eax
            subl $racketInnerO, %eax
            movw %ax, enemies(%r12)

            # set y to windowHeight - mouseY
            movl windowHeight, %eax
            subl mouseY, %eax
            movq $2, %r8
            movw %ax, enemies(%r12, %r8, 1)

            jmp addEnemyEnd
        addRightEnemy:
            # set vx to 1 so that it initially goes right
            movq $4, %r8
            movw $1, enemies(%r12, %r8, 1)

            # set vy to 0
            movq $6, %r8
            movw $0, enemies(%r12, %r8, 1)

            # set x to $racketInnerO, so that it is just to the right of the racket
            movw $racketInnerO, enemies(%r12)

            # set y to mouseY
            movl mouseY, %eax
            movq $2, %r8
            movw %ax, enemies(%r12, %r8, 1)

            jmp addEnemyEnd
    addEnemyEnd:

    popq %r12
    popq %r12
    movq %rbp, %rsp
    popq %rbp
    ret

# updates the triangle of the enemy based on its x and y coordinates
# params: %rdi = pointer to enemy
updateTriangle:
    pushq %rbp
    movq %rsp, %rbp


    # check whether enemy is going down:
    movw 6(%rdi), %ax # get vy
    cmpw $0, %ax # compare vy to 0
    jg goingDown # if vy > 0, go to down
    jl goingUp # if vy < 0, go to up

    # if vy == 0, then enemy is going right or left
    movw 4(%rdi), %ax # get vx
    cmpw $0, %ax # compare vx to 0
    jg goingRight # if vx > 0, go to right
    jl goingLeft # if vx < 0, go to left

    # if vx == 0, then enemy is not moving - reset triangle to (0,0), (0,0), (0,0)
    movw $0, 8(%rdi) # set p1_x to 0
    movw $0, 10(%rdi) # set p2_x to 0
    movw $0, 12(%rdi) # set p3_x to 0
    movw $0, 14(%rdi) # set p1_y to 0
    movw $0, 16(%rdi) # set p2_y to 0
    movw $0, 18(%rdi) # set p3_y to 0
    jmp endUpdateTriangleSwitch # go to end of function

    goingRight:
        # if the enemy is going to the right, the triangle coordinates relative to the
        # enemy's x and y coordinates are (0, 0), (-35, 20), (-35, -20)

        # first point (0, 0)
            # x
            movw 0(%rdi), %ax # get x
            movw %ax, 8(%rdi) # set p1_x to x
            # y
            movw 2(%rdi), %ax # get y
            movw %ax, 14(%rdi) # set p1_y to y

        # second point (-35, 20)
            # x
            movw 0(%rdi), %ax # get x
            addw $-35, %ax # add -35 to x
            movw %ax, 10(%rdi) # set p2_x to x-35
            # y
            movw 2(%rdi), %ax # get y
            addw $20, %ax # add 20 to y
            movw %ax, 16(%rdi) # set p2_y to y+20

        # third point (-35, -20)
            # x
            movw 0(%rdi), %ax # get x
            addw $-35, %ax # add -35 to x
            movw %ax, 12(%rdi) # set p3_x to x-35
            # y
            movw 2(%rdi), %ax # get y
            addw $-20, %ax # add -20 to y
            movw %ax, 18(%rdi) # set p3_y to y-20

        jmp endUpdateTriangleSwitch

    goingLeft:
        # if the enemy is going to the left, the triangle coordinates relative to the
        # enemy's x and y coordinates are (0, 0), (35, 20), (35, -20)

        # first point
            # x
            movw 0(%rdi), %ax # get x
            movw %ax, 8(%rdi) # set p1_x to x
            # y
            movw 2(%rdi), %ax # get y
            movw %ax, 14(%rdi) # set p1_y to y

        # second point
            # x
            movw 0(%rdi), %ax # get x
            addw $35, %ax # add 35 to x
            movw %ax, 10(%rdi) # set p2_x to x+35
            # y
            movw 2(%rdi), %ax # get y
            addw $20, %ax # add 20 to y
            movw %ax, 16(%rdi) # set p2_y to y+20

        # third point
            # x
            movw 0(%rdi), %ax # get x
            addw $35, %ax # add 35 to x
            movw %ax, 12(%rdi) # set p3_x to x+35
            # y
            movw 2(%rdi), %ax # get y
            addw $-20, %ax # add -20 to y
            movw %ax, 18(%rdi) # set p3_y to y-20

        jmp endUpdateTriangleSwitch

    goingDown:
        # if the enemy is going down, the triangle coordinates relative to the enemy's
        # x and y coordinates are (0, 0), (-20, -35), (20, -35)

        # first point
            # x
            movw 0(%rdi), %ax # get x
            movw %ax, 8(%rdi) # set p1_x to x
            # y
            movw 2(%rdi), %ax # get y
            movw %ax, 14(%rdi) # set p1_y to y

        # second point
            # x
            movw 0(%rdi), %ax # get x
            addw $-20, %ax # add -20 to x
            movw %ax, 10(%rdi) # set p2_x to x-20
            # y
            movw 2(%rdi), %ax # get y
            addw $-35, %ax # add -35 to y
            movw %ax, 16(%rdi) # set p2_y to y-35

        # third point
            # x
            movw 0(%rdi), %ax # get x
            addw $20, %ax # add 20 to x
            movw %ax, 12(%rdi) # set p3_x to x+20
            # y
            movw 2(%rdi), %ax # get y
            addw $-35, %ax # add -35 to y
            movw %ax, 18(%rdi) # set p3_y to y-35

        jmp endUpdateTriangleSwitch

    goingUp:
        # if the enemy is going up, the triangle coordinates relative to the enemy's
        # x and y coordinates are (0, 0), (-20, 35), (20, 35)

        # first point
            # x
            movw 0(%rdi), %ax # get x
            movw %ax, 8(%rdi) # set p1_x to x
            # y
            movw 2(%rdi), %ax # get y
            movw %ax, 14(%rdi) # set p1_y to y

        # second point
            # x
            movw 0(%rdi), %ax # get x
            addw $-20, %ax # add -20 to x
            movw %ax, 10(%rdi) # set p2_x to x-20
            # y
            movw 2(%rdi), %ax # get y
            addw $35, %ax # add 35 to y
            movw %ax, 16(%rdi) # set p2_y to y+35

        # third point
            # x
            movw 0(%rdi), %ax # get x
            addw $20, %ax # add 20 to x
            movw %ax, 12(%rdi) # set p3_x to x+20
            # y
            movw 2(%rdi), %ax # get y
            addw $35, %ax # add 35 to y
            movw %ax, 18(%rdi) # set p3_y to y+35

        jmp endUpdateTriangleSwitch


    endUpdateTriangleSwitch:
    movq %rbp, %rsp
    popq %rbp
    ret


# parameters: %rdi = enemy pointer
moveEnemy:
    pushq %rbp
    movq %rsp, %rbp

    # add vx to x
    movw 0(%rdi), %ax # get x
    movw 4(%rdi), %dx # get vx
    addw %dx, %ax # add vx to x
    movw %ax, 0(%rdi) # set x to x+vx

    # add vy to y
    movw 2(%rdi), %ax # get y
    movw 6(%rdi), %dx # get vy
    addw %dx, %ax # add vy to y
    movw %ax, 2(%rdi) # set y to y+vy

    # update the triangle coordinates
    call updateTriangle

    movq %rbp, %rsp
    popq %rbp
    ret

# moves all 8 enemies in the global enemies array
moveEnemies:
    pushq %rbp
    movq %rsp, %rbp
    pushq %r12
    pushq %r12

    movw $0, %r12w # set r12w to 0 (index of enemies array)
    loopStart:
        cmpw $enemiesSize, %r12w # check if r12w has reached the 8th enemy
        je loopEnd # if so, jump to loopEnd
        leaq enemies(%r12d), %rdi # get enemy pointer
        call moveEnemy # move enemy
        addw $enemySize, %r12w # increment r12w by the size of the enemy struct
        jmp loopStart # jump to loopStart

    loopEnd:


    popq %r12
    popq %r12
    movq %rbp, %rsp
    popq %rbp
    ret

# parameters: %rdi = renderer, %rsi = enemy pointer
drawEnemy:
    pushq %rbp
    movq %rsp, %rbp
    pushq %r12
    pushq %r12


    movq %rsi, %r12 # enemy pointer in r12
    mov %rdi, %r13 # renderer pointer in r13


    # print the x_1, y_1, x_2, y_2, x_3, y_3 coordinates of the triangle
    movq $0, %rdi
    movq $0, %rsi
    movq $0, %rdx
    movq $0, %rcx
    movq $0, %r8
    movq $0, %r9

    movw 8(%r13), %si  # load p1_x to si
    movw 14(%r13), %dx  # load p1_y to dx
    movw 10(%r13), %cx  # load p2_x to cx
    movw 16(%r13), %r8w  # load p2_y to r8w
    movw 12(%r13), %r9w  # load p3_x to r9w
    pushq 18(%r13)  # load p3_y to next param
    pushq 18(%r13)  # load p3_y to next param
    movq $printSeq, %rdi
    movq $0, %rax
    #call printf
    addq $16, %rsp # pop 2 params



    movq %r12, %rdi
    call isMiddle
    cmpb $1, %axl
    je redEnemyColor
    # else purpleEnemyColor

    # draw the triangle
    # filledPolygonRGBA(renderer, xes, ys, 3, 255, 0, 0, 255);

    # purple enemy color: 106, 88, 177, 255
    movb $106, %r8b # red
    movb $88,  %r9b # green
    pushq $255      # alpha
    pushq $177      # blue
    jmp setAdditionalParamsForDrawTriangle

    redEnemyColor:
    movb $124, %r8b # red
    movb $0, %r9b   # green
    pushq $255      # alpha
    pushq $0        # blue

    setAdditionalParamsForDrawTriangle:

    # renderer
    movq %r13, %rdi
    leaq 8(%r12), %rsi # get pointer to p1_x
    leaq 14(%r12), %rdx # get pointer to p1_y
    movq $3, %rcx # 3 points should be rendered



    call filledPolygonRGBA

    addq $16, %rsp # pop 2 values off the stack

    popq %r12
    popq %r12
    movq %rbp, %rsp
    popq %rbp
    ret


# parameters: %rdi = renderer
drawEnemies:
    pushq %rbp
    movq %rsp, %rbp
    pushq %r12

    movq $enemies, %r12 # enemies array pointer in r12

    # 0th enemy
    pushq %rdi # push renderer
    movq $enemies, %rsi # get pointer to 0th enemy
    call drawEnemy # draw enemy
    popq %rdi # pop renderer

    # 1st enemy
    pushq %rdi # push renderer
    leaq enemySize(%r12), %rsi # get pointer to 1st enemy
    call drawEnemy # draw enemy
    popq %rdi # pop renderer

    # 2nd enemy
    pushq %rdi # push renderer
    leaq 2*enemySize(%r12), %rsi # get pointer to 2nd enemy
    call drawEnemy # draw enemy
    popq %rdi # pop renderer

    # 3rd enemy
    pushq %rdi # push renderer
    leaq 3*enemySize(%r12), %rsi # get pointer to 3rd enemy
    call drawEnemy # draw enemy
    popq %rdi # pop renderer

    # 4th enemy
    pushq %rdi # push renderer
    leaq 4*enemySize(%r12), %rsi # get pointer to 4th enemy
    call drawEnemy # draw enemy
    popq %rdi # pop renderer

    # 5th enemy
    pushq %rdi # push renderer
    leaq 5*enemySize(%r12), %rsi # get pointer to 5th enemy
    call drawEnemy # draw enemy
    popq %rdi # pop renderer

    # 6th enemy
    pushq %rdi # push renderer
    leaq 6*enemySize(%r12), %rsi # get pointer to 6th enemy
    call drawEnemy # draw enemy
    popq %rdi # pop renderer

    # 7th enemy
    pushq %rdi # push renderer
    leaq 7*enemySize(%r12), %rsi # get pointer to 7th enemy
    call drawEnemy # draw enemy
    popq %rdi # pop renderer

    popq %r12
    movq %rbp, %rsp
    popq %rbp
    ret

.global drawEnemies
.global moveEnemies
.global initFirstEnemy
