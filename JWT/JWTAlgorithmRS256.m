//
//  JWTAlgorithmRS256.m
//  JWT
//
//  Created by Hernan Zalazar on 10/23/14.
//  Copyright (c) 2014 Karma. All rights reserved.
//

#import "JWTAlgorithmRS256.h"

#import <CommonCrypto/CommonDigest.h>

@implementation JWTAlgorithmRS256

- (NSString *)name {
    return @"RS256";
}

- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret {
    SecKeyRef privateKeyRef = [self privateKeyRefWithTag:theSecret];
    NSData *signedHash;
    if (privateKeyRef) {
        size_t signatureSize = SecKeyGetBlockSize(privateKeyRef);
        uint8_t *signatureBytes = malloc(signatureSize * sizeof(uint8_t));
        memset(signatureBytes, 0x0, signatureSize);
        NSData *hashedJWT = [self hashValue:theString];
        OSStatus status = SecKeyRawSign(privateKeyRef, kSecPaddingPKCS1SHA256, [hashedJWT bytes], CC_SHA256_DIGEST_LENGTH, signatureBytes, &signatureSize);
        if (status == errSecSuccess) {
            signedHash = [NSData dataWithBytes:signatureBytes length:signatureSize];
        }
        CFRelease(privateKeyRef);
        if (signatureBytes) {
            free(signatureBytes);
        }
    }
    return signedHash;
}

- (SecKeyRef)privateKeyRefWithTag:(NSString *)tag {
    NSDictionary *query = @{
                            (__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
                            (__bridge id)kSecReturnRef: @YES,
                            (__bridge id)kSecAttrApplicationTag: tag,
                            };
    SecKeyRef privateKeyRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&privateKeyRef);
    if (status != errSecSuccess) {
        return NULL;
    }
    return privateKeyRef;
}

- (NSData *)hashValue:(NSString *)value {
    CC_SHA256_CTX ctx;

    uint8_t * hashBytes = malloc(CC_SHA256_DIGEST_LENGTH * sizeof(uint8_t));
    memset(hashBytes, 0x0, CC_SHA256_DIGEST_LENGTH);

    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];

    CC_SHA256_Init(&ctx);
    CC_SHA256_Update(&ctx, [valueData bytes], (CC_LONG)[valueData length]);
    CC_SHA256_Final(hashBytes, &ctx);

    NSData *hash = [NSData dataWithBytes:hashBytes length:CC_SHA256_DIGEST_LENGTH];

    if (hashBytes) {
        free(hashBytes);
    }

    return hash;
}

@end
