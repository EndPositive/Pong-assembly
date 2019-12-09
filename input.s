.global set_keyboard_handler, curr_key

.equ    UP,     0x48
.equ    DOWN,   0x50
.equ    SPACE,  0x39
.equ    ESC,    1
.equ    ENTER,  0x1c

.data
    curr_key:   .zero  1

.text
    set_keyboard_handler:
        pushl   $irq1
        pushl   $1
        call    set_irq_handler
        call    enable_irq
        addl    $8, %esp
        ret
    irq1:
        pushl   %eax

        wait:
            inb     $0x64, %al
            test    $1, %al
            jz      wait

            xor     %eax, %eax
            inb     $0x60, %al

        case_up:
            cmpb    $UP, %al
            jne     case_down
            movb    $1, curr_key
            jmp     return
        case_down:
            cmpb    $DOWN, %al
            jne     case_space
            movb    $2, curr_key
            jmp     return
        case_space:
            cmpb    $SPACE, %al
            jne     case_esc
            movb    $3, curr_key
            jmp     return
        case_esc:
            cmpb    $ESC, %al
            jne     case_enter
            movb    $4, curr_key
        case_enter:
            cmpb    $ENTER, %al
            jne     return
            movb    $5, curr_key
        return:
            movb    $0, %al
            popl    %eax
            jmp     end_of_irq1
