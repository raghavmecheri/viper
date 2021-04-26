	.text
	.file	"Viper"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbx
	.cfi_def_cfa_offset 16
	subq	$32, %rsp
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -16
	movl	$4, 28(%rsp)
	leaq	.L__unnamed_1(%rip), %rdi
	callq	create_list@PLT
	movq	%rax, %rbx
	movl	$1, %esi
	movq	%rbx, %rdi
	callq	append_int@PLT
	movl	$2, %esi
	movq	%rbx, %rdi
	callq	append_int@PLT
	movl	$3, %esi
	movq	%rbx, %rdi
	callq	append_int@PLT
	movl	$4, %esi
	movq	%rbx, %rdi
	callq	append_int@PLT
	movl	$5, %esi
	movq	%rbx, %rdi
	callq	append_int@PLT
	movq	%rbx, 16(%rsp)
	leaq	.L__unnamed_2(%rip), %rdi
	callq	create_list@PLT
	movq	%rax, %rbx
	movl	$1, %esi
	movq	%rbx, %rdi
	callq	append_int@PLT
	movl	$2, %esi
	movq	%rbx, %rdi
	callq	append_int@PLT
	movl	$3, %esi
	movq	%rbx, %rdi
	callq	append_int@PLT
	movl	$5, %esi
	movq	%rbx, %rdi
	callq	append_int@PLT
	movq	%rbx, 8(%rsp)
	movq	16(%rsp), %rdi
	movl	$4, %esi
	callq	binary_search@PLT
	movl	%eax, %ecx
	leaq	.Lfmt.1(%rip), %rbx
	xorl	%eax, %eax
	movq	%rbx, %rdi
	movl	%ecx, %esi
	callq	printf@PLT
	movq	8(%rsp), %rdi
	movl	$4, %esi
	callq	binary_search@PLT
	movl	%eax, %ecx
	xorl	%eax, %eax
	movq	%rbx, %rdi
	movl	%ecx, %esi
	callq	printf@PLT
	xorl	%eax, %eax
	addq	$32, %rsp
	popq	%rbx
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.globl	binary_search           # -- Begin function binary_search
	.p2align	4, 0x90
	.type	binary_search,@function
binary_search:                          # @binary_search
	.cfi_startproc
# %bb.0:                                # %entry
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movq	%rdi, 16(%rsp)
	movl	%esi, 12(%rsp)
	movl	$0, 8(%rsp)
	callq	listlen@PLT
	movl	%eax, 4(%rsp)
	movl	$0, (%rsp)
	jmp	.LBB1_1
	.p2align	4, 0x90
.LBB1_3:                                # %then
                                        #   in Loop: Header=BB1_1 Depth=1
	movl	(%rsp), %eax
	incl	%eax
	movl	%eax, 8(%rsp)
.LBB1_1:                                # %while
                                        # =>This Inner Loop Header: Depth=1
	movl	8(%rsp), %eax
	cmpl	4(%rsp), %eax
	jg	.LBB1_7
# %bb.2:                                # %while_body
                                        #   in Loop: Header=BB1_1 Depth=1
	movl	4(%rsp), %eax
	addl	8(%rsp), %eax
	movl	%eax, %esi
	shrl	$31, %esi
	addl	%eax, %esi
	sarl	%esi
	movl	%esi, (%rsp)
	movq	16(%rsp), %rdi
	callq	access_int@PLT
	cmpl	12(%rsp), %eax
	jl	.LBB1_3
# %bb.4:                                # %else
                                        #   in Loop: Header=BB1_1 Depth=1
	movl	(%rsp), %esi
	movq	16(%rsp), %rdi
	callq	access_int@PLT
	cmpl	12(%rsp), %eax
	jle	.LBB1_6
# %bb.5:                                # %then20
                                        #   in Loop: Header=BB1_1 Depth=1
	movl	(%rsp), %eax
	decl	%eax
	movl	%eax, 4(%rsp)
	jmp	.LBB1_1
.LBB1_7:                                # %merge
	movl	$-1, %eax
	addq	$24, %rsp
	retq
.LBB1_6:                                # %else23
	movl	(%rsp), %eax
	addq	$24, %rsp
	retq
.Lfunc_end1:
	.size	binary_search, .Lfunc_end1-binary_search
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

	.type	.L__unnamed_1,@object   # @0
.L__unnamed_1:
	.asciz	"int"
	.size	.L__unnamed_1, 4

	.type	.L__unnamed_2,@object   # @1
.L__unnamed_2:
	.asciz	"int"
	.size	.L__unnamed_2, 4

	.type	.Lfmt.4,@object         # @fmt.4
.Lfmt.4:
	.asciz	"%c\n"
	.size	.Lfmt.4, 4

	.type	.Lfmt.5,@object         # @fmt.5
.Lfmt.5:
	.asciz	"%d\n"
	.size	.Lfmt.5, 4

	.type	.Lfmt.6,@object         # @fmt.6
.Lfmt.6:
	.asciz	"%s\n"
	.size	.Lfmt.6, 4

	.type	.Lfmt.7,@object         # @fmt.7
.Lfmt.7:
	.asciz	"%g\n"
	.size	.Lfmt.7, 4


	.section	".note.GNU-stack","",@progbits
