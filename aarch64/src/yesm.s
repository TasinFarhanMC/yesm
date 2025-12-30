.equ WRITE, 64
.equ EXIT, 93
.equ SIG_ACTION, 134

.set STDOUT, 1

.set SIGINT, 2
.set SIGPIPE, 13
.set SIGTERM, 15

.set PAGE, 4096

.section .rodata

sig_action:
	.quad exit
	.quad 0

default_yes:
	.rept  2048
	.ascii "y\n"
	.endr

	.section .text
	.global  _start

_start:
	mov x19, x0
	mov x20, x1

	mov x8, #SIG_ACTION
	mov x0, #SIGINT
	ldr x1, =sig_action
	mov x2, #0
	mov x3, #8
	svc #0

	mov x8, #SIG_ACTION
	mov x0, #SIGTERM
	ldr x1, =sig_action
	mov x2, #0
	mov x3, #8
	svc #0

	mov x8, #SIG_ACTION
	mov x0, #SIGPIPE
	ldr x1, =sig_action
	mov x2, #0
	mov x3, #8
	svc #0

	subs x19, x19, #1
	beq  default

	ldr x19, =default_yes // TODO: REMOVE DEFAULT
	mov x20, #PAGE

loop:
	mov x8, #WRITE
	mov x0, #STDOUT
	mov x1, x19
	mov x2, x20
	svc #0

default:
	ldr x19, =default_yes
	mov x20, #PAGE
	b   loop

exit:
	mov x8, #EXIT
	mov x0, #0
	svc #0
