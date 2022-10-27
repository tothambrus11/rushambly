.equ SDL_KEYDOWN, 0x300
.equ SDL_QUIT, 0x100
.equ ballSize, 44
.equ ballBigR, 22
.equ ballLittleR, 12
.equ ballBigRInner, ballBigR - 5
.equ ballLittleRInner, ballLittleR - 5

.data
event: .skip 56 # an SDL_Event
mouseX: .long 0
mouseY: .long 0



ballX: .long 500
ballY: .long 500
vx: .long 1
vy: .long 2


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

ballRectVertical: # SDL_Rect
    ballRectVertical_x:          .long 0
    ballRectVertical_y:          .long 0
    ballRectVertical_w:          .long ballLittleR * 2
    ballRectVertical_h:          .long ballBigR * 2

ballRectHorizontal: # SDL_Rect
    ballRectHorizontal_x:        .long 0
    ballRectHorizontal_y:        .long 0
    ballRectHorizontal_w:        .long ballBigR * 2
    ballRectHorizontal_h:        .long ballLittleR * 2

ballRectVerticalInner: # SDL_Rect
    ballRectVerticalInner_x:     .long 0
    ballRectVerticalInner_y:     .long 0
    ballRectVerticalInner_w:     .long ballLittleRInner * 2
    ballRectVerticalInner_h:     .long ballBigRInner * 2

ballRectHorizontalInner: # SDL_Rect
    ballRectHorizontalInner_x:   .long 0
    ballRectHorizontalInner_y:   .long 0
    ballRectHorizontalInner_w:   .long ballBigRInner * 2
    ballRectHorizontalInner_h:   .long ballLittleRInner * 2




.text
onTick:
    # prologue
    pushq %rbp
    movq %rsp, %rbp

    #         if (SDL_PollEvent(&event)) {
    #              switch (event.type) {
    #                  case SDL_KEYDOWN:
    #                      if (event.key.keysym.sym == SDLK_SPACE) {
    #                          if (isGameRunning) {
    #                              onSpacePressed();
    #                          } else {
    #                              restartGame();
    #                          }
    #                      }
    #                      break;
    #                  case SDL_QUIT:
    #                      isAppRunning = false;
    #                      break;
    #                  default:
    #                      break;
    #              }
    #          }

    # SDL_PollEvent(&event)
    movq $0, %rax
    movl $event, %edi
    call SDL_PollEvent

    cmpl $0, %eax
    jz skipEventChecking

        movl event(%rip), %edi
        cmpl $SDL_KEYDOWN, %edi
        je handleKeydown

        cmpl $SDL_QUIT, %edi
        je handleQuit



        handleKeydown:

            jmp switchEnd


        handleQuit:
            movb $0, isAppRunning
            jmp switchEnd


        switchEnd:

    skipEventChecking:

    #    if (isGameRunning) {
    #        updatePlayerRotation();
    #        updatePos();
    #        moveObstacles();
    #        updateVel();
    #    }

    skipGameUpdate:

    # Clear screen
    # SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);

    movq    renderer, %rdi
    movb    $0, %sil
    movb    $0, %dl
    movb    $0, %cl
    movb    $255, %r8b
    call    SDL_SetRenderDrawColor

    # SDL_RenderClear(renderer);
    movq renderer(%rip), %rdi
    call SDL_RenderClear


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


    # Draw circle for ball
    # SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    movq    renderer, %rdi
    movb    $106, %sil
    movb    $88,  %dl
    movb    $177, %cl
    movb    $255, %r8b
    call    SDL_SetRenderDrawColor

    # Draw horizontal ball rect at ballX - $ballBigR, ballY - $ballLittleR
    movl ballX, %eax
    subl $ballBigR, %eax
    movl %eax, ballRectHorizontal_x
    movl ballY, %eax
    subl $ballLittleR, %eax
    movl %eax, ballRectHorizontal_y

    # SDL_RenderFillRect(renderer, &ballRectHorizontal);
    movq renderer, %rdi
    movq $ballRectHorizontal, %rsi
    call SDL_RenderFillRect

    # Draw vertical ball rect at ballX - $ballLittleR, ballY - $ballBigR
    movl ballX, %eax
    subl $ballLittleR, %eax
    movl %eax, ballRectVertical_x
    movl ballY, %eax
    subl $ballBigR, %eax
    movl %eax, ballRectVertical_y

    # SDL_RenderFillRect(renderer, &ballRectVertical);
    movq renderer, %rdi
    movq $ballRectVertical, %rsi
    call SDL_RenderFillRect


    # Draw inner rectangles for ball

    # SDL_SetRenderDrawColor(renderer, 26, 18, 57, 255);
    movq    renderer, %rdi
    movb    $26, %sil
    movb    $18, %dl
    movb    $57, %cl
    movb    $255, %r8b
    call    SDL_SetRenderDrawColor

    # Draw horizontal ball rect at ballX - $ballBigRInner, ballY - $ballLittleRInner
    movl ballX, %eax
    subl $ballBigRInner, %eax
    movl %eax, ballRectHorizontalInner_x
    movl ballY, %eax
    subl $ballLittleRInner, %eax
    movl %eax, ballRectHorizontalInner_y

    # SDL_RenderFillRect(renderer, &ballRectHorizontalInner);
    movq renderer, %rdi
    movq $ballRectHorizontalInner, %rsi
    call SDL_RenderFillRect

    # Draw vertical ball rect at ballX - $ballLittleRInner, ballY - $ballBigRInner
    movl ballX, %eax
    subl $ballLittleRInner, %eax
    movl %eax, ballRectVerticalInner_x
    movl ballY, %eax
    subl $ballBigRInner, %eax
    movl %eax, ballRectVerticalInner_y

    # SDL_RenderFillRect(renderer, &ballRectVerticalInner);
    movq renderer, %rdi
    movq $ballRectVerticalInner, %rsi
    call SDL_RenderFillRect



    # Move ball
    # ballX += vx;
    movl ballX, %eax
    addl vx, %eax
    movl %eax, ballX

    # ballY += vy;
    movl ballY, %eax
    addl vy, %eax
    movl %eax, ballY




    # SDL_RenderPresent(renderer);
    movq renderer(%rip), %rdi
    call SDL_RenderPresent


    # SDL_Delay(1);    
    movq $1, %rdi
    call SDL_Delay

    


    # epilogue
    movq %rbp, %rsp
    pop %rbp
    ret

.global onTick
