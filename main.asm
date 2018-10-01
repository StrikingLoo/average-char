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

global replace_byte
replace_byte:
    ;stack frame
    push rbp
    push rbx
    push r15
    
    ; rdi : pointer to stream
    ; rsi : have
    ; rdx : want
    xor rax, rax
    pxor xmm1, xmm1
    .get_length:
    movdqu xmm0, [rdi + rax]
    pcmpeqb xmm0, xmm1
    vpmovmskb rbx, xmm0

    add rax, 16

    cmp rbx, 0
    jne .border_case
    jmp .get_length
    
    .border_case:
    popcnt rbx, rbx
    sub rax, rbx ; now rax has the length of the string

    .replace:
    xor rbx, rbx ; will be used for indexing
    pxor xmm3, xmm3

    movd xmm1, esi ; xmm1 has 'have' on lower word
    movd xmm2, edx ; xmm2 has 'want' on lower word

    pshufb xmm2, xmm3 ;repeat least significant byte 16 times
    pshufb xmm1, xmm3 ;repeat least significant byte 16 times

    .cycle_read:
    cmp rbx, rax 
    jge .end_cycle
    movdqu xmm0, [rdi + rbx]
    movdqa xmm3, xmm0
    pcmpeqb xmm3, xmm1 ; check where avoided byte is
    
    pcmpeqb xmm4, xmm4 ; turn everything on
    pxor xmm4, xmm3 ; turn on where avoided byte ISN'T

    pand xmm3, xmm2 ; turn on wanted byte where avoided was
    pand xmm0, xmm4 ; restrict stream to wanted bytes
    por xmm0, xmm3 ; turn on replacement
    movdqu [rdi + rbx], xmm0
    add rbx, 16

    jmp .cycle_read
    .end_cycle:
    
    ; restore stack
    pop r15
    pop rbx
    pop rbp
    ret











