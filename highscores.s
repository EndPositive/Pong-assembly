.global highscores, highscore_count, add_highscore, get_highscore, render_scores, scores_inputs

.bss
    highscores: .zero 404
    highscore_count: .zero 4

.text
    scores_text: .asciz "Top scores:"
    dot_text:   .asciz  "."
    navigation_msg: .asciz  "ESC to go back to main menu."
    render_scores:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        call    clear_screen                # Clear the screen before rendering new text.

        movl    $scores_text, %edi          # \
        movl    $3, %edx                    # | Render text scores_text on line 3 at offset 10.
        movl    $10, %ecx                   # |
        call    render_text                 # /

        movl    $-1, %esi                   # Loop counter set to -1.

        render_scores_loop:
            incl    %esi                    # Increment loop counter.
            cmpl    $5, %esi                # | If the maximum number of scores are rendered,
            jge     render_scores_end       # | exit the loop.

            movl    %esi, %edi              # Move the loop counter to %edi.
            call    get_highscore           # Get the highscore at %edi.

            cmpl    $0, %eax                # | If gotten highscore >= 0,
            jle     render_scores_end       # | exit the loop.

            movl    %eax, %edi              # Move the gotten highscore into %edi.
            call    int_to_string           # Convert the highscore int into a string.

            movl    $int_string, %edi       # \
            movl    $5, %edx                # | Render the high score on line 5+%esi at offset 16.
            movl    $16, %ecx               # |
            addl    %esi, %edx              # |
            call    render_text             # /

            incl    %esi                    # \
            movl    %esi, %edi              # | Convert the loop counter + 1 int into a string.
            decl    %esi                    # | Note: this will be the place before the highscore.
            call    int_to_string           # /

            movl    $int_string, %edi       # \
            movl    $5, %edx                # | Render the place on line 5+%esi at offset 10.
            movl    $10, %ecx               # |
            addl    %esi, %edx              # |
            call    render_text             # /

            movl    $dot_text, %edi         # \
            movl    $5, %edx                # | Render a dot on line 5+%esi at offset 12.
            movl    $12, %ecx               # |
            addl    %esi, %edx              # |
            call    render_text             # /

            jmp     render_scores_loop      # Jump back to the top of this loop.

        render_scores_end:

        movl    $navigation_msg, %edi       # \
        movl    $21, %edx                   # | Render navigation text at the bottom of the view.
        movl    $10, %ecx                   # |
        call    render_text                 # /

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    /*
    %edi = highscore to add
    */
    add_highscore:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        movl    (highscore_count), %ecx     # Move amount of scores into %ecx.

        decl    %ecx                        # Now %ecx is the index of the last element.
        movl    $highscores, %ebx           # Use %ebx as pointer to highscores.
        add_highscore_loop:
            cmpl    (%ebx, %ecx, 4), %edi   # | If the current score is smaller or equal than the current element,
            jle     add_highscore_end       # | exit the loop.

            # Else move the current element one to the right.
            movl    (%ebx, %ecx, 4), %eax
            movl    %eax, 4(%ebx, %ecx, 4)

            decl    %ecx                    # Decrement the counter
            cmpl    $0, %ecx                # | If the counter is lower than 0,
            jl      add_highscore_end       # | exit the loop.
            jmp     add_highscore_loop      # | Else, continue the loop.

        add_highscore_end:
            movl    %edi, 4(%ebx, %ecx, 4)  # Move the element one position after the one just checked
            cmpl    $100, (highscore_count) # | If the max highscore count has already been reached,
            je      add_highscore_epilogue  # | skip incrementing.
            incl    (highscore_count)       # | Else, increment the number of scores.

        add_highscore_epilogue:
        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret


    /*
    edi = index of score to retrieve
    returns the value of the score in eax
    */
    get_highscore:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        movl    $highscores, %ebx
        movl    (%ebx, %edi, 4), %eax

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret
