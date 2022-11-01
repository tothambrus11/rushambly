.data

racketLeft: # SDL_Rect
    racketLeft_x:                .long 10
    racketLeft_y:                .long 400
    racketLeft_w:                .long 10
    racketLeft_h:                .long 200

racketRight: # SDL_Rect
    racketRight_x:               .long 980
    racketRight_y:               .long 400
    racketRight_w:               .long 10
    racketRight_h:               .long 200

racketTop: # SDL_Rect
    racketTop_x:                 .long 400
    racketTop_y:                 .long 10
    racketTop_w:                 .long 200
    racketTop_h:                 .long 10

racketBottom: # SDL_Rect
    racketBottom_x:              .long 400
    racketBottom_y:              .long 980
    racketBottom_w:              .long 200
    racketBottom_h:              .long 10

.global racketLeft
.global racketRight
.global racketTop
.global racketBottom

.text
.global updateRacketPositions
.global drawRackets


updateRacketPositions:
    pushq %rbp
    movq %rsp, %rbp

    # update racket positions based on mouse
    # SDL_GetMouseState(&mouseX, &mouseY);
    movq $mouseX, %rdi
    movq $mouseY, %rsi
    call SDL_GetMouseState


    # racketLeft.y = mouseY - racketLeft.h / 2;
    movl racketLeft_h, %eax
    shr $1, %eax
    movl mouseY, %edx
    subl %eax, %edx
    movl %edx, racketLeft_y

    # racketRight.y = (1000 - mouseY) - racketRight.h / 2;
    movl racketRight_h, %eax
    shr $1, %eax
    movl $1000, %edx
    subl mouseY, %edx
    subl %eax, %edx
    movl %edx, racketRight_y

    # racketTop.x = mouseX - racketTop.w / 2;
    movl racketTop_w, %eax
    shr $1, %eax
    movl mouseX, %edx
    subl %eax, %edx
    movl %edx, racketTop_x

    # racketBottom.x = (1000 - mouseX) - racketBottom.w / 2;
    movl racketBottom_w, %eax
    shr $1, %eax
    movl $1000, %edx
    subl mouseX, %edx
    subl %eax, %edx
    movl %edx, racketBottom_x


    movq %rbp, %rsp
    popq %rbp
    ret



# inputs:
drawRackets:
    pushq %rbp
    movq %rsp, %rbp
     # SDL_SetRenderDrawColor(renderer, 0, 255, 194, 255);
    movq    renderer, %rdi
    movb    $0, %sil
    movb    $255, %dl
    movb    $194, %cl
    movb    $255, %r8b
    call    SDL_SetRenderDrawColor

    # SDL_RenderFillRect(renderer, &racketLeft);
    movq renderer(%rip), %rdi
    movq $racketLeft, %rsi
    call SDL_RenderFillRect

    # SDL_RenderFillRect(renderer, &racketRight);
    movq renderer(%rip), %rdi
    movq $racketRight, %rsi
    call SDL_RenderFillRect

    # SDL_RenderFillRect(renderer, &racketTop);
    movq renderer(%rip), %rdi
    movq $racketTop, %rsi
    call SDL_RenderFillRect

    # SDL_RenderFillRect(renderer, &racketBottom);
    movq renderer(%rip), %rdi
    movq $racketBottom, %rsi
    call SDL_RenderFillRect

    movq %rbp, %rsp
    popq %rbp
    ret
