.global render_start_menu, start_menu_inputs

.bss
    start_menu_option:  .zero   1
.text
    welcome_msg:        .asciz  "Welcome to Pong"
    start_msg:          .asciz  "Start game"
    scores_msg:         .asciz  "See high scores"
    easter_egg_msg:     .asciz  "Easter egg"
    navigation_msg:     .asciz  "UP/DOWN to move selection. SPACE to select."
    render_start_menu:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp

        call    clear_screen

        movl    $welcome_msg, %edi
        movl    $3, %edx
        movl    $10, %ecx
        call    render_text

        call    render_start_menu_options

        movl    $navigation_msg, %edi
        movl    $21, %edx
        movl    $10, %ecx
        call    render_text

        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    render_start_menu_options:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp
        movb    $'[', vga_memory + 160*5+10
        movb    $' ', vga_memory + 160*5+12
        cmpb    $0, (start_menu_option)
        jne     start_menu_option_0_disabled
        start_menu_option_0_enabled:
            movb    $'x', vga_memory + 160*5+12
        start_menu_option_0_disabled:
            movb    $']', vga_memory + 160*5+14

        movl    $start_msg, %edi
        movl    $5, %edx
        movl    $20, %ecx
        call    render_text

        movb    $'[', vga_memory + 160*6+10
        movb    $' ', vga_memory + 160*6+12
        cmpb    $1, (start_menu_option)
        jne     start_menu_option_1_disabled
        start_menu_option_1_enabled:
            movb    $'x', vga_memory + 160*6+12
        start_menu_option_1_disabled:
            movb    $']', vga_memory + 160*6+14

        movl    $scores_msg, %edi
        movl    $6, %edx
        movl    $20, %ecx
        call    render_text

        movb    $'[', vga_memory + 160*7+10
        movb    $' ', vga_memory + 160*7+12
        cmpb    $2, (start_menu_option)
        jne     start_menu_option_2_disabled
        start_menu_option_2_enabled:
            movb    $'x', vga_memory + 160*7+12
        start_menu_option_2_disabled:
            movb    $']', vga_memory + 160*7+14

        movl    $easter_egg_msg, %edi
        movl    $7, %edx
        movl    $20, %ecx
        call    render_text

        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    start_menu_inputs:
        cmpb    $1, (curr_key)
        je      move_up
        cmpb    $2, (curr_key)
        je      move_down
        cmpb    $3, (curr_key)
        je      enter
        jmp     game_loop

    move_up:
        cmpb    $0, (start_menu_option)
        jg      move_option_up
        jmp     move_done
    move_option_up:
        decb    (start_menu_option)
        call    render_start_menu_options
        jmp     move_done

    move_down:
        cmpb    $2, (start_menu_option)
        jl      move_option_down
        jmp     move_done
    move_option_down:
        incb    (start_menu_option)
        call    render_start_menu_options
        jmp     move_done

    enter:
        cmpb    $0, (start_menu_option)
        je      show_game
        cmpb    $1, (start_menu_option)
        je      show_scores
        cmpb    $2, (start_menu_option)
        je      show_easter_egg
        jmp     move_done

    move_done:
        movl    $0, curr_key
        jmp     game_loop

    return:
        ret
