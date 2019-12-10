.global main, clear_screen, game_loop, show_start, show_game, show_easter_egg, show_scores, showing_start, showing_scores, showing_easter_egg, putline, render_text, tick, int_string, int_to_string

.bss
    int_string:         .zero   20
    state:              .zero   4
    showing_start:      .zero   4
    showing_scores:     .zero   4
    showing_easter_egg: .zero   4
    tick:               .zero   4

.text
    main:
        # Set the timer frequency to 60Hz   #\
        pushl   $60                         # | Bootlib stuff.
        call    set_timer_frequency         # |
        addl    $4, %esp                    # |
                                            # |
        # Set up VGA stuff                  # |
        call    color_text_mode             # |
        call    hide_cursor                 # /

        movl    $-1, balldx                 # Set horizontal speed for the ball.
        movl    $1, balldy                  # Set vertical speed for the ball.

        call    set_keyboard_handler        # Turn on keyboard detection. See input.s.

        jmp     show_start                  # Render the start menu and continue into the game loop.

    # Main loop
    game_loop:
        incl    (tick)                      # Increase tick. Used for timing when the ball must move.

        cmpb    $1, (showing_start)         # | If start menu view is showing,
        je      start_menu_inputs           # | check for inputs specific to start menu view.

        cmpb    $1, (showing_scores)        # | If highscores view is showing,
        je      scores_inputs               # | check for inputs specific to highscores view.

        cmpb    $1, (showing_easter_egg)    # | If easter egg view is showing,
        je      easter_egg_inputs           # | check for inputs specific to easter egg view.

        call    game                        # If none of the views are showing, show the game view.

        cmpb    $4, (curr_key)              # | If the ESC key is pressed,
        je      show_start                  # | Show start menu view.

        jmp     game_loop                   # Jumps back to the start of this loop.

    show_game:
        movb    $0, showing_start           # \
        movb    $0, showing_scores          # | Set which view is currently showing for use in game_loop.
        movb    $0, showing_easter_egg      # /
        movb    $0, curr_key                # Set the pressed key back to none. (prevents ESC loop).
        call    init_game
        jmp     game_loop

    show_start:
        movb    $1, showing_start           # \
        movb    $0, showing_scores          # | Set which view is currently showing for use in game_loop.
        movb    $0, showing_easter_egg      # /
        movb    $0, curr_key                # Set the pressed key back to none. (prevents ESC loop).
        call    init_start_menu
        jmp     game_loop

    show_scores:
        movb    $0, showing_start           # \
        movb    $1, showing_scores          # | Set which view is currently showing for use in game_loop.
        movb    $0, showing_easter_egg      # /
        movb    $0, curr_key                # Set the pressed key back to none. (prevents ESC loop).
        call    render_scores
        jmp     game_loop

    show_easter_egg:
        movb    $0, showing_start           # \
        movb    $0, showing_scores          # | Set which view is currently showing for use in game_loop.
        movb    $1, showing_easter_egg      # /
        movb    $0, curr_key                # Set the pressed key back to none. (prevents ESC loop).
        call    init_easter_egg
        jmp     game_loop

    clear_screen:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        # Clear the screen
        movb    $' ', %al                   # Set character to none.
        movb    $0x0F, %ah                  # Set background to black (0) and text to white (F).
        movl    $25*80, %ecx                # Write above to screen with height=25 and width=80.
        movl    $vga_memory, %edi           # Load the VGA memory location.
        rep     stosw                       # Actually write the above to the screen (also hides QEMU console).

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    /*
    %edi = string to write
    %edx = line to print chars to
    %ecx = line offset
    */
    render_text:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        movl    %edx, %eax                  # \
        movl    $160, %ebx                  # | Find VGA memory address offset to start writing to.
        movl    $0, %edx                    # | Result will be in %eax.
        mull    %ebx                        # /

        addl    %ecx, %eax                  # | Add line offset to VGA memory address offset.
        addl    $vga_memory, %eax           # | Add VGA memory address to offset.

    render_text_loop:
        movb    (%edi), %bl                 # \
        movb    %bl, (%eax)                 # | Moves char at (%edi) into VGA memory.

        # increment pointers
        addl    $2, %eax                    # Increment VGA memory address by 2 (cell width=2).
        incl    %edi                        # Increment string address.

        cmpb    $0, (%edi)                  # | If end of string reached (char=0),
        je      render_text_end             # | Exit the loop.
        jmp     render_text_loop            # | Else jump back to the start of this loop.

    render_text_end:
        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    /*
    %edi = number
    puts the string to write in int_string
    */
    int_to_string:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        movl    $0, %ecx                    # Use %ecx as counter of digits.
        int_to_string_loop:
            movl    %edi, %eax              # \
            movl    $10, %ebx               # | Divide number in %edi by 10.
            movl    $0, %edx                # | Result will be in %eax.
            divl    %ebx                    # /
            addl    $48, %edx               # Convert digit to ascii by adding '0'.

            pushl   %edx                    # Push digit in %edx onto the stack.
            incl    %ecx                    # Increment the digit counter.
            movl    %eax, %edi              # Restore the division result to %edi.

            cmpl    $0, %edi                # | If division result has reached 0.
            je      put_int_into_string     # | Exit the loop.
            jmp     int_to_string_loop      # | Else jump back to the start of this loop.

        put_int_into_string:
            movl    $int_string, %ebx       # %ebx will point to the string where we will store the int.

        put_int_into_string_loop:
            popl    %edx                    # Move the digit from the stack into %edx.
            movb    %dl, (%ebx)             # Move the digit into the string.

            incl    %ebx                    # Increment the string pointer
            decl    %ecx                    # Decrement the digit counter

            cmpl    $0, %ecx                # | If the counter has reached 0,
            jle     int_to_string_end       # | Exit the loop.
            jmp     put_int_into_string_loop# | Else jump back to the start of this loop.

    int_to_string_end:
        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret
