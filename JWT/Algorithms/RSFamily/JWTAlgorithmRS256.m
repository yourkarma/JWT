//
//  JWTAlgorithmRS256.m
//  JWT
//
//  Created by Lobanov Dmitry on 17.11.15.
//  Copyright © 2015 Karma. All rights reserved.
//

#import "JWTAlgorithmRS256.h"
#import "MF_Base64Additions.h"
#import <CommonCrypto/CommonCrypto.h>

@interface JWTAlgorithmRS256()

@property (assign, nonatomic, readonly) NSNumber *CC_SHA_DIGEST_LENGTH;
@property (assign, nonatomic, readonly) NSNumber *kSecPaddingPKCS1SHANumber;

@end

@implementation JWTAlgorithmRS256

@synthesize privateKeyCertificatePassphrase;

#pragma mark - JWTAlgorithm

- (NSNumber *)CC_SHA_DIGEST_LENGTH {
    return @(CC_SHA256_DIGEST_LENGTH);
}

- (NSNumber *)kSecPaddingPKCS1SHANumber {
    return @(kSecPaddingPKCS1SHA256);
}

- (BOOL)CC_SHANumberWithData:(const void *)data withLength:(CC_LONG)len withHashBytes:(unsigned char *)hashBytes {
    return CC_SHA256(data, len, hashBytes);
}

- (NSString *)name {
  return @"RS256";
}

- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret {
    return [self encodePayloadData:[theString dataUsingEncoding:NSUTF8StringEncoding] withSecret:[NSData dataWithBase64UrlEncodedString:theSecret]];
}

- (NSData *)encodePayloadData:(NSData *)theStringData withSecret:(NSData *)theSecretData {
    SecIdentityRef identity = nil;
    SecTrustRef trust = nil;
    extractIdentityAndTrust((__bridge CFDataRef)theSecretData, &identity, &trust, (__bridge CFStringRef) self.privateKeyCertificatePassphrase);
    if (identity && trust) {
        SecKeyRef privateKey;
        SecIdentityCopyPrivateKey(identity, &privateKey);
        return PKCSSignBytesSHA256withRSA(theStringData, privateKey);
    } else {
        return nil;
    }
}

- (BOOL)verifySignedInput:(NSString *)input withSignature:(NSString *)signature verificationKey:(NSString *)verificationKey {
    NSData *certificateData = [NSData dataWithBase64String:verificationKey];
    return [self verifySignedInput:input
                     withSignature:signature
               verificationKeyData:certificateData];
}

- (BOOL)verifySignedInput:(NSString *)input withSignature:(NSString *)signature verificationKeyData:(NSData *)verificationKeyData {
    NSData *signedData = [input dataUsingEncoding:NSUTF8StringEncoding];
    NSData *signatureData = [NSData dataWithBase64UrlEncodedString:signature];
    SecKeyRef publicKey = [self publicKeyFromCertificate:verificationKeyData];
    BOOL signatureOk = PKCSVerifyBytesSHA256withRSA(signedData, signatureData, publicKey);
    return signatureOk;
}

#pragma mark - Private

- (SecKeyRef)publicKeyFromCertificate:(NSData *)certificateData {
    SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData);
    SecPolicyRef secPolicy = SecPolicyCreateBasicX509();
    SecTrustRef trust;
    SecTrustCreateWithCertificates(certificate, secPolicy, &trust);
    SecTrustResultType resultType;
    SecTrustEvaluate(trust, &resultType);
    SecKeyRef publicKey = SecTrustCopyPublicKey(trust);
    return publicKey;
}

- (BOOL)PKCSVerifyBytesSHANumberWithRSA(NSData* plainData, NSData* signature, SecKeyRef publicKey) {
    size_t signedHashBytesSize = SecKeyGetBlockSize(publicKey);
    const void* signedHashBytes = [signature bytes];

    size_t hashBytesSize = self.CC_SHA_DIGEST_LENGTH.integerValue;
    uint8_t* hashBytes = malloc(hashBytesSize);

    OSStatus status = SecKeyRawVerify(publicKey,
        self.kSecPaddingPKCS1SHANumber.integerValue,
        hashBytes,
        hashBytesSize,
        signedHashBytes,
        signedHashBytesSize);

    return status == errSecSuccess;
}

