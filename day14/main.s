%define WIDTH 101
%define HEIGHT 103
%define CENTER_X 50
%define CENTER_Y 51
%define TIME 100

section .data
    filename db 'input.txt', 0 ; Null-terminated string
    newline db 10, 0

section .bss
    fd resq 1 ; File descriptor saved on 8 bytes
    statbuf resb 144; statbuf from sys_fstat is exactly 144 bytes long
    top_left resq 1
    top_right resq 1
    bottom_left resq 1
    bottom_right resq 1

section .text
    global _start

; r11 : mmap address
; syscall args : rdi, rsi, rdx, r10, r8, r9
_start:
    mov qword [top_left], 0
    mov qword [top_right], 0
    mov qword [bottom_left], 0
    mov qword [bottom_right], 0

    mov rax, 2 ; sys_open
    mov rdi, filename
    mov rsi, 0 ; O_RDONLY
    mov rdx, 0 ; mode = 0
    syscall

    cmp rax, 0
    js .exit_error

    mov qword [fd], rax

    call .load_file
    
    mov rsi, r11 ; rsi = mmap address
    call .parse_line
    call .final_sum

    ; Clean up and exit
    call .close_file


; Problem-specific functions

.parse_line:
    ; rsi : pointer to the start of the line
    
    add rsi, 2 ; Skip the "p=" part
    call .parse_number
    mov r12, rax ; Save x0

    inc rsi ; Skip ","
    call .parse_number
    mov r13, rax ; Save y0

    add rsi, 3 ; Skip " v="
    call .parse_number
    mov r14, rax ; Save vx

    inc rsi ; Skip ","
    call .parse_number
    mov r15, rax ; Save vy

    call .compute_future_position

    ; Skip "\n"
    inc rsi
    mov bl, byte [rsi]
    cmp bl, 0 ; Check if null byte (EOF)

    jnz .parse_line ; If not, parse the next line

    ret

.compute_future_position:
    ; Compute x = (vx * TIME + x0) % WIDTH and y = (vy * TIME + y0) % HEIGHT
    ; Gives output in r12, r13

    imul rax, r14, TIME
    add rax, r12
    xor rdx, rdx

    ; Make sure that rax is positive, to make idiv work as expected
    cmp rax, 0
    jge .skip_adjust_x

.wait_x_positive:
    add rax, WIDTH
    cmp rax, 0
    jl .wait_x_positive

.skip_adjust_x:
    xor rdx, rdx
    cqo
    mov rbx, WIDTH
    idiv rbx
    mov r12, rdx

    imul rax, r15, TIME
    add rax, r13

    cmp rax, 0
    jge .skip_adjust_y

.wait_y_positive:
    add rax, HEIGHT
    cmp rax, 0
    jl .wait_y_positive

.skip_adjust_y:
    mov rbx, HEIGHT
    xor rdx, rdx
    cqo
    idiv rbx
    mov r13, rdx

.check_quadrant:
    ; Check in which quadrant (r12, r13) falls into
    cmp r12, CENTER_X
    jl .left_half
    jg .right_half
    ret

.left_half:
    cmp r13, CENTER_Y
    jl .top_left
    jg .bottom_left
    ret

.right_half:
    cmp r13, CENTER_Y
    jl .top_right
    jg .bottom_right
    ret

.top_left:
    inc qword [top_left]
    ret

.top_right:
    inc qword [top_right]
    ret

.bottom_left:
    inc qword [bottom_left]
    ret

.bottom_right:
    inc qword [bottom_right]
    ret


.final_sum:
    mov rax, qword [top_left]
    mul qword [top_right]
    mul qword [bottom_left]
    mul qword [bottom_right]
    
    mov r8, rax
    call .print_result
    
    ret


; Print labels

.print_result:
    push r11 ; Needed because syscall will overwrite r11

    mov rdi, r8
    call .int_to_str

    ; Print newline
    mov rax, 1 ; write
    mov rdi, 1 ; stdout
    lea rsi, [newline]
    mov rdx, 1 ; length of newline
    syscall

    pop r11
    ret

.int_to_str:
    mov rax, rdi
    lea rsi, [rsp - 32]
    mov rcx, 10
    mov rbx, rsi
.convert_loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    test rax, rax
    jnz .convert_loop

    mov rax, 1
    mov rdi, 1
    mov rdx, rbx
    sub rdx, rsi
    syscall

    ret


; File loading labels

.file_size: ; Set file size into fs
    ; sys_fstat
    mov rax, 5 ; fstat
    mov rdi, qword [fd]
    mov rsi, statbuf
    syscall
    ret

.load_file: ; Load file in memory with mmap
    call .file_size

    mov rax, 9
    mov rdi, 0
    mov rsi, qword [statbuf + 48]
    mov rdx, 1 | 2 ; PROT_READ | PROT_WRITE
    mov r10, 2 ; MAP_PRIVATE
    mov r8, qword [fd]
    mov r9, 0 ; offset
    syscall

    cmp rax, 0 ; Check if mmap result is NULL
    js .exit_error

    mov r11, rax ; Save mmap result in r11

    ret

.close_file:
    mov rax, 11 ; sys_munmap()
    mov rdi, r11 ; addr
    mov rsi, qword [statbuf + 48]; length
    syscall
    cmp rax, 0
    jne .exit_error

    ; Close file descriptor
    mov rax, 3 ; sys_close
    mov rdi, [fd] ; File descriptor
    syscall
    cmp rax, 0
    js .exit_error

    mov rax, 60 ; sys_exit(0)
    xor rdi, rdi
    syscall


; Number parsing labels

.parse_number:
    xor rax, rax
    xor rcx, rcx
    cmp byte [rsi], '-'
    jne .parse_loop
    inc rsi
    mov cl, 1

.parse_loop:
    mov bl, byte [rsi]
    cmp bl, '0'
    jb .done
    cmp bl, '9'
    ja .done
    sub bl, '0'
    imul rax, rax, 10
    add rax, rbx
    inc rsi
    jmp .parse_loop

.done:
    test rcx, rcx
    jz .return
    neg rax
    
.return:
    ret


; Error handling label

.exit_error: ; sys_exit(1)
    mov rax, 60
    mov rdi, 1
    syscall
