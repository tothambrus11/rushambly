.data

.text
.global isMiddle
.equ middleSize, 250
.equ middleHalf, 125

# Checks whether the given enemy is started from the middle area (that would mean it is red, and it gives us negative
# points if we hit it)
# @params: %rdi: pointer to enemy
isMiddle:
    pushq %rbp
    movq %rsp, %rbp

    # check the enemy's vy
    movw 6(%rdi), %ax
    cmpw $0, %ax
    jne  vertical

    # check the enemy's vx
    movw 4(%rdi), %ax
    cmpw $0, %ax
    jne horizontal

    # inactive so probably bad
    movq $1, %rax
    jmp end

    horizontal:
        # check if the enemy's y is in the range (windowHeight/2)-175 to (windowHeight/2)+175
        movw windowHeight, %ax
        shr $1, %ax
        subw $middleHalf, %ax
        cmpw %ax, 2(%rdi)
        movq $0, %rax
        jl end

        movw windowHeight, %ax
        shr $1, %ax
        addw $middleHalf, %ax
        cmpw %ax, 2(%rdi)
        movq $0, %rax
        jg end

        # if it is, return 1
        movq $1, %rax
        jmp end
    vertical:
        # check if the enemy's x is in the range (windowWidth/2)-175 to (windowWidth/2)+175
        movw windowWidth, %ax
        shr $1, %ax
        subw $175, %ax
        cmpw %ax, 0(%rdi)
        movq $0, %rax
        jl end

        movw windowWidth, %ax
        shr $1, %ax
        addw $175, %ax
        cmpw %ax, 0(%rdi)
        movq $0, %rax
        jg end

        # if it is, return 1
        movq $1, %rax
        jmp end

    end:

    movq %rbp, %rsp
    popq %rbp
    ret
