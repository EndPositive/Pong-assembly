.global init_easter_egg, easter_egg_inputs, render_easter_egg

.equ    UP,     0x1
.equ    DOWN,   0x2
.equ    ESC,    0x4

.data
    line: .zero 4

.text
    t1: .asciz "CONGRATS! YOU FOUND THE EASTER EGG."
    t2: .asciz "NOW CAN YOU FIND THE EASTER EGG WITHIN THE EASTER EGG?"
    t3: .asciz "HINT: HOLD DOWN THE POWER BUTTON"
    t4: .asciz "JK THAT WOULD TURN OFF YOUR COMPUTER."
    t5: .asciz "THAT'S LITERALLY IT."
    t6: .asciz "OR IS IT?"
    t7: .asciz "YEAH THAT IS IT. LAME EASTEREGG (T.T)"
    navigation_msg: .asciz  "ESC to go back to main menu."

    init_easter_egg:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        movl    $3, (line)                  # Write lines of text starting at line 3.
        call    render_easter_egg           # Render the easter egg

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    easter_egg_inputs:
        cmpb    $1, (curr_key)              # | If current key is the UP key,
        je      move_text_up                # | Move text up.
        cmpb    $2, (curr_key)              # | If current key is the DOWN key,
        je      move_text_down              # | Move text down.
        cmpb    $4, (curr_key)              # | If current key is the ESC key,
        je      show_start                  # | Exit from the easter egg and show start.

        jmp     game_loop                   # Jump back to main loop

    move_text_up:
        cmpl    $-300, (line)               # | If the bottom of the page is reached,
        jle     move_done                   # | Disallow move and jump back to the start of the loop.

        decl    (line)                      # Move the text one line up.
        call    render_easter_egg           # Render the easter egg
        jmp     move_done                   # Jump to exit
    move_text_down:
        cmpl    $3, (line)                  # | If the top of the page is reached,
        jge     move_done                   # | Disallow move and jump back to the start of the loop.

        incl    (line)                      # Move the text one line down.
        call    render_easter_egg           # Render the easter egg
        jmp     move_done                   # Jump to exit

    move_done:
        movb    $0, curr_key                # Set the pressed key back to none. (prevents ESC loop).
        jmp     game_loop                   # Jump back to main loop

    render_easter_egg:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        call    clear_screen                # Clear the screen before rendering new text.

        movl    $t1, %edi                   # \
        movl    (line), %edx                # | Render text t1 on line at offset 10.
        movl    $10, %ecx                   # |
        call    render_text                 # /

        incl    (line)                      # Set line pointer to the next line.
        movl    $t2, %edi                   # \
        movl    (line), %edx                # | Render text t2 on line at offset 10.
        movl    $10, %ecx                   # |
        call    render_text                 # /

        incl    (line)                      # Set line pointer to the next line.
        movl    $t3, %edi                   # \
        movl    (line), %edx                # | Render text t3 on line at offset 10.
        movl    $10, %ecx                   # |
        call    render_text                 # /

        incl    (line)                      # Set line pointer to the next line.
        movl    $t4, %edi                   # \
        movl    (line), %edx                # | Render text t4 on line at offset 10.
        movl    $10, %ecx                   # |
        call    render_text                 # /

        addl    $100, (line)                # Add 100 to the line pointer.
        movl    $t5, %edi                   # \
        movl    (line), %edx                # | Render text t5 on line at offset 10.
        movl    $10, %ecx                   # |
        call    render_text                 # /

        addl    $100, (line)                # Add 100 to the line pointer.
        movl    $t6, %edi                   # \
        movl    (line), %edx                # | Render text t6 on line at offset 10.
        movl    $10, %ecx                   # |
        call    render_text                 # /

        addl    $100, (line)                # Add 100 to the line pointer.
        movl    $t7, %edi                   # \
        movl    (line), %edx                # | Render text t7 on line at offset 10.
        movl    $10, %ecx                   # |
        call    render_text                 # /

        subl    $303, (line)                # Subtract 303 from the line pointer to restore it.

        movl    $navigation_msg, %edi       # \
        movl    $21, %edx                   # | Render text navigation_msg at the bottom of the screen
        movl    $10, %ecx                   # | at offset 10.
        call    render_text                 # /

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret