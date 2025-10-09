/*
Abnormal General Software License v2 (ABGSLV2)
This Abnormal General Software License Version 2 ("License") is a legal agreement between the
original author ("Licensor") and the individual or entity using the software, source code, or executable binary licensed
under this agreement ("Licensee"). By using, modifying, or distributing the software,
Licensee agrees to abide by the terms set forth herein.
By using, modifying, or distributing the source code or executable binary, Licensee agrees to be bound by the terms of this Agreement.
https://xcn.abby0666.xyz/abgslv2.htm
*/
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "aes.h"

int main() {
	uint8_t key[16]={
		0x2b,0x7e,0x15,0x16,
		0x28,0xae,0xd2,0xa6,
		0xab,0xf7,0x97,0x75,
		0x46,0x20,0x63,0x74
	};

	uint8_t plain[AES_BLOCKLEN]="HelloAES1234567";
	uint8_t buf[AES_BLOCKLEN];

	memcpy(buf, plain, AES_BLOCKLEN);

	struct AES_ctx ctx;
	AES_init_ctx(&ctx, key);

	AES_ECB_encrypt(&ctx, buf);

	printf("Ciphertext: ");
	for(int i=0;i<AES_BLOCKLEN;i++) {
		printf("%02x", buf[i]);
	}
	printf("\n");

	AES_ECB_decrypt(&ctx, buf);

	printf("Decrypted: %.*s\n", AES_BLOCKLEN, buf);

	return 0;
}
