; © Jacob Liam Gill 2025. All rights reserved. **DO NOT REMOVE THIS LINE.**
; Quplexity MUST be credited in the project you use it in either throughout documentation and/or in the code base. **DO NOT REMOVE THIS LINE.**

; I'm striving to make the code for Quplexity as readable as possible.
; If you would like to contribute or contact me for any other reason please don't hesitate to email me: jacobygill@outlook.com
; Or DM/friend request me on Discord: @mrgill0651

section .data
    one dd 1.0
    results dq 0.0, 0.0, 0.0, 0.0           ; To store the result of the division
    mA dq 0.0
    mB dq 0.0

section .text
    global sqrt_array_asm
    global floatingpoint_sqrt
    extern exp
    extern log
    extern sqrt
    global sqrt_exponential_log_asm
    global gills_matrix1x2
    global matrix2x2
    global gills_inv_matrix2x2
    global return_0

sqrt_exponential_log_asm:
    ; Arguments:
    ; xmm0: Input float number

    ; Compute log(x)
    call log                ; Call the log function
    ; Compute exp(log(x)) which is just x
    call exp                ; Call the exp function
    ; Compute sqrt(exp(log(x)))
    sqrtss xmm0, xmm0      ; Compute the square root
    ret

sqrt_array_asm:
    ; Arguments:
    ; rdi: Pointer to input array
    ; rsi: Pointer to output array
    ; rdx: Number of elements in the array

    ; Initialize pointers
    mov     rcx, rdx         ; rcx = number of elements
    cmp     rcx, 0           ; Check if number of elements is zero
    je      done            ; If zero, we're done

.loop:
    ; Load 4 floats from input array into xmm0
    movaps  xmm0, [rdi]
    ; Compute the square root
    sqrtps  xmm0, xmm0
    ; Store the result into the output array
    movaps  [rsi], xmm0
    ; Increment pointers
    add     rdi, 16          ; Move to the next 4 floats
    add     rsi, 16
    ; Decrement the counter
    sub     rcx, 4
    jg      .loop

done:
    ret

floatingpoint_sqrt:
    ; Arguments:
    ; xmm0: Input float number
    ; Return value in xmm0

    ; Compute the square root
    sqrtss xmm0, xmm0
    ; Return the result in xmm0
    ret

gills_matrix1x2:
    ; Multiply two 1 by 2 matrix:
    ; |x| * |y|
    ; |y|   |x|

    ; Load values
    ; Load integers into registers
    movss xmm1, dword [rdi]     ; xmm1 = num1
    movss xmm2, dword [rsi]     ; xmm2 = num2
    movss xmm3, dword [rdx]     ; xmm3 = num3
    movss xmm4, dword [rcx]     ; xmm4 = num4

    ; Perform matrix multiplication
    mulss xmm1, xmm3            ; rax = num1 * num3
    mulss xmm2, xmm4            ; rcx = num2 * num4

    addss xmm1, xmm2            ; rax = rax + rbx

    movss xmm0, xmm1            ; move answer into xmm0 for output.

    ; Store the result in the output matrix
    ;mov qword [rdi], rax       ; First element
    ;mov qword [rdi + 8], rcx   ; Second element

    ret                         ; return to caller

matrix2x2:
    ; Arguments:
    ; rdi: Pointer to matrix A (2x2)
    ; rsi: Pointer to matrix B (2x2)
    ; rdx: Pointer to result matrix C (2x2)

    ; Calculate C[0][0]
    mov rax, [rdi]        ; A[0][0]
    mov rbx, [rdi + 8]    ; A[0][1]
    mov rcx, [rsi]        ; B[0][0]
    mov r8, [rsi + 16]    ; B[1][0]
    imul rax, rcx         ; A[0][0] * B[0][0]
    imul rbx, r8          ; A[0][1] * B[1][0]
    add rax, rbx          ; (A[0][0] * B[0][0]) + (A[0][1] * B[1][0])
    mov [rdx], rax        ; Store result in C[0][0]

    ; Calculate C[0][1]
    mov rax, [rdi]        ; A[0][0]
    mov rbx, [rdi + 8]    ; A[0][1]
    mov rcx, [rsi + 8]    ; B[0][1]
    mov r8, [rsi + 24]    ; B[1][1]
    imul rax, rcx         ; A[0][0] * B[0][1]
    imul rbx, r8          ; A[0][1] * B[1][1]
    add rax, rbx          ; (A[0][0] * B[0][1]) + (A[0][1] * B[1][1])
    mov [rdx + 8], rax    ; Store result in C[0][1]

    ; Calculate C[1][0]
    mov rax, [rdi + 16]   ; A[1][0]
    mov rbx, [rdi + 24]   ; A[1][1]
    mov rcx, [rsi]        ; B[0][0]
    mov r8, [rsi + 16]    ; B[1][0]
    imul rax, rcx         ; A[1][0] * B[0][0]
    imul rbx, r8          ; A[1][1] * B[1][0]
    add rax, rbx          ; (A[1][0] * B[0][0]) + (A[1][1] * B[1][0])
    mov [rdx + 16], rax   ; Store result in C[1][0]

    ; Calculate C[1][1]
    mov rax, [rdi + 16]   ; A[1][0]
    mov rbx, [rdi + 24]   ; A[1][1]
    mov rcx, [rsi + 8]    ; B[0][1]
    mov r8, [rsi + 24]    ; B[1][1]
    imul rax, rcx         ; A[1][0] * B[0][1]
    imul rbx, r8          ; A[1][1] * B[1][1]
    add rax, rbx          ; (A[1][0] * B[0][1]) + (A[1][1] * B[1][1])
    mov [rdx + 24], rax   ; Store result in C[1][1]

    ret

gills_inv_matrix2x2:
    movss   xmm1, dword [rdi]   ; a
    movss   xmm2, dword [rsi]   ; b
    movss   xmm3, dword [rdx]   ; c
    movss   xmm4, dword [rcx]   ; d

    ; det = a*d - b*c
    movaps  xmm5, xmm1
    mulss   xmm5, xmm4
    movaps  xmm6, xmm2
    mulss   xmm6, xmm3
    subss   xmm5, xmm6

    ; reject zero or NaN determinant
    pxor    xmm8, xmm8
    ucomiss xmm5, xmm8
    jp      determinant_error
    je      determinant_error

    movss   xmm0, [one]
    divss   xmm0, xmm5          ; 1/det

    mulss   xmm4, xmm0          ; d/det
    pxor    xmm6, xmm6
    subss   xmm6, xmm2
    mulss   xmm6, xmm0          ; -b/det
    pxor    xmm7, xmm7
    subss   xmm7, xmm3
    mulss   xmm7, xmm0          ; -c/det
    mulss   xmm1, xmm0          ; a/det

    movss   dword [r8],      xmm4
    movss   dword [r8 + 4],  xmm6
    movss   dword [r8 + 8],  xmm7
    movss   dword [r8 + 12], xmm1

    mov     eax, 1
    ret

determinant_error:
    mov rax, 0
    ret

return_0:
    ret