- (NSData *)PKCSSignBytesSHANumberwithRSA(NSData* plainData, SecKeyRef privateKey) {
    size_t signedHashBytesSize = SecKeyGetBlockSize(privateKey);
    uint8_t* signedHashBytes = malloc(signedHashBytesSize);
    memset(signedHashBytes, 0x0, signedHashBytesSize);

    size_t hashBytesSize = self.CC_SHA_DIGEST_LENGTH.integerValue;
    uint8_t* hashBytes = malloc(hashBytesSize);

    // ([plainData bytes], (CC_LONG)[plainData length], hashBytes)
    if (![self CC_SHANumberWithData:[plainData bytes] withLength:(CC_LONG)[plainData length] withHashBytes:hashBytes]) {
        return nil;
    }

    SecKeyRawSign(privateKey,
            self.kSecPaddingPKCS1SHANumber.integerValue,
            hashBytes,
            hashBytesSize,
            signedHashBytes,
            &signedHashBytesSize);

    NSData* signedHash = [NSData dataWithBytes:signedHashBytes
                                        length:(NSUInteger)signedHashBytesSize];

    if (hashBytes)
        free(hashBytes);
    if (signedHashBytes)
        free(signedHashBytes);

    return signedHash;
}

// BOOL PKCSVerifyBytesSHA256withRSA(NSData* plainData, NSData* signature, SecKeyRef publicKey) {
//     size_t signedHashBytesSize = SecKeyGetBlockSize(publicKey);
//     const void* signedHashBytes = [signature bytes];

//     size_t hashBytesSize = CC_SHA256_DIGEST_LENGTH;
//     uint8_t* hashBytes = malloc(hashBytesSize);
//     if (!CC_SHA256([plainData bytes], (CC_LONG)[plainData length], hashBytes)) {
//         return false;
//     }

//     OSStatus status = SecKeyRawVerify(publicKey,
//             kSecPaddingPKCS1SHA256,
//             hashBytes,
//             hashBytesSize,
//             signedHashBytes,
//             signedHashBytesSize);

//     return status == errSecSuccess;
// }

NSData* PKCSSignBytesSHA256withRSA(NSData* plainData, SecKeyRef privateKey) {
    size_t signedHashBytesSize = SecKeyGetBlockSize(privateKey);
    uint8_t* signedHashBytes = malloc(signedHashBytesSize);
    memset(signedHashBytes, 0x0, signedHashBytesSize);

    size_t hashBytesSize = CC_SHA256_DIGEST_LENGTH;
    uint8_t* hashBytes = malloc(hashBytesSize);
    if (!CC_SHA256([plainData bytes], (CC_LONG)[plainData length], hashBytes)) {
        return nil;
    }

    SecKeyRawSign(privateKey,
            kSecPaddingPKCS1SHA256,
            hashBytes,
            hashBytesSize,
            signedHashBytes,
            &signedHashBytesSize);

    NSData* signedHash = [NSData dataWithBytes:signedHashBytes
                                        length:(NSUInteger)signedHashBytesSize];

    if (hashBytes)
        free(hashBytes);
    if (signedHashBytes)
        free(signedHashBytes);

    return signedHash;
}

OSStatus extractIdentityAndTrust(CFDataRef inPKCS12Data,
        SecIdentityRef *outIdentity,
        SecTrustRef *outTrust,
        CFStringRef keyPassword) {
    OSStatus securityError = errSecSuccess;


    const void *keys[] =   { kSecImportExportPassphrase };
    const void *values[] = { keyPassword };
    CFDictionaryRef optionsDictionary = NULL;

    /* Create a dictionary containing the passphrase if one
       was specified.  Otherwise, create an empty dictionary. */
    optionsDictionary = CFDictionaryCreate(
            NULL, keys,
            values, (keyPassword ? 1 : 0),
            NULL, NULL);  // 1

    CFArrayRef items = NULL;
    securityError = SecPKCS12Import(inPKCS12Data,
            optionsDictionary,
            &items);                    // 2


    //
    if (securityError == 0) {                                   // 3
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (myIdentityAndTrust,
                kSecImportItemIdentity);
        CFRetain(tempIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);

        CFRetain(tempTrust);
        *outTrust = (SecTrustRef)tempTrust;
    }

    if (optionsDictionary)                                      // 4
        CFRelease(optionsDictionary);

    if (items)
        CFRelease(items);

    return securityError;
}

@end
