.set WRITE, 1
.set BRK, 12
.set SIG_ACTION, 13
.set EXIT, 60

.set STDOUT, 1

.set SIGINT, 2
.set SIGPIPE, 13
.set SIGTERM, 15

.set PAGE, 4096

.section .rodata

default_yes:
	.rept  2048
	.ascii "y\n"
	.endr

sig_action:
	.quad exit
	.quad 0x04000000

#code
.section .text
.global  _start

_start:
	mov $SIG_ACTION, %rax
	mov $SIGINT, %rdi
	mov $sig_action, %rsi
	xor %rdx, %rdx
	mov $8, %r10
	syscall

	mov $SIG_ACTION, %rax
	mov $SIGTERM, %rdi
	mov $sig_action, %rsi
	xor %rdx, %rdx
	mov $8, %r10
	syscall

	mov $SIG_ACTION, %rax
	mov $SIGPIPE, %rdi
	mov $sig_action, %rsi
	xor %rdx, %rdx
	mov $8, %r10
	syscall

	mov (%rsp), %rbx
	sub $1, %rbx
	jz  default

	mov $BRK, %rax
	xor %rdi, %rdi
	syscall

	mov %rax, %rdi
	mov %rax, %r13 # strlen array
	shl $3, %rbx
	add %rbx, %rdi
	mov $BRK, %rax
	syscall
	mov %rax, %r14 # buffer

	mov (%rsp), %rcx
	dec %rcx
	mov %rcx, %r12               # argc
	xor %rbx, %rbx
	xor %rsi, %rsi
	mov $0x0101010101010101, %r8
	mov $0x8080808080808080, %r9

arg_loop:
	mov 8(%rsp, %rcx, 8), %rdi

	add  %rbx, %rsi
	inc  %rsi
	pxor %xmm1, %xmm1
	jmp  strlen_do

strlen:
	add $16, %rbx

strlen_do:
	movdqu   (%rdi, %rbx), %xmm0
	pcmpeqb  %xmm1, %xmm0
	pmovmskb %xmm0, %rax
	test     %rax, %rax
	jz       strlen

	tzcnt %rax, %rax
	add   %rax, %rbx
	mov   %rbx, -8(%r13, %rcx, 8)
	loop  arg_loop

	add   %rsi, %rbx
	mov   %rbx, %r15 # line size
	mov   $PAGE, %rax
	cmp   %rbx, %rax
	cmova %rax, %rbx  # buffer size

	mov %r14, %rdi
	add %rbx, %rdi
	mov $BRK, %rax
	syscall

	xor %rdx, %rdx
	mov %r14, %rdi
	cld

arg_copy_loop:
	mov 16(%rsp, %rdx, 8), %rsi
	mov (%r13, %rdx, 8), %rax

	mov %rax, %rcx
	shr $3, %rcx
	rep movsq

	mov  %rax, %rcx
	and  $7, %rcx
	rep  movsb
	movb $' ', (%rdi)
	inc  %rdi

	inc  %rdx
	cmp  %r12, %rdx
	jb   arg_copy_loop
	movb $'\n', -1(%rdi)

	cmp %rbx, %r15
	jae loop

	mov %rbx, %rax
	xor %rdx, %rdx
	div %r15

	sub %rdx, %rbx # write size
	xor %rdx, %rdx
	mov %r14, %rdi

line_copy_loop:
	mov %r14, %rsi
	mov %r15, %rcx
	shr $3, %rcx
	rep movsq

	mov %r15, %rcx
	and $7, %rcx
	rep movsb

	inc %rdx
	cmp %rax, %rdx
	jb  line_copy_loop

loop:
	mov $WRITE, %rax
	mov $STDOUT, %rdi
	mov %r14, %rsi
	mov %rbx, %rdx
	syscall
	jmp loop

default:
	mov $default_yes, %r14
	mov $PAGE, %rbx
	jmp loop

exit:
	mov $EXIT, %rax
	xor %rdi, %rdi
	syscall
