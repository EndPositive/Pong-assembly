.global paddle, paddlepos, render_paddle, ball, ballpos, render_ball, game, balldx, balldy, render_walls, init_game
.data
    paddlepos:      .zero   4
    ballpos:        .zero   4
    balldx:         .zero   4
    balldy:         .zero   4
    wallx:          .zero   4
    score:          .zero   4
    score_text:     .asciz  "Your score:"
    pause_text1:    .asciz  "Press SPACE"
    pause_text2:    .asciz  "to pause"
    paused_text1:   .asciz  "PAUSED"
    paused_text2:   .asciz  "to continue"
    exit_text1:     .asciz  "Press ESC"
    exit_text2:     .asciz  "to exit"
    key_text1:      .asciz  "Press UP/DOWN"
    key_text2:      .asciz  "to move paddle"
    empty_text:     .asciz  "               "
    game_over_text: .asciz  "GAME OVER!"
    restart_text:   .asciz  "to restart"
    is_paused:      .zero   1
    is_over:        .zero   1

.text
    init_game:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        movb    $0, (is_paused)             # Set paused status back to running
        movb    $0, (is_over)               # Set game over status back to running
        movb    $0, (score)                 # Start game with 0 points.
        movl    $120, (wallx)               # Wall position starts at offset 120.
        movl    $1930, paddlepos            # Set paddle position to line 1 at offset 5 (12*160+5*2)
        movl    $2020, ballpos              # Set ball position to line 1 at offset 100 (12*160+50*2).
        movl    $0, (tick)                  # Reset tick counter

        call    clear_screen                # Clear the screen before rendering new items
        call    render_paddle               # \
        call    render_ball                 # | Render all game items.
        call    render_walls                # |
        call    render_sidebar              # |
        call    render_score                # /

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    game:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        cmpb    $1, (is_over)               # | If the game is over,
        je      game_is_over                # | jump to game is over function.

        cmpb    $1, (is_paused)             # | If the game is paused,
        je      game_is_paused              # | jump to game is paused function.

        cmpb    $3, (curr_key)              # | If current key is the SPACE key,
        je      pause_game                  # | pause the game.

        call    paddle_inputs               # Check for UP/DOWN input for the paddle.
        call    ball                        # Move the ball (and do collision checks).

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    game_is_over:
        cmpb    $3, (curr_key)              # | If current key is the SPACE key,
        je      start_new_game              # | start a new game.

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    start_new_game:
        movb    $0, curr_key                # Set the pressed key back to none.

        call    init_game                   # Initialize a new game.

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    game_over:
        movb    $1, (is_over)               # Set game over status to game over.
        movl    (score), %edi               # Move the score into %edi.
        call    add_highscore               # Add high score to highscore list.

        call    render_game_over            # Render game over text.
        call    render_issue                # Render ball red & add red line to left wall.

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    game_is_paused:
        cmpb    $3, (curr_key)              # | If current key is the SPACE key,
        je      unpause_game                # | unpause the game.

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    unpause_game:
        movb    $0, (is_paused)             # Set paused status back to running.
        movb    $0, (curr_key)              # Set the pressed key back to none.

        call    render_sidebar              # Render running game text in sidebar (remove paused text)

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    pause_game:
        movb    $1, (is_paused)             # Set paused status to paused.
        movb    $0, (curr_key)              # Set the pressed key back to none.

        call    render_paused_sidebar       # Render paused game text in sidebar

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    paddle_inputs:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        cmpb    $1, (curr_key)              # | If current key is the UP key,
        je      move_paddle_up              # | move the paddle up.
        cmpb    $2, (curr_key)              # | If current key is the DOWN key,
        je      move_paddle_down            # | move the paddle down

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    move_paddle_up:
        movl    (paddlepos), %eax           # \
        movl    $160, %ecx                  # | Calculate paddle y pos
        movl    $0, %edx                    # | %eax = paddlepos / 160
        divl    %ecx                        # /

        cmpl    $1, %eax                    # | If the position is <= 1,
        jle     move_paddle_done            # | Disallow move and exit paddle input function.

        subl    $160, (paddlepos)           # Subtract 160 from paddlepos (1 line=160)
        call    render_paddle               # Rerender paddle with new position

        jmp     move_paddle_done            # Exit paddle input function.

    move_paddle_down:
        movl    (paddlepos), %eax           # \
        movl    $160, %ecx                  # | Calculate paddle y pos
        movl    $0, %edx                    # | %eax = paddlepos / 160
        divl    %ecx                        # /

        cmpl    $23, %eax                    # | If the position is >= 23,
        jge     move_paddle_done            # | Disallow move and exit paddle input function.

        addl    $160, (paddlepos)           # Subtract 160 from paddlepos (1 line=160)
        call    render_paddle               # Rerender paddle with new position

        jmp     move_paddle_done            # Exit paddle input function.

    move_paddle_done:
        movb    $0, curr_key                # Set the pressed key back to none.

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    ball:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        cmpl    $3000000, (tick)            # | Only move the ball every 3000000 ticks.
        jge     move_ball                   # |

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    move_ball:
        movl    $0, (tick)                  # Reset tick timer.

        # Ball position
        movl    ballpos, %ecx               # Copy the current ballpos into %ecx.

        # Ball horizontal speed
        movl    (balldx), %eax              # | Calculate horizontal speed (cellwidth=2).
        movl    $2, %ebx                    # | %eax = balldx * 2
        mull    %ebx                        # /

        addl    %eax, %ecx                  # Add horizontal speed to ballpos.

        # Ball vertical speed
        movl    (balldy), %eax              # | Calculate vertical speed.
        movl    $160, %ebx                  # | %eax = ballpos * 160
        mull    %ebx                        # /

        addl    %eax, %ecx                  # Add vertical speed to ballpos.

        cmpl    $4000, %ecx                 # | If the new position is out of (lower bounds),
        jge     y_collision                 # | jump to y_collision to invert vertical speed.

        cmpl    $0, %ecx                    # | If the new position is out of (higher bounds),
        jle     y_collision                 # | jump to y_collision to invert vertical speed.

        # Ball y and x position
        movl    %ecx, %eax                  # \
        movl    $160, %ebx                  # | Calculate ball y and x position.
        movl    $0, %edx                    # | %ebx = %eax = ballpos / 160
        divl    %ebx                        # | %edi = %edx = ballpos % 160
        movl    %eax, %ebx                  # |
        movl    %edx, %edi                  # /

        # Paddle y position
        movl    (paddlepos), %eax           # \
        movl    $160, %esi                  # | Calculate paddle y position.
        movl    $0, %edx                    # | %eax = paddlepos / 160
        divl    %esi                        # /

        cmpl    $10, %edi                   # | If the ball gets to x <= 10,
        jle     check_paddle_collision      # | check for collision with paddle or game over.

        addl    $2, %edi                    # | If the ball gets to x >= wallx - 2,
        cmpl    (wallx), %edi               # | jump to x_colission to invert horizontal speed.
        jge     x_collision                 # |

        movl    $vga_memory, %eax           # Load the VGA memory location.
        addl    (ballpos), %eax             # Offset by the previous ball position.
        movb    $' ', (%eax)                # Hide the previous.

        movl    %ecx, ballpos               # Write the new ball position.
        call    render_ball                 # Render the new ball.

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    x_car_collision:
        addl    $1, score                   # Increase score.
        call    render_score                # Render the new score.

        cmpl    $30, (wallx)                # | If the wall is already on the left most,
        jle     x_collision                 # | Disallow any more wall moving.

        subl    $2, (wallx)                 # \
        call    render_walls                # | Make the sidebar wall more thicc.
        subl    $2, (wallx)                 # |
        call    render_walls                # |
        subl    $2, (wallx)                 # |
        call    render_walls                # /

    x_collision:
        movl    (balldx), %eax              # | Invert the horizontal speed.
        movl    $-1, %ebx                   # | %eax = -1 * %eax
        mull    %ebx                        # /
        movl    %eax, balldx                # Move result back into horizontal speed.
        jmp     move_ball                   # Jump back to move ball to calculate new position.

    y_collision:
        movl    (balldy), %eax              # | Invert the vertical speed.
        movl    $-1, %ebx                   # | %eax = -1 * %eax
        mull    %ebx                        # /
        movl    %eax, balldy                # Move result back into vertical speed.
        jmp     move_ball                   # Jump back to move ball to calculate new position.

    check_paddle_collision:
        # We do this check because wheter the ball is going up or down will influence
        # whether it will hit the paddle in the new position.
        movl    (balldy), %edi              # Copy the current horizontal speed into %edi.
        cmpl    $0, %edi                            # | If the horizontal speed is less than zero,
        jl      check_paddle_collision_upwards      # | jump to check_paddle_collision_upwards.
        cmpl    $0, %edi                            # | If the vertical speed is more than zero,
        jg      check_paddle_collision_downwards    # | jump to check_paddle_collision_downwards

    check_paddle_collision_upwards:
        cmpl    %ebx, %eax                  # | If ball y = paddle y,
        je      x_car_collision             # | jump to x_car_colission to invert horizontal speed, increase score, and move wall.
        subl    $1, %eax                    # Decrement paddle y.
        cmpl    %ebx, %eax                  # | If ball y = paddle y - 1,
        je      x_car_collision             # | jump to x_car_colission to invert horizontal speed, increase score, and move wall.
        subl    $1, %eax                    # Decrement paddle y.
        cmpl    %ebx, %eax                  # | If ball y = paddle y - 2,
        je      x_car_collision             # | jump to x_car_colission to invert horizontal speed, increase score, and move wall.
        jmp     game_over                   # Ball hasn't collided with paddle so game over :(.

    check_paddle_collision_downwards:
        cmpl    %ebx, %eax                  # | If ball y = paddle y,
        je      x_car_collision             # | jump to x_car_colission to invert horizontal speed, increase score, and move wall.
        addl    $1, %eax                    # Increment paddle y.
        cmpl    %ebx, %eax                  # | If ball y = paddle y + 1,
        je      x_car_collision             # | jump to x_car_colission to invert horizontal speed, increase score, and move wall.
        addl    $1, %eax                    # Increment paddle y.
        cmpl    %ebx, %eax                  # | If ball y = paddle y + 2,
        je      x_car_collision             # | jump to x_car_colission to invert horizontal speed, increase score, and move wall.
        jmp     game_over                   # Ball hasn't collided with paddle so game over :(.

    render_paddle:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        movl    $vga_memory, %eax           # Load the VGA memory location.
        addl    (paddlepos), %eax           # Offset by the paddle position.

        movb    $0, -319(%eax)              # Hide old paddle.
        movb    $255, -159(%eax)            # \
        movb    $255, 1(%eax)               # | Draw new paddle.
        movb    $255, 161(%eax)             # /
        movb    $0, 321(%eax)               # Hide old paddle.

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    render_ball:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        movl    $vga_memory, %eax           # Load the VGA memory location.
        addl    (ballpos), %eax             # Offset by the ball position.

        movb    $'O', (%eax)                # Draw a ball.

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    render_issue:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /



        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    render_walls:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        movl    $vga_memory, %eax           # Load the VGA memory location.
        addl    (wallx), %eax               # Offset by the wall x.
        decl    %eax                        # Decrement by 1 so that we change the BG color.

        movb    $255, (%eax)                # Color first cell.

        movl    $-1, %ecx                   # Move -1 into cell counter.

    render_walls_loop:
        incl    %ecx                        # Increment the cell counter.
        cmpl    $24, %ecx                   # | If we have drawn 24 cells,
        jge     render_walls_loop_end       # | exit the render.
        addl    $160, %eax                  # Add one line to the VGA offset.
        movb    $255, (%eax)                # Color the cell at offset.
        jmp     render_walls_loop           # Jump back to start of loop.

    render_walls_loop_end:
        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    render_sidebar:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        movl    $score_text, %edi           # \
        movl    $2, %edx                    # | Render text score_text on line 2 at offset 126.
        movl    $126, %ecx                  # |
        call    render_text                 # /

        movl    $empty_text, %edi           # \
        movl    $15, %edx                   # | Remove text on line 17 at offset 126.
        movl    $126, %ecx                  # |
        call    render_text                 # /

        movl    $pause_text1, %edi          # \
        movl    $16, %edx                   # | Render paragraph about pausing the game
        movl    $126, %ecx                  # | on line 18-19 at offset 126.
        call    render_text                 # |
        movl    $empty_text, %edi           # |
        movl    $17, %edx                   # |
        movl    $126, %ecx                  # |
        call    render_text                 # |
        movl    $pause_text2, %edi          # |
        movl    $17, %edx                   # |
        movl    $126, %ecx                  # |
        call    render_text                 # /

        movl    $key_text1, %edi            # \
        movl    $19, %edx                   # | Render paragraph about keys
        movl    $126, %ecx                  # | on line 22-23 at offset 126.
        call    render_text                 # |
        movl    $key_text2, %edi            # |
        movl    $20, %edx                   # |
        movl    $126, %ecx                  # |
        call    render_text                 # /

        movl    $exit_text1, %edi           # \
        movl    $22, %edx                   # | Render paragraph about exiting the game
        movl    $126, %ecx                  # | on line 22-23 at offset 126.
        call    render_text                 # |
        movl    $exit_text2, %edi           # |
        movl    $23, %edx                   # |
        movl    $126, %ecx                  # |
        call    render_text                 # /

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    render_score:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        movl    (score), %edi               # | Convert score to a string.
        call    int_to_string               # | String will be stored in $int_string.

        movl    $int_string, %edi           # \
        movl    $3, %edx                    # | Render text int_string on line 3 at 126.
        movl    $126, %ecx                  # |
        call    render_text                 # /

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    render_paused_sidebar:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        movl    $paused_text1, %edi         # \
        movl    $15, %edx                   # | Render paragraph about exiting the game
        movl    $126, %ecx                  # | on line 17 and 19 at offset 126.
        call    render_text                 # |
        movl    $paused_text2, %edi         # |
        movl    $17, %edx                   # |
        movl    $126, %ecx                  # |
        call    render_text                 # /

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    render_game_over:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        movl    $game_over_text, %edi       # \
        movl    $15, %edx                   # | Render game_over_text on line 15 at offset 126.
        movl    $126, %ecx                  # |
        call    render_text                 # /

        movl    $vga_memory, %eax           # Load the VGA memory location.
        addl    $2526, %eax                 # Offset by 15*160 + 126
        incl    %eax

        movb    $64, (%eax)                 # \
        addl    $2, %eax                    # | Render red background
        movb    $64, (%eax)                 # |
        addl    $2, %eax                    # |
        movb    $64, (%eax)                 # |
        addl    $2, %eax                    # |
        movb    $64, (%eax)                 # |
        addl    $2, %eax                    # |
        movb    $64, (%eax)                 # |
        addl    $2, %eax                    # |
        movb    $64, (%eax)                 # |
        addl    $2, %eax                    # |
        movb    $64, (%eax)                 # |
        addl    $2, %eax                    # |
        movb    $64, (%eax)                 # |
        addl    $2, %eax                    # |
        movb    $64, (%eax)                 # |
        addl    $2, %eax                    # |
        movb    $64, (%eax)                 # /

        movl    $restart_text, %edi         # \
        movl    $17, %edx                   # | Render game_over_text on line 17 at offset 126.
        movl    $126, %ecx                  # |
        call    render_text                 # /

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret
