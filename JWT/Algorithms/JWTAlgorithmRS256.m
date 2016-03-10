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
#import <CommonCrypto/CommonHMAC.h>

@implementation JWTAlgorithmRS256

- (NSString *)name {
  return @"RS256";
}

- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret {
  return nil;
}

- (NSData *)encodePayloadData:(NSData *)theStringData withSecret:(NSData *)theSecretData
{
    return nil;
}

- (BOOL)verifySignedInput:(NSString *)input withSignature:(NSString *)signature verificationKey:(NSString *)verificationKey
{
    NSData *certificateData = [NSData dataWithBase64String:verificationKey];
    return [self verifySignedInput:input
                     withSignature:signature
               verificationKeyData:certificateData];
}

- (BOOL)verifySignedInput:(NSString *)input withSignature:(NSString *)signature verificationKeyData:(NSData *)verificationKeyData
{
    NSData *signatureVerificationInputData = [input dataUsingEncoding:NSUTF8StringEncoding];
    NSData *signatureData = [NSData dataWithBase64UrlEncodedString:signature];
    SecKeyRef publicKey = [self publicKeyFromCertificate:verificationKeyData];
    BOOL signatureOk = PKCSVerifyBytesSHA256withRSA(signatureVerificationInputData, signatureData, publicKey);
    return signatureOk;
}

#pragma mark - Private

BOOL PKCSVerifyBytesSHA256withRSA(NSData* plainData, NSData* signature, SecKeyRef publicKey) {
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    if (!CC_SHA256([plainData bytes], (CC_LONG)[plainData length], digest))
        return NO;

    uint8_t *signatureBytes = [signature bytes];
    size_t signatureLength = [signature length];
    OSStatus status = SecKeyRawVerify(publicKey,
            kSecPaddingPKCS1SHA256,
            digest,
            CC_SHA256_DIGEST_LENGTH,
            signatureBytes,
            signatureLength);
//    NSLog(@"status = %li", status);
    return status == errSecSuccess;
}

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

@end
