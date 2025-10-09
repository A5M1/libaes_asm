	.intel_syntax noprefix
	.text
	.def	KeyExpansion;	.scl	3;	.type	32;	.endef
KeyExpansion:
	push	rsi
	xor	eax, eax
	push	rbx
.copy_initial_key:
	mov	r8b, BYTE PTR [rdx+rax]
	mov	BYTE PTR [rcx+rax], r8b
	mov	r8b, BYTE PTR 1[rdx+rax]
	mov	BYTE PTR 1[rcx+rax], r8b
	mov	r8b, BYTE PTR 2[rdx+rax]
	mov	BYTE PTR 2[rcx+rax], r8b
	mov	r8b, BYTE PTR 3[rdx+rax]
	mov	BYTE PTR 3[rcx+rax], r8b
	add	rax, 4
	cmp	rax, 16
	jne	.copy_initial_key
	mov	r10d, 4
	lea	r11, sbox[rip]
	lea	rbx, Rcon[rip]
.expand_loop:
	movzx	r9d, BYTE PTR 12[rcx]
	movzx	r8d, BYTE PTR 13[rcx]
	movzx	edx, BYTE PTR 14[rcx]
	movzx	eax, BYTE PTR 15[rcx]
	test	r10d, 3
	jne	.no_schedule_core
	mov	sil, BYTE PTR [r11+r8]
	mov	r8b, BYTE PTR [r11+rdx]
	mov	dl, BYTE PTR [r11+rax]
	mov	al, BYTE PTR [r11+r9]
	mov	r9d, r10d
	shr	r9d, 2
	xor	sil, BYTE PTR [rbx+r9]
	mov	r9d, esi
.no_schedule_core:
	xor	r9b, BYTE PTR [rcx]
	xor	r8b, BYTE PTR 1[rcx]
	inc	r10d
	add	rcx, 4
	xor	dl, BYTE PTR -2[rcx]
	xor	al, BYTE PTR -1[rcx]
	mov	BYTE PTR 12[rcx], r9b
	mov	BYTE PTR 13[rcx], r8b
	mov	BYTE PTR 14[rcx], dl
	mov	BYTE PTR 15[rcx], al
	cmp	r10d, 44
	jne	.expand_loop
	pop	rbx
	pop	rsi
	ret
	.def	AddRoundKey;	.scl	3;	.type	32;	.endef
AddRoundKey:
	movzx	ecx, cl
	xor	eax, eax
	sal	rcx, 4
	add	r8, rcx
.round_words_loop:
	lea	r9, [rdx+rax]
	lea	r10, [rax+r8]
	xor	ecx, ecx
.round_bytes_xor:
	mov	r11b, BYTE PTR [r10+rcx]
	inc	rcx
	xor	BYTE PTR [r9], r11b
	inc	r9
	cmp	rcx, 4
	jne	.round_bytes_xor
	add	rax, 4
	cmp	rax, 16
	jne	.round_words_loop
	ret
	.def	xtime;	.scl	3;	.type	32;	.endef
xtime:
	mov	eax, ecx
	add	ecx, ecx
	sar	al, 7
	and	eax, 27
	xor	eax, ecx
	ret
	.def	Cipher;	.scl	3;	.type	32;	.endef
Cipher:
	push	r15
	mov	r8, rdx
	push	r14
	push	r13
	mov	r13d, 1
	push	r12
	push	rbp
	lea	rbp, sbox[rip]
	push	rdi
	push	rsi
	mov	rsi, rdx
	mov	rdx, rcx
	push	rbx
	mov	rbx, rcx
	xor	ecx, ecx
	lea	rdi, 4[rbx]
	lea	r12, 16[rbx]
	sub	rsp, 40
	call	AddRoundKey
.round_loop:
	mov	rdx, rbx
	mov	rcx, rbx
.subbytes_outer:
	mov	rax, rcx
	xor	r8d, r8d
.subbytes_inner:
	movzx	r9d, BYTE PTR [rax]
	inc	r8d
	add	rax, 4
	mov	r9b, BYTE PTR 0[rbp+r9]
	mov	BYTE PTR -4[rax], r9b
	cmp	r8b, 4
	jne	.subbytes_inner
	inc	rcx
	cmp	rdi, rcx
	jne	.subbytes_outer
	mov	cl, BYTE PTR 5[rbx]
	mov	al, BYTE PTR 1[rbx]
	mov	BYTE PTR 1[rbx], cl
	mov	cl, BYTE PTR 9[rbx]
	mov	BYTE PTR 5[rbx], cl
	mov	cl, BYTE PTR 13[rbx]
	mov	BYTE PTR 13[rbx], al
	mov	al, BYTE PTR 2[rbx]
	mov	BYTE PTR 9[rbx], cl
	mov	cl, BYTE PTR 10[rbx]
	mov	BYTE PTR 10[rbx], al
	mov	al, BYTE PTR 6[rbx]
	mov	BYTE PTR 2[rbx], cl
	mov	cl, BYTE PTR 14[rbx]
	mov	BYTE PTR 14[rbx], al
	mov	al, BYTE PTR 3[rbx]
	mov	BYTE PTR 6[rbx], cl
	mov	cl, BYTE PTR 15[rbx]
	mov	BYTE PTR 3[rbx], cl
	mov	cl, BYTE PTR 11[rbx]
	mov	BYTE PTR 15[rbx], cl
	mov	cl, BYTE PTR 7[rbx]
	mov	BYTE PTR 7[rbx], al
	mov	BYTE PTR 11[rbx], cl
	cmp	r13d, 10
	je	.final_round
.mix_columns_loop:
	mov	r9b, BYTE PTR [rdx]
	mov	r14b, BYTE PTR 1[rdx]
	add	rdx, 4
	mov	r11b, BYTE PTR -2[rdx]
	mov	r8b, BYTE PTR -1[rdx]
	mov	ecx, r9d
	xor	ecx, r14d
	mov	r15d, r11d
	mov	r10d, ecx
	movzx	ecx, cl
	xor	r15d, r8d
	call	xtime
	xor	r10d, r15d
	mov	ecx, r14d
	xor	eax, r9d
	xor	ecx, r11d
	xor	r9d, r8d
	xor	eax, r10d
	movzx	ecx, cl
	mov	BYTE PTR -4[rdx], al
	call	xtime
	movzx	ecx, r15b
	xor	r14d, eax
	xor	r14d, r10d
	mov	BYTE PTR -3[rdx], r14b
	call	xtime
	movzx	ecx, r9b
	xor	r11d, eax
	xor	r11d, r10d
	mov	BYTE PTR -2[rdx], r11b
	call	xtime
	xor	r8d, eax
	xor	r8d, r10d
	mov	BYTE PTR -1[rdx], r8b
	cmp	r12, rdx
	jne	.mix_columns_loop
	mov	ecx, r13d
	mov	r8, rsi
	mov	rdx, rbx
	inc	r13d
	call	AddRoundKey
	jmp	.round_loop
.final_round:
	add	rsp, 40
	mov	r8, rsi
	mov	rdx, rbx
	mov	ecx, 10
	pop	rbx
	pop	rsi
	pop	rdi
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	jmp	AddRoundKey
	.def	InvCipher;	.scl	3;	.type	32;	.endef
InvCipher:
	push	r15
	mov	r8, rdx
	push	r14
	push	r13
	push	r12
	mov	r12d, 9
	push	rbp
	push	rdi
	push	rsi
	push	rbx
	mov	rbx, rcx
	sub	rsp, 72
	mov	QWORD PTR 152[rsp], rdx
	mov	rdx, rcx
	mov	ecx, 10
	call	AddRoundKey
	lea	rax, 4[rbx]
	mov	QWORD PTR 48[rsp], rax
	lea	rax, 16[rbx]
	mov	QWORD PTR 56[rsp], rax
.inv_round_loop:
	mov	dl, BYTE PTR 9[rbx]
	mov	al, BYTE PTR 13[rbx]
	mov	rsi, rbx
	mov	BYTE PTR 13[rbx], dl
	mov	dl, BYTE PTR 5[rbx]
	mov	BYTE PTR 9[rbx], dl
	mov	dl, BYTE PTR 1[rbx]
	mov	BYTE PTR 1[rbx], al
	mov	al, BYTE PTR 2[rbx]
	mov	BYTE PTR 5[rbx], dl
	mov	dl, BYTE PTR 10[rbx]
	mov	BYTE PTR 10[rbx], al
	mov	al, BYTE PTR 6[rbx]
	mov	BYTE PTR 2[rbx], dl
	mov	dl, BYTE PTR 14[rbx]
	mov	BYTE PTR 14[rbx], al
	mov	al, BYTE PTR 3[rbx]
	mov	BYTE PTR 6[rbx], dl
	mov	dl, BYTE PTR 7[rbx]
	mov	BYTE PTR 3[rbx], dl
	mov	dl, BYTE PTR 11[rbx]
	mov	BYTE PTR 7[rbx], dl
	mov	dl, BYTE PTR 15[rbx]
	mov	BYTE PTR 15[rbx], al
	mov	BYTE PTR 11[rbx], dl
	mov	rdx, rbx
