.global render_start_menu, start_menu_inputs

.bss
    start_menu_option:  .zero   1
.data
    welcome_msg:        .asciz  "Welcome to Pong"
    start_msg:          .asciz  "Start game"
    scores_msg:         .asciz  "See high scores"
    easter_egg_msg:     .asciz  "Easter egg"
.text
    render_start_menu:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp

        call    clear_screen

        movl    $welcome_msg, %edi
        movl    $10, %edx
        movl    $20, %ecx
        call    render_text

        movb    $'[', vga_memory + 160*13+20
        cmpb    $0, (start_menu_option)
        jne     start_menu_option_0_disabled
        start_menu_option_0_enabled:
            movb    $'x', vga_memory + 160*13+22
        start_menu_option_0_disabled:
            movb    $']', vga_memory + 160*13+24

        movl    $start_msg, %edi
        movl    $13, %edx
        movl    $30, %ecx
        call    render_text

        movb    $'[', vga_memory + 160*14+20
        cmpb    $1, (start_menu_option)
        jne     start_menu_option_1_disabled
        start_menu_option_1_enabled:
            movb    $'x', vga_memory + 160*14+22
        start_menu_option_1_disabled:
            movb    $']', vga_memory + 160*14+24

        movl    $scores_msg, %edi
        movl    $14, %edx
        movl    $30, %ecx
        call    render_text

        movb    $'[', vga_memory + 160*15+20
        cmpb    $2, (start_menu_option)
        jne     start_menu_option_2_disabled
        start_menu_option_2_enabled:
            movb    $'x', vga_memory + 160*15+22
        start_menu_option_2_disabled:
            movb    $']', vga_memory + 160*15+24

        movl    $easter_egg_msg, %edi
        movl    $15, %edx
        movl    $30, %ecx
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
        call    render_start_menu
        jmp     move_done

    move_down:
        cmpb    $2, (start_menu_option)
        jl      move_option_down
        jmp     move_done
    move_option_down:
        incb    (start_menu_option)
        call    render_start_menu
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
