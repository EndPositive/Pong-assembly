.global highscores, highscore_count, add_highscore, get_highscore, render_scores, scores_inputs

.bss
    highscores: .zero 404
    highscore_count: .zero 4

.text
    scores_text: .asciz "Top scores:"
    dot_text:   .asciz  "."
    render_scores:
        call    clear_screen

        movl    $scores_text, %edi
        movl    $3, %edx
        movl    $10, %ecx
        call    render_text

        movl    $-1, %esi

        render_scores_loop:
            incl    %esi
            cmpl    $5, %esi
            jge     render_scores_loop_end

            movl    %esi, %edi
            call    get_highscore

            cmpl    $0, %eax
            jle     render_scores_loop_end

            movl    %eax, %edi
            call    int_to_string

            movl    $int_string, %edi
            movl    $5, %edx
            movl    $16, %ecx
            addl    %esi, %edx
            call    render_text

            incl    %esi
            movl    %esi, %edi
            decl    %esi
            call    int_to_string

            movl    $int_string, %edi
            movl    $5, %edx
            movl    $10, %ecx
            addl    %esi, %edx
            call    render_text

            movl    $dot_text, %edi
            movl    $5, %edx
            movl    $12, %ecx
            addl    %esi, %edx
            call    render_text

            jmp     render_scores_loop

        render_scores_loop_end:

        ret

    scores_inputs:
        cmpb    $4, (curr_key)
        jne     game_loop
        call    show_start
        jmp     game_loop

    /*
    edi = highscore to add
    */
    add_highscore:
        # prologue
        pushl   %ebp
        movl    %esp, %ebp

        movl    (highscore_count), %ecx                         # use ecx as counter

        decl    %ecx                                            # now ecx is the index of the last element
        movl    $highscores, %ebx                               # use ebx as pointer to highscores
        add_highscore_loop:
            cmpl    (%ebx, %ecx, 4), %edi                       # if the current score is smaller or equal than the current element
            jle     add_highscore_end                           # exit the loop

            # else move the current element one to the right
            movl    (%ebx, %ecx, 4), %eax
            movl    %eax, 4(%ebx, %ecx, 4)

            decl    %ecx                                        # decrement the counter
            cmpl    $0, %ecx                                    # if the counter is lower than 0
            jl      add_highscore_end                           # exit the loop
            jmp     add_highscore_loop                          # else continue the loop

        add_highscore_end:
            movl    %edi, 4(%ebx, %ecx, 4)                      # move the element one position after the one just checked
            cmpl    $100, (highscore_count)                     # if the max highscore count has already been reached
            je      add_highscore_epilogue                      # skip incrementing
            incl    (highscore_count)                           # else increment the number of scores

        add_highscore_epilogue:
        # epilogue
        movl    %ebp, %esp
        popl    %ebp
        ret


    /*
    edi = index of score to retrieve
    returns the value of the score in eax
    */
    get_highscore:
        # prologue
        pushl   %ebp
        movl    %esp, %ebp

        movl    $highscores, %ebx
        movl    (%ebx, %edi, 4), %eax

        get_highscore_epilogue:
        # epilogue
        movl    %ebp, %esp
        popl    %ebp
        ret
