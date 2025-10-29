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
    .byte 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36
    .align 32

# === AES inverse S-box (rsbox) ===
rsbox:
    .byte 0x52,0x09,0x6A,0xD5,0x30,0x36,0xA5,0x38,0xBF,0x40,0xA3,0x9E,0x81,0xF3,0xD7,0xFB
    .byte 0x7C,0xE3,0x39,0x82,0x9B,0x2F,0xFF,0x87,0x34,0x8E,0x43,0x44,0xC4,0xDE,0xE9,0xCB
    .byte 0x54,0x7B,0x94,0x32,0xA6,0xC2,0x23,0x3D,0xEE,0x4C,0x95,0x0B,0x42,0xFA,0xC3,0x4E
    .byte 0x08,0x2E,0xA1,0x66,0x28,0xD9,0x24,0xB2,0x76,0x5B,0xA2,0x49,0x6D,0x8B,0xD1,0x25
    .byte 0x72,0xF8,0xF6,0x64,0x86,0x68,0x98,0x16,0xD4,0xA4,0x5C,0xCC,0x5D,0x65,0xB6,0x92
    .byte 0x6C,0x70,0x48,0x50,0xFD,0xED,0xB9,0xDA,0x5E,0x15,0x46,0x57,0xA7,0x8D,0x9D,0x84
    .byte 0x90,0xD8,0xAB,0x00,0x8C,0xBC,0xD3,0x0A,0xF7,0xE4,0x58,0x05,0xB8,0xB3,0x45,0x06
    .byte 0xD0,0x2C,0x1E,0x8F,0xCA,0x3F,0x0F,0x02,0xC1,0xAF,0xBD,0x03,0x01,0x13,0x8A,0x6B
    .byte 0x3A,0x91,0x11,0x41,0x4F,0x67,0xDC,0xEA,0x97,0xF2,0xCF,0xCE,0xF0,0xB4,0xE6,0x73
    .byte 0x96,0xAC,0x74,0x22,0xE7,0xAD,0x35,0x85,0xE2,0xF9,0x37,0xE8,0x1C,0x75,0xDF,0x6E
    .byte 0x47,0xF1,0x1A,0x71,0x1D,0x29,0xC5,0x89,0x6F,0xB7,0x62,0x0E,0xAA,0x18,0xBE,0x1B
    .byte 0xFC,0x56,0x3E,0x4B,0xC6,0xD2,0x79,0x20,0x9A,0xDB,0xC0,0xFE,0x78,0xCD,0x5A,0xF4
    .byte 0x1F,0xDD,0xA8,0x33,0x88,0x07,0xC7,0x31,0xB1,0x12,0x10,0x59,0x27,0x80,0xEC,0x5F
    .byte 0x60,0x51,0x7F,0xA9,0x19,0xB5,0x4A,0x0D,0x2D,0xE5,0x7A,0x9F,0x93,0xC9,0x9C,0xEF
    .byte 0xA0,0xE0,0x3B,0x4D,0xAE,0x2A,0xF5,0xB0,0xC8,0xEB,0xBB,0x3C,0x83,0x53,0x99,0x61
    .byte 0x17,0x2B,0x04,0x7E,0xBA,0x77,0xD6,0x26,0xE1,0x69,0x14,0x63,0x55,0x21,0x0C,0x7D
    .align 32

# === AES forward S-box (sbox) ===
sbox:
    .byte 0x63,0x7C,0x77,0x7B,0xF2,0x6B,0x6F,0xC5,0x30,0x01,0x67,0x2B,0xFE,0xD7,0xAB,0x76
    .byte 0xCA,0x82,0xC9,0x7D,0xFA,0x59,0x47,0xF0,0xAD,0xD4,0xA2,0xAF,0x9C,0xA4,0x72,0xC0
    .byte 0xB7,0xFD,0x93,0x26,0x36,0x3F,0xF7,0xCC,0x34,0xA5,0xE5,0xF1,0x71,0xD8,0x31,0x15
    .byte 0x04,0xC7,0x23,0xC3,0x18,0x96,0x05,0x9A,0x07,0x12,0x80,0xE2,0xEB,0x27,0xB2,0x75
    .byte 0x09,0x83,0x2C,0x1A,0x1B,0x6E,0x5A,0xA0,0x52,0x3B,0xD6,0xB3,0x29,0xE3,0x2F,0x84
    .byte 0x53,0xD1,0x00,0xED,0x20,0xFC,0xB1,0x5B,0x6A,0xCB,0xBE,0x39,0x4A,0x4C,0x58,0xCF
    .byte 0xD0,0xEF,0xAA,0xFB,0x43,0x4D,0x33,0x85,0x45,0xF9,0x02,0x7F,0x50,0x3C,0x9F,0xA8
    .byte 0x51,0xA3,0x40,0x8F,0x92,0x9D,0x38,0xF5,0xBC,0xB6,0xDA,0x21,0x10,0xFF,0xF3,0xD2
    .byte 0xCD,0x0C,0x13,0xEC,0x5F,0x97,0x44,0x17,0xC4,0xA7,0x7E,0x3D,0x64,0x5D,0x19,0x73
    .byte 0x60,0x81,0x4F,0xDC,0x22,0x2A,0x90,0x88,0x46,0xEE,0xB8,0x14,0xDE,0x5E,0x0B,0xDB
    .byte 0xE0,0x32,0x3A,0x0A,0x49,0x06,0x24,0x5C,0xC2,0xD3,0xAC,0x62,0x91,0x95,0xE4,0x79
    .byte 0xE7,0xC8,0x37,0x6D,0x8D,0xD5,0x4E,0xA9,0x6C,0x56,0xF4,0xEA,0x65,0x7A,0xAE,0x08
    .byte 0xBA,0x78,0x25,0x2E,0x1C,0xA6,0xB4,0xC6,0xE8,0xDD,0x74,0x1F,0x4B,0xBD,0x8B,0x8A
    .byte 0x70,0x3E,0xB5,0x66,0x48,0x03,0xF6,0x0E,0x61,0x35,0x57,0xB9,0x86,0xC1,0x1D,0x9E
    .byte 0xE1,0xF8,0x98,0x11,0x69,0xD9,0x8E,0x94,0x9B,0x1E,0x87,0xE9,0xCE,0x55,0x28,0xDF
    .byte 0x8C,0xA1,0x89,0x0D,0xBF,0xE6,0x42,0x68,0x41,0x99,0x2D,0x0F,0xB0,0x54,0xBB,0x16
    .align 32

	.ident  "Libaes Build"
