.global main, clear_screen, game_loop, show_start, show_game, show_easter_egg, show_scores, showing_start, showing_scores, showing_easter_egg, putline, render_text, time, int_string, int_to_string

.bss
    int_string:         .zero   20
    state:              .zero   4
    showing_start:      .zero   4
    showing_scores:     .zero   4
    showing_easter_egg: .zero   4
    time:               .zero   4

.text
    main:
        # Set the timer frequency to 60Hz
        pushl   $60
        call    set_timer_frequency
        addl    $4, %esp

        movl    $-1, balldx
        movl    $1, balldy

        # Set up VGA stuff
        call    color_text_mode
        call    hide_cursor

        # Set up keyboard
        call    set_keyboard_handler

        jmp     show_start

    game_loop:
        incl    (time)

        cmpb    $1, (showing_start)
        je      start_menu_inputs

        cmpb    $1, (showing_scores)
        je      scores_inputs

        cmpb    $1, (showing_easter_egg)
        je      easter_egg_inputs

        call    game

        cmpb    $4, (curr_key)
        je      show_start

        jmp     game_loop

    show_game:
        movb    $0, showing_start
        movb    $0, showing_scores
        movb    $0, showing_easter_egg
        movb    $0, curr_key
        call    init_game
        jmp     game_loop

    show_start:
        movb    $1, showing_start
        movb    $0, showing_scores
        movb    $0, showing_easter_egg
        movb    $0, curr_key
        call    render_start_menu
        jmp     game_loop

    show_scores:
        movb    $0, showing_start
        movb    $1, showing_scores
        movb    $0, showing_easter_egg
        movb    $0, curr_key
        call    render_scores
        jmp     game_loop

    show_easter_egg:
        movb    $0, showing_start
        movb    $0, showing_scores
        movb    $1, showing_easter_egg
        movb    $0, curr_key
        call    render_easter_egg
        jmp     game_loop

    clear_screen:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp

        # Clear the screen
        movb    $' ', %al
        movb    $0x0F, %ah
        movl    $25*80, %ecx
        movl    $vga_memory, %edi
        cld
        rep     stosw

        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    /*
    edi = string to write
    edx = line to print chars to
    ecx = line offset
    */
    render_text:
        # prologue
        pushl   %ebp
        movl    %esp, %ebp

        # find memory address to start writing to (will be in eax)
        movl    %edx, %eax
        movl    $160, %ebx
        movl    $0, %edx
        mull    %ebx

        addl    %ecx, %eax
        addl    $vga_memory, %eax

    render_text_loop:
        # move char at (%edi) into vga memory
        movb    (%edi), %bl
        movb    %bl, (%eax)

        # increment pointers
        addl    $2, %eax
        incl    %edi

        cmpb    $0, (%edi)                                  # if end reached
        je      render_text_end                             # exit the loop
        jmp     render_text_loop                            # else continue the loop

    render_text_end:
        # epilogue
        movl    %ebp, %esp
        popl    %ebp
        ret

    /*
    edi = number
    puts the string to write in int_string
    */
    int_to_string:
        # prologue
        pushl   %ebp
        movl    %esp, %ebp

        movl    $0, %ecx                                    # use ecx as counter of digits
        int_to_string_loop:
            # divide edi by 10
            movl    %edi, %eax                              # division has to be done into eax
            movl    $10, %ebx                               # ebx temp holds 10
            movl    $0, %edx                                # edx will be the remainder
            divl    %ebx                                    # eax /= 10; edx = eax % 10
            addl    $48, %edx                               # convert digit to ascii by adding '0'

            pushl   %edx                                    # push edx onto the stack
            incl    %ecx                                    # increment the digit counter
            movl    %eax, %edi                              # restore the result to edi

            cmpl    $0, %edi                                # if edi has reached 0
            je      put_int_into_string                     # exit the loop
            jmp     int_to_string_loop                      # else jump back to the loop start

        put_int_into_string:
            movl    $int_string, %ebx                       # ebx will point to the string

        put_int_into_string_loop:
            popl    %edx                                    # move the digit from the stack into edx
            movb    %dl, (%ebx)                             # move the digit into the string

            incl    %ebx                                    # increment the string pointer
            decl    %ecx                                    # decrement the counter

            cmpl    $0, %ecx                                # if the counter has reached 0
            jle     int_to_string_end                       # exit the loop
            jmp     put_int_into_string_loop                # else continue the loop

    int_to_string_end:
        movb    $0, (%ebx)                                  # NULL terminate the string
        # epilogue
        movl    %ebp, %esp
        popl    %ebp
        ret
