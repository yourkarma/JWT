//
//  JWTAlgorithmRSBase.m
//  JWT
//
//  Created by Lobanov Dmitry on 13.03.16.
//  Copyright © 2016 Karma. All rights reserved.
//

#import "JWTAlgorithmRSBase.h"
#import "MF_Base64Additions.h"
#import <CommonCrypto/CommonCrypto.h>

@interface JWTAlgorithmRSBase()

@end


@implementation JWTAlgorithmRSBase

@synthesize privateKeyCertificatePassphrase;

- (size_t)ccSHANumberDigestLength {
    return 0;
}

- (uint32_t)secPaddingPKCS1SHANumber {
    return 0;
}

#pragma mark - JWTAlgorithm

- (unsigned char *)CC_SHANumberWithData:(const void *)data withLength:(CC_LONG)len withHashBytes:(unsigned char *)hashBytes {
    return nil;
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
        return [self PKCSSignBytesSHANumberwithRSA:theStringData withPrivateKey:privateKey];
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
    BOOL signatureOk = [self PKCSVerifyBytesSHANumberWithRSA:signedData witSignature:signatureData withPublicKey:publicKey];
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

- (BOOL)PKCSVerifyBytesSHANumberWithRSA:(NSData *)plainData witSignature:(NSData *)signature withPublicKey:(SecKeyRef) publicKey {
    size_t signedHashBytesSize = SecKeyGetBlockSize(publicKey);
    const void* signedHashBytes = [signature bytes];

    size_t hashBytesSize = self.ccSHANumberDigestLength;
    uint8_t* hashBytes = malloc(hashBytesSize);

    OSStatus status = SecKeyRawVerify(publicKey,
        self.secPaddingPKCS1SHANumber,
        hashBytes,
        hashBytesSize,
        signedHashBytes,
        signedHashBytesSize);

    return status == errSecSuccess;
}

- (NSData *)PKCSSignBytesSHANumberwithRSA:(NSData *)plainData withPrivateKey:(SecKeyRef)privateKey {
    size_t signedHashBytesSize = SecKeyGetBlockSize(privateKey);
    uint8_t* signedHashBytes = malloc(signedHashBytesSize);
    memset(signedHashBytes, 0x0, signedHashBytesSize);

    size_t hashBytesSize = self.ccSHANumberDigestLength;
    uint8_t* hashBytes = malloc(hashBytesSize);

    // ([plainData bytes], (CC_LONG)[plainData length], hashBytes)
    unsigned char *str = [self CC_SHANumberWithData:[plainData bytes] withLength:(CC_LONG)[plainData length] withHashBytes:hashBytes];
    
    if (!str) {
        return nil;
    }

    SecKeyRawSign(privateKey,
            self.secPaddingPKCS1SHANumber,
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

@interface JWTAlgorithmRSBaseTest : JWTAlgorithmRSBase
@property (assign, nonatomic, readwrite) size_t ccSHANumberDigestLength;
@property (assign, nonatomic, readwrite) uint32_t secPaddingPKCS1SHANumber;
@property (assign, nonatomic, readwrite) unsigned char * (^ccShaNumberWithData)(const void *data, CC_LONG len, unsigned char *hashBytes);
@end

@implementation JWTAlgorithmRSBaseTest

@synthesize ccSHANumberDigestLength = _ccSHANumberDigestLength;
@synthesize secPaddingPKCS1SHANumber = _secPaddingPKCS1SHANumber;

- (size_t)ccSHANumberDigestLength {
    return _ccSHANumberDigestLength;
}

- (uint32_t)secPaddingPKCS1SHANumber {
    return _secPaddingPKCS1SHANumber;
}

- (unsigned char *)CC_SHANumberWithData:(const void *)data withLength:(uint32_t)len withHashBytes:(unsigned char *)hashBytes {
    unsigned char *result = [super CC_SHANumberWithData:data withLength:len withHashBytes:hashBytes];
    if (!result && self.ccShaNumberWithData) {
        result = self.ccShaNumberWithData(data, len, hashBytes);
    }
    return result;
}

@end

@implementation JWTAlgorithmRSBase (Create)

+ (instancetype)algorithm256 {
    JWTAlgorithmRSBaseTest *base = [JWTAlgorithmRSBaseTest new];
    base.ccSHANumberDigestLength = CC_SHA256_DIGEST_LENGTH;
    base.secPaddingPKCS1SHANumber = kSecPaddingPKCS1SHA256;
    base.ccShaNumberWithData = ^unsigned char *(const void *data, CC_LONG len, unsigned char *hashBytes){
        return CC_SHA256(data, len, hashBytes);
    };
    return base;
}

+ (instancetype)algorithm384 {
    JWTAlgorithmRSBaseTest *base = [JWTAlgorithmRSBaseTest new];
    base.ccSHANumberDigestLength = CC_SHA384_DIGEST_LENGTH;
    base.secPaddingPKCS1SHANumber = kSecPaddingPKCS1SHA384;
    base.ccShaNumberWithData = ^unsigned char *(const void *data, CC_LONG len, unsigned char *hashBytes){
        return CC_SHA384(data, len, hashBytes);
    };
    return base;
}

+ (instancetype)algorithm512 {
    JWTAlgorithmRSBaseTest *base = [JWTAlgorithmRSBaseTest new];
    base.ccSHANumberDigestLength = CC_SHA512_DIGEST_LENGTH;
    base.secPaddingPKCS1SHANumber = kSecPaddingPKCS1SHA512;
    base.ccShaNumberWithData = ^unsigned char *(const void *data, CC_LONG len, unsigned char *hashBytes){
        return CC_SHA512(data, len, hashBytes);
    };
    return base;
}

@end