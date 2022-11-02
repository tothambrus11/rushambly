.data

.text
.global onGameOver
onGameOver:
    pushq %rbp
    movq %rsp, %rbp

    # Mix_RewindMusic();
    call Mix_RewindMusic

    # Mix_PauseMusic();
    call Mix_PauseMusic

    # isGameRunning = false;
    movb $0, isGameRunning

    movq %rbp, %rsp
    popq %rbp
    ret
