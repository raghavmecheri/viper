	.text
	.file	"Viper"
	.section	.rodata.cst8,"aM",@progbits,8
	.p2align	3               # -- Begin function main
.LCPI0_0:
	.quad	4607632778762754458     # double 1.1000000000000001
.LCPI0_1:
	.quad	4612136378390124954     # double 2.2000000000000002
	.text
	.globl	main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbx
	.cfi_def_cfa_offset 16
	subq	$48, %rsp
	.cfi_def_cfa_offset 64
	.cfi_offset %rbx, -16
	movl	$10, 36(%rsp)
	leaq	.Lfmt.1(%rip), %rbx
	movl	$10, %esi
	xorl	%eax, %eax
	movq	%rbx, %rdi
	callq	printf@PLT
	movl	$20, 32(%rsp)
	movl	$20, %esi
	xorl	%eax, %eax
	movq	%rbx, %rdi
	callq	printf@PLT
	movl	$10, 4(%rsp)
	movl	$10, %esi
	xorl	%eax, %eax
	movq	%rbx, %rdi
	callq	printf@PLT
	movl	4(%rsp), %esi
	addl	$10, %esi
	movl	%esi, 28(%rsp)
	xorl	%eax, %eax
	movq	%rbx, %rdi
	callq	printf@PLT
	movb	$97, 3(%rsp)
	movzbl	3(%rsp), %esi
	leaq	.Lfmt(%rip), %rdi
	xorl	%eax, %eax
	callq	printf@PLT
	movb	$1, 2(%rsp)
	movzbl	2(%rsp), %esi
	xorl	%eax, %eax
	movq	%rbx, %rdi
	callq	printf@PLT
	movb	$0, 1(%rsp)
	movzbl	1(%rsp), %esi
	xorl	%eax, %eax
	movq	%rbx, %rdi
	callq	printf@PLT
	movabsq	$4607632778762754458, %rax # imm = 0x3FF199999999999A
	movq	%rax, 16(%rsp)
	leaq	.Lfmt.3(%rip), %rbx
	movsd	.LCPI0_0(%rip), %xmm0   # xmm0 = mem[0],zero
	movb	$1, %al
	movq	%rbx, %rdi
	callq	printf@PLT
	movabsq	$4612136378390124954, %rax # imm = 0x400199999999999A
	movq	%rax, 8(%rsp)
	movsd	.LCPI0_1(%rip), %xmm0   # xmm0 = mem[0],zero
	movb	$1, %al
	movq	%rbx, %rdi
	callq	printf@PLT
	movsd	16(%rsp), %xmm0         # xmm0 = mem[0],zero
	addsd	8(%rsp), %xmm0
	movsd	%xmm0, 40(%rsp)
	movb	$1, %al
	movq	%rbx, %rdi
	callq	printf@PLT
	xorl	%eax, %eax
	addq	$48, %rsp
	popq	%rbx
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	.Lfmt,@object           # @fmt
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lfmt:
	.asciz	"%c\n"
	.size	.Lfmt, 4

	.type	.Lfmt.1,@object         # @fmt.1
.Lfmt.1:
	.asciz	"%d\n"
	.size	.Lfmt.1, 4

	.type	.Lfmt.2,@object         # @fmt.2
.Lfmt.2:
	.asciz	"%s\n"
	.size	.Lfmt.2, 4

	.type	.Lfmt.3,@object         # @fmt.3
.Lfmt.3:
	.asciz	"%g\n"
	.size	.Lfmt.3, 4


	.section	".note.GNU-stack","",@progbits