.inv_subbytes_outer:
	mov	rax, rdx
	xor	ecx, ecx
.inv_subbytes_inner:
	movzx	r8d, BYTE PTR [rax]
	lea	rdi, rsbox[rip]
	inc	ecx
	add	rax, 4
	mov	r8b, BYTE PTR [rdi+r8]
	mov	BYTE PTR -4[rax], r8b
	cmp	cl, 4
	jne	.inv_subbytes_inner
	inc	rdx
	cmp	QWORD PTR 48[rsp], rdx
	jne	.inv_subbytes_outer
	mov	r8, QWORD PTR 152[rsp]
	mov	rdx, rbx
	mov	ecx, r12d
	call	AddRoundKey
	test	r12d, r12d
	je	.inv_final_round
.inv_mix_columns_loop:
	movzx	ecx, BYTE PTR [rsi]
	mov	r9b, BYTE PTR 1[rsi]
	mov	r8b, BYTE PTR 2[rsi]
	mov	bpl, BYTE PTR 3[rsi]
	mov	r10d, ecx
	call	xtime
	movzx	ecx, al
	mov	BYTE PTR 43[rsp], al
	call	xtime
	movzx	ecx, al
	mov	BYTE PTR 44[rsp], al
	call	xtime
	movzx	ecx, r9b
	mov	edx, eax
	call	xtime
	movzx	ecx, al
	mov	BYTE PTR 45[rsp], al
	call	xtime
	movzx	ecx, al
	mov	BYTE PTR 46[rsp], al
	call	xtime
	movzx	ecx, r8b
	mov	edi, eax
	call	xtime
	movzx	ecx, al
	mov	r15d, ecx
	call	xtime
	movzx	ecx, al
	mov	r14d, ecx
	call	xtime
	movzx	ecx, bpl
	mov	r11d, eax
	call	xtime
	movzx	ecx, al
	mov	r13d, ecx
	call	xtime
	movzx	ecx, al
	mov	BYTE PTR 47[rsp], al
	call	xtime
	mov	ecx, eax
	mov	al, BYTE PTR 43[rsp]
	xor	eax, DWORD PTR 44[rsp]
	xor	eax, edx
	xor	al, BYTE PTR 45[rsp]
	xor	eax, edi
	xor	eax, r14d
	xor	eax, r11d
	xor	eax, ecx
	xor	eax, r9d
	xor	eax, r8d
	xor	eax, ebp
	mov	BYTE PTR [rsi], al
	mov	al, BYTE PTR 45[rsp]
	xor	eax, edx
	xor	al, BYTE PTR 46[rsp]
	xor	eax, edi
	xor	eax, r15d
	xor	eax, r11d
	xor	al, BYTE PTR 47[rsp]
	xor	eax, ecx
	xor	eax, r10d
	xor	eax, r8d
	xor	eax, ebp
	mov	BYTE PTR 1[rsi], al
	mov	al, BYTE PTR 44[rsp]
	xor	eax, edx
	add	rsi, 4
	xor	eax, edi
	xor	eax, r15d
	xor	eax, r14d
	xor	eax, r11d
	xor	eax, r13d
	xor	eax, ecx
	xor	eax, r10d
	xor	eax, r9d
	xor	eax, ebp
	mov	BYTE PTR -2[rsi], al
	mov	al, BYTE PTR 43[rsp]
	xor	eax, edx
	xor	al, BYTE PTR 46[rsp]
	xor	eax, edi
	xor	eax, r11d
	xor	eax, r13d
	xor	al, BYTE PTR 47[rsp]
	xor	eax, ecx
	xor	eax, r10d
	xor	eax, r9d
	xor	eax, r8d
	mov	BYTE PTR -1[rsi], al
	cmp	QWORD PTR 56[rsp], rsi
	jne	.inv_mix_columns_loop
	dec	r12d
	jmp	.inv_round_loop
.inv_final_round:
	add	rsp, 72
	pop	rbx
	pop	rsi
	pop	rdi
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	ret
	.globl	AES_init_ctx
	.def	AES_init_ctx;	.scl	2;	.type	32;	.endef
