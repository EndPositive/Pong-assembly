.global paddle, paddlepos, render_paddle, ball, ballpos, render_ball, game, balldx, balldy, render_walls, init_game
.data
    paddlepos:  .zero   4
    ballpos:    .zero   4
    balldx:     .zero   4
    balldy:     .zero   4
    score:      .zero   4
    score_text: .asciz  "Your score:"
    pause_text1:.asciz  "Press SPACE"
    pause_text2:.asciz  "to pause"
    paused_text1:.asciz  "PAUSED"
    paused_text2:.asciz  "to continue"
    exit_text1: .asciz  "Press ESC"
    exit_text2: .asciz  "to exit"
    empty_text: .asciz  "               "
    lost_text:  .asciz  "GAME OVER!"
    paused:     .zero   1
    is_over:    .zero   1

.text
    init_game:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp

        # Init car
        call    render_score
        movb    $0, (paused)
        movb    $0, (is_over)
        movb    $0, (curr_key)
        movb    $0, (score)
        movl    $1930, paddlepos                # Row 1, Col 5 (12*160+5*2)
        movl    $2020, ballpos                  # Row 2, Col 80 (12*160+5*20)
        call    clear_screen
        call    render_paddle
        call    render_ball
        call    render_walls
        call    render_sidebar

        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    game:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp

        cmpb    $4, (curr_key)
        je      game_end

        cmpb    $1, (is_over)
        jne     game_not_over
        call    render_game_over
        jmp     game_end

    game_not_over:
        cmpb    $3, (curr_key)
        jne     game_no_pause
        call    change_pause

    game_no_pause:
        cmpb    $1, (paused)
        je      game_end

        call    paddle_inputs
        call    ball

    game_end:
        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    change_pause:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp

        cmpb    $1, (paused)
        jne     not_paused
        movb    $0, (paused)
        movb    $0, (curr_key)
        call    render_sidebar
        jmp     change_pause_end

    not_paused:
        movb    $1, (paused)
        movb    $0, (curr_key)
        call    render_paused_sidebar

    change_pause_end:
        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    paddle_inputs:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp

        cmpb    $1, (curr_key)
        je      move_paddle_up
        cmpb    $2, (curr_key)
        je      move_paddle_down

        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    move_paddle_up:
        call    get_paddle_x
        cmpl    $1, %eax
        jle     move_paddle_done
        subl    $160, (paddlepos)
        call    render_paddle
        jmp     move_paddle_done
    move_paddle_down:
        call    get_paddle_x
        cmpl    $23, %eax
        jge     move_paddle_done
        addl    $160, (paddlepos)
        call    render_paddle
        jmp     move_paddle_done
    move_paddle_done:
        movb    $0, curr_key

        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    /*
    returns eax
    */
    get_paddle_x:
        movl    (paddlepos), %eax
        movl    $160, %ecx
        movl    $0, %edx
        divl    %ecx
        ret

    render_paddle:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp

        movl    $vga_memory, %eax       # Load VGA
        addl    (paddlepos), %eax          # Offset by POS

        movb    $0, -319(%eax)
        movb    $255, -159(%eax)
        movb    $255, 1(%eax)
        movb    $255, 161(%eax)
        movb    $0, 321(%eax)

        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    ball:
        cmpl    $5000000, (time)
        jge     move_ball
    ball_end:
        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret
    move_ball:
        movl    $0, (time)

        # ecx = ballpos + balldx
        movl    ballpos, %ecx
        movl    (balldx), %eax
        movl    $2, %ebx
        mull    %ebx
        addl    %eax, %ecx

        # eax = balldy * 160
        movl    (balldy), %eax
        movl    $160, %ebx
        mull    %ebx

        # ball pos:   ebx = ballpos + balldx + 160 * balldy
        addl    %ecx, %eax
        movl    %eax, %ebx

        # Y collision
        cmpl    $4000, %ebx
        jge     y_collision

        cmpl    $0, %ebx
        jle     y_collision

        # ball x:   edi = ballpos % 160
        # ball y:   ecx = ballpos / 160
        movl    %ebx, %eax
        movl    $160, %ecx
        movl    $0, %edx
        divl    %ecx
        movl    %eax, %ecx
        movl    %edx, %edi
        # paddle y:    eax = carpos / 160
        movl    (paddlepos), %eax
        movl    $160, %esi
        movl    $0, %edx
        divl    %esi

        cmpl    $10, %edi
        jle     check_paddle_collision
        cmpl    $118, %edi
        jge     x_collision

        movl    $vga_memory, %eax       # Load VGA
        addl    (ballpos), %eax         # Offset by POS

        movb    $' ', (%eax)

        movl    %ebx, ballpos

        call    render_ball
        jmp     ball_end

    x_car_collision:
        addl    $1, score
        call    render_score

    x_collision:
        movl    (balldx), %eax
        movl    $-1, %ebx
        mull    %ebx
        movl    %eax, balldx
        jmp     move_ball

    y_collision:
        movl    (balldy), %eax
        movl    $-1, %ebx
        mull    %ebx
        movl    %eax, balldy
        jmp     move_ball

    check_paddle_collision:
        movl    (balldy), %edi
        cmpl    $0, %edi
        jl      check_paddle_collision_upwards
        cmpl    $0, %edi
        jg      check_paddle_collision_downwards

    check_paddle_collision_upwards:
        cmpl    %ecx, %eax              # ball y = paddle y
        je      x_car_collision
        subl    $1, %eax
        cmpl    %ecx, %eax              # ball y = paddle y - 1
        je      x_car_collision
        subl    $1, %eax
        cmpl    %ecx, %eax              # ball y = paddle y - 2
        je      x_car_collision
        jmp     game_over

    check_paddle_collision_downwards:
        cmpl    %ecx, %eax              # ball y = paddle y
        je      x_car_collision
        addl    $1, %eax
        cmpl    %ecx, %eax              # ball y = paddle y + 1
        je      x_car_collision
        addl    $1, %eax
        cmpl    %ecx, %eax              # ball y = paddle y + 2
        je      x_car_collision

    game_over:
        movl    (score), %edi
        call    add_highscore

        movb    $1, (is_over)
        jmp     ball_end                 # ball_end is going to exit for us

    render_ball:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp

        movl    $vga_memory, %eax       # Load VGA
        addl    (ballpos), %eax         # Offset by POS

        movb    $'O', (%eax)

        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    render_walls:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp

        movl    $vga_memory, %eax       # Load VGA

        movb    $255, 119(%eax)
        movb    $255, 279(%eax)
        movb    $255, 439(%eax)
        movb    $255, 599(%eax)
        movb    $255, 759(%eax)
        movb    $255, 919(%eax)
        movb    $255, 1079(%eax)
        movb    $255, 1239(%eax)
        movb    $255, 1399(%eax)
        movb    $255, 1559(%eax)
        movb    $255, 1719(%eax)
        movb    $255, 1879(%eax)
        movb    $255, 2039(%eax)
        movb    $255, 2199(%eax)
        movb    $255, 2359(%eax)
        movb    $255, 2519(%eax)
        movb    $255, 2679(%eax)
        movb    $255, 2839(%eax)
        movb    $255, 2999(%eax)
        movb    $255, 3159(%eax)
        movb    $255, 3319(%eax)
        movb    $255, 3479(%eax)
        movb    $255, 3639(%eax)
        movb    $255, 3799(%eax)
        movb    $255, 3959(%eax)

        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    render_sidebar:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp

        movl    $score_text, %edi
        movl    $2, %edx
        movl    $126, %ecx
        call    render_text

        movl    $empty_text, %edi
        movl    $17, %edx
        movl    $126, %ecx
        call    render_text

        movl    $pause_text1, %edi
        movl    $18, %edx
        movl    $126, %ecx
        call    render_text
        movl    $empty_text, %edi
        movl    $19, %edx
        movl    $126, %ecx
        call    render_text
        movl    $pause_text2, %edi
        movl    $19, %edx
        movl    $126, %ecx
        call    render_text

        movl    $exit_text1, %edi
        movl    $22, %edx
        movl    $126, %ecx
        call    render_text
        movl    $exit_text2, %edi
        movl    $23, %edx
        movl    $126, %ecx
        call    render_text

        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    render_score:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp

        movl    (score), %edi
        call    int_to_string

        movl    $int_string, %edi
        movl    $3, %edx
        movl    $126, %ecx
        call    render_text

        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    render_paused_sidebar:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp

        movl    $paused_text1, %edi
        movl    $17, %edx
        movl    $126, %ecx
        call    render_text
        movl    $paused_text2, %edi
        movl    $19, %edx
        movl    $126, %ecx
        call    render_text

        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    render_game_over:
        # prologue
        pushl	%ebp
        movl	%esp, %ebp

        movl    $lost_text, %edi
        movl    $10, %edx
        movl    $60, %ecx
        call    render_text

        # epilogue
        movl	%ebp, %esp
        popl	%ebp
        ret

    sidebar_already_showing:
        ret
