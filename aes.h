/*
Abnormal General Software License v2 (ABGSLV2)
This Abnormal General Software License Version 2 ("License") is a legal agreement between the
original author ("Licensor") and the individual or entity using the software, source code, or executable binary licensed
under this agreement ("Licensee"). By using, modifying, or distributing the software,
Licensee agrees to abide by the terms set forth herein.
By using, modifying, or distributing the source code or executable binary, Licensee agrees to be bound by the terms of this Agreement.
https://xcn.abby0666.xyz/abgslv2.htm
*/
#ifndef AES_H
#define AES_H

#include <stdint.h>
#include <stddef.h>

#define AES_BLOCKLEN 16
#define AES_KEYLEN   16
#define AES_keyExpSize 176
typedef struct AES_ctx {
	uint8_t RoundKey[AES_keyExpSize];
	uint8_t Iv[AES_BLOCKLEN];
} AES_ctx;
#ifdef __cplusplus
extern "C" {
#endif

	void AES_init_ctx(AES_ctx* ctx, const uint8_t* key);
	void AES_init_ctx_iv(AES_ctx* ctx, const uint8_t* key, const uint8_t* iv);
	void AES_ctx_set_iv(AES_ctx* ctx, const uint8_t* iv);
	void AES_ECB_encrypt(AES_ctx* ctx, uint8_t* buf);
	void AES_ECB_decrypt(AES_ctx* ctx, uint8_t* buf);
	void AES_CBC_encrypt_buffer(AES_ctx* ctx, uint8_t* buf, size_t length);
	void AES_CBC_decrypt_buffer(AES_ctx* ctx, uint8_t* buf, size_t length);
	void AES_CTR_xcrypt_buffer(AES_ctx* ctx, uint8_t* buf, size_t length);

#ifdef __cplusplus
}
#endif

#endif /* AES_H */