AES_init_ctx:
	jmp	KeyExpansion
	.globl	AES_init_ctx_iv
	.def	AES_init_ctx_iv;	.scl	2;	.type	32;	.endef
AES_init_ctx_iv:
	push	rbp
	mov	rbp, rsp
	push	rsi
	mov	rsi, r8
	push	rbx
	mov	rbx, rcx
	and	rsp, -16
	sub	rsp, 32
	call	KeyExpansion
	mov	rax, QWORD PTR [rsi]
	mov	rdx, QWORD PTR 8[rsi]
	mov	QWORD PTR 176[rbx], rax
	mov	QWORD PTR 184[rbx], rdx
	lea	rsp, -16[rbp]
	pop	rbx
	pop	rsi
	pop	rbp
	ret
	.globl	AES_ctx_set_iv
	.def	AES_ctx_set_iv;	.scl	2;	.type	32;	.endef
AES_ctx_set_iv:
	push	rbp
	movups	xmm0, XMMWORD PTR [rdx]
	mov	rbp, rsp
	and	rsp, -16
	movups	XMMWORD PTR 176[rcx], xmm0
	leave
	ret
	.globl	AES_ECB_encrypt
	.def	AES_ECB_encrypt;	.scl	2;	.type	32;	.endef
AES_ECB_encrypt:
	xchg	rdx, rcx
	jmp	Cipher
	.globl	AES_ECB_decrypt
	.def	AES_ECB_decrypt;	.scl	2;	.type	32;	.endef
AES_ECB_decrypt:
	xchg	rdx, rcx
	jmp	InvCipher
	.globl	AES_CBC_encrypt_buffer
	.def	AES_CBC_encrypt_buffer;	.scl	2;	.type	32;	.endef
AES_CBC_encrypt_buffer:
	push	rbp
	mov	rbp, rsp
	push	r13
	mov	r13, rdx
	push	r12
	mov	r12, r8
	push	rdi
	push	rsi
	xor	esi, esi
	push	rbx
	mov	rbx, rcx
	add	rcx, 176
	and	rsp, -16
	sub	rsp, 32
.cbc_encrypt_loop:
	cmp	rsi, r12
	jnb	.cbc_done
	lea	rdi, 0[r13+rsi]
	xor	eax, eax
.cbc_xor_iv:
	mov	dl, BYTE PTR [rcx+rax]
	xor	BYTE PTR [rdi+rax], dl
	inc	rax
	cmp	rax, 16
	jne	.cbc_xor_iv
	mov	rcx, rdi
	mov	rdx, rbx
	add	rsi, 16
	call	Cipher
	mov	rcx, rdi
	jmp	.cbc_encrypt_loop
.cbc_done:
	mov	rax, QWORD PTR [rcx]
	mov	rdx, QWORD PTR 8[rcx]
	mov	QWORD PTR 176[rbx], rax
	mov	QWORD PTR 184[rbx], rdx
	lea	rsp, -40[rbp]
	pop	rbx
	pop	rsi
	pop	rdi
	pop	r12
	pop	r13
	pop	rbp
	ret
	.globl	AES_CBC_decrypt_buffer
	.def	AES_CBC_decrypt_buffer;	.scl	2;	.type	32;	.endef
AES_CBC_decrypt_buffer:
	push	rbp
	mov	rbp, rsp
	push	r13
	push	r12
	mov	r12, r8
	push	rdi
	mov	rdi, rdx
	push	rsi
	mov	rsi, rcx
	push	rbx
	xor	ebx, ebx
	and	rsp, -16
	sub	rsp, 32
.cbc_decrypt_loop:
	cmp	rbx, r12
	jnb	.cbc_decrypt_done
	lea	r13, [rdi+rbx]
	mov	rdx, rsi
	movups	xmm0, XMMWORD PTR [rdi+rbx]
	mov	rcx, r13
	call	InvCipher
	xor	eax, eax
.cbc_decrypt_xor_iv:
	mov	dl, BYTE PTR 176[rsi+rax]
	xor	BYTE PTR 0[r13+rax], dl
	inc	rax
	cmp	rax, 16
	jne	.cbc_decrypt_xor_iv
	movups	XMMWORD PTR 176[rsi], xmm0
	add	rbx, 16
	jmp	.cbc_decrypt_loop
.cbc_decrypt_done:
	lea	rsp, -40[rbp]
	pop	rbx
	pop	rsi
	pop	rdi
	pop	r12
	pop	r13
	pop	rbp
	ret
	.globl	AES_CTR_xcrypt_buffer
	.def	AES_CTR_xcrypt_buffer;	.scl	2;	.type	32;	.endef
