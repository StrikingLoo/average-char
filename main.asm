section .text

global average_byte
average_byte:
    ; stack frame
    push rbp
    push rbx
    push r15
    
    mov rbx, rdi ; pointer to string
    
    xor r15, r15
    xor rax, rax ; acumulator
    pxor xmm1, xmm1 ; acumulator
    pxor xmm4, xmm4 ; used on comparison

    ; get_length:

    .start_length:
    movdqu xmm0, [rbx + rax]
    pcmpeqb xmm0, xmm1
    VPMOVMSKB r15, xmm0
    add rax, 16
    cmp r15, 0
    jne .border_case
    jmp .start_length

    .border_case:
    popcnt r15, r15
    sub rax, r15
    ; end length calculation.
    mov r15, rax
    xor rax, rax

    .cycle_read:
    cmp rax, r15
    jge .end_cycle
    
    pmovsxbd xmm3, [rbx + rax] ; xmm0 = ['s','t','r','i']
    paddd xmm1, xmm3
    
    add rax, 4
    jmp .cycle_read    
    
    .end_cycle:
    movd xmm2, r15d ; has length of string
    movdqa xmm3, xmm2
    pslldq xmm2, 4
    por xmm2, xmm3 ; xmm2 stores the string length's twice in its 2 least significant DW
    cvtdq2pd xmm2, xmm2 ;now xmm2 has the form PD PD(length) | PD(length)
    
    movdqa xmm3, xmm1
    psrldq xmm3, 8
    paddd xmm1, xmm3 ; xmm1 = trash | trash | s3 + s1 | s2 + s0
    cvtdq2pd xmm1, xmm1 ; xmm1 = PD(s3 + s1) | PD(s2 + s0)

    ; average and final sum
    divpd xmm1, xmm2
    movdqa xmm3, xmm1
    psrldq xmm3, 8
    addpd xmm1, xmm3
    movdqa xmm0, xmm1
    mov rax, r15
    pop r15
    pop rbx
    pop rbp
    ret
