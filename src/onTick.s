.equ SDL_KEYDOWN, 0x300
.equ SDL_QUIT, 0x100

.equ racketInnerO, 21
.global racketInnerO
.equ CLOCK_MONOTIC, 1

.data
.equ initialTimeDelayBetweenEnemies, 1837500000
timeDelayBetweenEnemies: .quad initialTimeDelayBetweenEnemies
.global initialTimeDelayBetweenEnemies
.global timeDelayBetweenEnemies

event: .skip 56 # an SDL_Event

mouseX: .long 0
mouseY: .long 0

nextEnemyShouldBeSentAt: .quad -1
.global nextEnemyShouldBeSentAt

.global mouseX
.global mouseY

ballX: .long 500
ballY: .long 500
vx: .long 1
vy: .long 2


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
    jz skipEventChecking # when no event is available, skip event checking

        movl event(%rip), %edi
        cmpl $SDL_KEYDOWN, %edi
        je handleKeydown

        cmpl $SDL_QUIT, %edi
        je handleQuit

        jmp switchEnd

        handleKeydown:
            cmpb $0, isGameRunning(%rip)
            je restartGameS
                call spawnEnemy
                jmp switchEnd
            restartGameS:
                call onInit
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

    cmpb $0, isGameRunning
    je skipGameUpdate

        # send enemy if enough time has passed
        movq nextEnemyShouldBeSentAt, %rax
        cmpq currentTimeNs, %rax
        jg skipEnemySending # if currentTimeNs <= nextEnemyShouldBeSentAt
            call spawnEnemy
            movq currentTimeNs, %rax
            movq timeDelayBetweenEnemies, %rdi
            addq %rdi, %rax
            movq %rax, nextEnemyShouldBeSentAt
        skipEnemySending:

        # move enemies
        call moveEnemies

        # check if any enemies hit a racket
        call anyIntersect

        # check if any enemies went out of the screen
        call outOfBounds

        # update racket rectangles
        call updateRacketPositions


    skipGameUpdate:

    # update time
    call updateTime




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

    # draw enemies
    movq renderer(%rip), %rdi
    call drawEnemies

    # draw rackets
    call drawRackets

    # update text
    call updateText

    # draw text
    call drawText

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

updateTime:
    pushq %rbp
    movq %rsp, %rbp

    # clock_gettime(CLOCK_MONOTONIC, &timeStruct);
    #      = timeStruct.tv_sec * 1000000000 + timeStruct.tv_nsec;

    movq $CLOCK_MONOTIC, %rdi
    leaq timeStruct(%rip), %rsi
    call clock_gettime

    # set currentTimeNs = timeStruct.tv_sec * 1000000000 + timeStruct.tv_nsec;
    movq timeStruct(%rip), %rax
    movq $1000000000, %rdx
    mulq %rdx
    addq timeStruct+8(%rip), %rax
    movq %rax, currentTimeNs

    movq %rbp, %rsp
    popq %rbp
    ret


.global onTick
.global updateTime