AES_CTR_xcrypt_buffer:
	push	rbp
	mov	eax, 16
	mov	rbp, rsp
	push	rdi
	lea	rdi, [rdx+r8]
	push	rsi
	mov	rsi, rcx
	push	rbx
	mov	rbx, rdx
	and	rsp, -16
	sub	rsp, 48
.ctr_loop:
	cmp	rbx, rdi
	je	.ctr_done
	cmp	eax, 16
	jne	.ctr_xor_keystream
	movups	xmm0, XMMWORD PTR 176[rsi]
	lea	rcx, 32[rsp]
	mov	rdx, rsi
	movups	XMMWORD PTR 32[rsp], xmm0
	call	Cipher
	mov	eax, 15
.ctr_increment_iv_loop:
	mov	dl, BYTE PTR 176[rsi+rax]
	cmp	dl, -1
	jne	.ctr_increment_byte
	mov	BYTE PTR 176[rsi+rax], 0
	sub	rax, 1
	jnb	.ctr_increment_iv_loop
	jmp	.ctr_increment_done
.ctr_increment_byte:
	cdqe
	inc	edx
	mov	BYTE PTR 176[rsi+rax], dl
.ctr_increment_done:
	xor	eax, eax
.ctr_xor_keystream:
	movsx	rdx, eax
	inc	eax
	mov	dl, BYTE PTR 32[rsp+rdx]
	xor	BYTE PTR [rbx], dl
	inc	rbx
	jmp	.ctr_loop
.ctr_done:
	lea	rsp, -24[rbp]
	pop	rbx
	pop	rsi
	pop	rdi
	pop	rbp
	ret
	.section .rdata,"dr"
	.align 8
Rcon:
	.ascii "\215\1\2\4\10\20 @\200\33"
	.ascii "6"
	.align 32
rsbox:
	.ascii "R\11j\325"
	.ascii "06\245"
	.ascii "8\277@\243\236\201\363\327\373|\343"
	.ascii "9\202\233/\377\207"
	.ascii "4\216CD\304\336\351\313T{\224"
	.ascii "2\246\302#=\356L\225\13B\372\303N\10.\241f(\331$\262v[\242Im\213\321%r\370\366d\206h\230\26\324\244\\\314]e\266\222lpHP\375\355\271\332^\25FW\247\215\235\204\220\330\253\0\214\274\323\12\367\344X\5\270\263E\6\320,\36\217\312?\17\2\301\257\275\3\1\23\212k:\221\21AOg\334\352\227\362\317\316\360\264\346s\226\254t\"\347\255"
	.ascii "5\205\342\371"
	.ascii "7\350\34u\337nG\361\32q\35)\305\211o\267b\16\252\30\276\33\374V>K\306\322y \232\333\300\376x\315Z\364\37\335\250"
	.ascii "3\210\7\307"
	.ascii "1\261\22\20Y'\200\354_`Q\177\251\31\265J\15-\345z\237\223\311\234\357\240\340;M\256*\365\260\310\353\273<\203S\231a\27+\4~\272w\326&\341i\24cU!\14}"
	.align 32
sbox:
	.ascii "c|w{\362ko\305"
	.ascii "0\1g+\376\327\253v\312\202\311}\372YG\360\255\324\242\257\234\244r\300\267\375\223&6?\367\314"
	.ascii "4\245\345\361q\330"
	.ascii "1\25\4\307#\303\30\226\5\232\7\22\200\342\353'\262u\11\203,\32\33nZ\240R;\326\263)\343/\204S\321\0\355 \374\261[j\313\276"
	.ascii "9JLX\317\320\357\252\373CM3\205E\371\2\177P<\237\250Q\243@\217\222\235"
	.ascii "8\365\274\266\332!\20\377\363\322\315\14\23\354_\227D\27\304\247~=d]\31s`\201O\334\"*\220\210F\356\270\24\336^\13\333\340"
	.ascii "2:\12I\6$\\\302\323\254b\221\225\344y\347\310"
	.ascii "7m\215\325N\251lV\364\352ez\256\10\272x%.\34\246\264\306\350\335t\37K\275\213\212p>\265fH\3\366\16a5W\271\206\301\35\236\341\370\230\21i\331\216\224\233\36\207\351\316U(\337\214\241\211\15\277\346BhA\231-\17\260T\273\26"
	.ident  "Libaes Build"
