.global init_start_menu, start_menu_inputs

.bss
    start_menu_option:  .zero   1
.text
    welcome_msg:        .asciz  "Welcome to Pong"
    start_msg:          .asciz  "Start game"
    scores_msg:         .asciz  "See high scores"
    easter_egg_msg:     .asciz  "Easter egg"
    navigation_msg:     .asciz  "UP/DOWN to move selection. ENTER to select."

    init_start_menu:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        call    render_start_menu

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    start_menu_inputs:
        cmpb    $1, (curr_key)              # | If current key is the UP key,
        je      move_selection_up           # | Move selection up.
        cmpb    $2, (curr_key)              # | If current key is the DOWN key,
        je      move_selection_down         # | Move selection down.
        cmpb    $5, (curr_key)              # | If current key is the ENTER key,
        je      select                      # | Show the selected view.

        jmp     game_loop                   # Jump back to main loop

    move_selection_up:
        cmpb    $0, (start_menu_option)     # | If the current selection is already at the top
        je      inputs_done                 # | Don't allow move and return to the game loop
        decb    (start_menu_option)         # | Else move selection up
        call    render_start_menu_options   # Render the new selection
        jmp     inputs_done                 # Return back to the game loop

    move_selection_down:
        cmpb    $2, (start_menu_option)     # | If the current selection is already at the top
        je      inputs_done                 # | Don't allow move and return to the game loop
        incb    (start_menu_option)         # | Else move selection down
        call    render_start_menu_options   # Render the new selection
        jmp     inputs_done                 # Return back to the game looop

    inputs_done:
        movb    $0, curr_key                # Set the pressed key back to none. (prevents ESC loop).
        jmp     game_loop                   # Jump back to main loop

    select:
        cmpb    $0, (start_menu_option)     # | If the current selection is 0 (top)
        je      show_game                   # | Exit from the start menu and show the game.
        cmpb    $1, (start_menu_option)     # | If the current selection is 1 (middle)
        je      show_scores                 # | Exit from the start menu and show the high shores.
        cmpb    $2, (start_menu_option)     # | If the current selection is 2 (bottom)
        je      show_easter_egg             # | Exit from the start menu and show the easter egg.

    render_start_menu:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        call    clear_screen                # Clear the screen before rendering new text.

        movl    $welcome_msg, %edi          # \
        movl    $3, %edx                    # | Render text welcome_msg on line 3 at offset 10
        movl    $10, %ecx                   # |
        call    render_text                 # /

        call    render_start_menu_options   # Actually render the start menu options

        movl    $navigation_msg, %edi       # \
        movl    $21, %edx                   # | Render text navigation_msg at the bottom of the screen
        movl    $10, %ecx                   # | at offset 10.
        call    render_text                 # /

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret

    render_start_menu_options:
        pushl	%ebp                        # | Prologue.
        movl	%esp, %ebp                  # /

        movb    $'[', vga_memory + 160*5+10         # Render '[' on line 5 at offset 10
        movb    $' ', vga_memory + 160*5+12         # Render ' ' on line 5 at offset 12
        cmpb    $0, (start_menu_option)             # | If the option is disabled
        jne     start_menu_option_0_disabled        # | Jump past rendering an 'x'
        start_menu_option_0_enabled:
            movb    $'x', vga_memory + 160*5+12     # Render 'x' on line 5 at offset 12
        start_menu_option_0_disabled:
            movb    $']', vga_memory + 160*5+14     # Render ']' on line 5 at offset 14

        movl    $start_msg, %edi            # \
        movl    $5, %edx                    # | Render text start_msg on line 5 at offset 20
        movl    $20, %ecx                   # |
        call    render_text                 # /

        movb    $'[', vga_memory + 160*6+10         # Render '[' on line 6 at offset 10
        movb    $' ', vga_memory + 160*6+12         # Render ' ' on line 6 at offset 12
        cmpb    $1, (start_menu_option)             # | If the option is disabled
        jne     start_menu_option_1_disabled        # | Jump past rendering an 'x'
        start_menu_option_1_enabled:
            movb    $'x', vga_memory + 160*6+12     # Render 'x' on line 6 at offset 12
        start_menu_option_1_disabled:
            movb    $']', vga_memory + 160*6+14     # Render ']' on line 6 at offset 14

        movl    $scores_msg, %edi           # \
        movl    $6, %edx                    # | Render text scores_msg on line 6 at offset 20
        movl    $20, %ecx                   # |
        call    render_text                 # /

        movb    $'[', vga_memory + 160*7+10         # Render '[' on line 7 at offset 10
        movb    $' ', vga_memory + 160*7+12         # Render ' ' on line 7 at offset 12
        cmpb    $2, (start_menu_option)             # | If the option is disabled
        jne     start_menu_option_2_disabled        # | Jump past rendering an 'x'
        start_menu_option_2_enabled:
            movb    $'x', vga_memory + 160*7+12     # Render 'x' on line 7 at offset 12
        start_menu_option_2_disabled:
            movb    $']', vga_memory + 160*7+14     # Render ']' on line 7 at offset 14

        movl    $easter_egg_msg, %edi       # \
        movl    $7, %edx                    # | Render text easter_egg_msg on line 7 at offset 20
        movl    $20, %ecx                   # |
        call    render_text                 # /

        movl	%ebp, %esp                  # \
        popl	%ebp                        # | Epilogue.
        ret
