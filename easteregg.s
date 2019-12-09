.global render_easter_egg, easter_egg_inputs

.equ    UP,     0x1
.equ    DOWN,   0x2
.equ    ESC,    0x4

.data
    line: .zero 4
    changed: .zero 1

.text
    t1: .asciz "CONGRATS! YOU FOUND THE EASTER EGG."
    t2: .asciz "NOW CAN YOU FIND THE EASTER EGG WITHIN THE EASTER EGG?"
    t3: .asciz "HINT: HOLD DOWN THE POWER BUTTON"
    t4: .asciz "JK THAT WOULD TURN OFF YOUR COMPUTER."
    t5: .asciz "THAT'S LITERALLY IT."
    t6: .asciz "OR IS IT?"
    t7: .asciz "YEAH THAT IS IT. LAME EASTEREGG (T.T)"

    render_easter_egg:
        # prologue
        pushl   %ebp
        movl    %esp, %ebp

        call    clear_screen
        movl    $10, (line)

    egg_loop:
        cmpb    $0, (changed)
        je      no_screen_clr
        call    clear_screen

    no_screen_clr:
        movl    $t1, %edi
        movl    (line), %edx
        movl    $22, %ecx
        call    render_text

        incl    (line)
        movl    $t2, %edi
        movl    (line), %edx
        movl    $22, %ecx
        call    render_text

        incl    (line)
        movl    $t3, %edi
        movl    (line), %edx
        movl    $22, %ecx
        call    render_text

        incl    (line)
        movl    $t4, %edi
        movl    (line), %edx
        movl    $22, %ecx
        call    render_text

        addl    $100, (line)
        movl    $t5, %edi
        movl    (line), %edx
        movl    $22, %ecx
        call    render_text

        addl    $100, (line)
        movl    $t6, %edi
        movl    (line), %edx
        movl    $22, %ecx
        call    render_text

        addl    $100, (line)
        movl    $t7, %edi
        movl    (line), %edx
        movl    $22, %ecx
        call    render_text

        subl    $303, (line)

        cmpb    $UP, (curr_key)
        je      text_up
        cmpb    $DOWN, (curr_key)
        je      text_down
        cmpb    $ESC, (curr_key)
        je      easter_egg_over

        movl    $0, (changed)
        jmp     egg_loop
    text_up:
        decl    (line)
        movl    $1, (changed)
        jmp     egg_loop
    text_down:
        incl    (line)
        movl    $1, (changed)
        jmp     egg_loop
    easter_egg_over:
        # epilogue
        movl    %ebp, %esp
        popl    %ebp
        ret

    easter_egg_inputs:
        cmpb    $4, (curr_key)
        jne     game_loop
        call    show_start
        jmp     game_loop
