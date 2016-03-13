//
//  JWTAlgorithmHSBase.m
//  JWT
//
//  Created by Lobanov Dmitry on 13.03.16.
//  Copyright © 2016 Karma. All rights reserved.
//

#import "JWTAlgorithmHSBase.h"
#import <Base64/MF_Base64Additions.h>
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonHMAC.h>

@interface JWTAlgorithmHSBase ()

@property (assign, nonatomic, readwrite) size_t ccSHANumberDigestLength;
@property (assign, nonatomic, readwrite) uint32_t ccHmacAlgSHANumber;

@end

@implementation JWTAlgorithmHSBase

- (size_t)ccSHANumberDigestLength {
    return 0;
}

- (uint32_t)ccHmacAlgSHANumber {
    return 0;
}

- (NSString *)name;
{
    return @"HSBase";
}

- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret;
{
    const char *cString = [theString cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cSecret = [theSecret cStringUsingEncoding:NSUTF8StringEncoding];
    
    size_t amount = self.ccSHANumberDigestLength;
    size_t fullSize = amount * sizeof(unsigned char);
    unsigned char* cHMAC = malloc(fullSize);
    CCHmacAlgorithm ccAlg = self.ccHmacAlgSHANumber;

//    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(ccAlg, cSecret, strlen(cSecret), cString, strlen(cString), cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}

- (NSData *)encodePayloadData:(NSData *)theStringData withSecret:(NSData *)theSecretData
{
//    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    size_t amount = self.ccSHANumberDigestLength;
    size_t fullSize = amount * sizeof(unsigned char);
    unsigned char* cHMAC = malloc(fullSize);
    CCHmacAlgorithm ccAlg = self.ccHmacAlgSHANumber;
    
    CCHmac(ccAlg, theSecretData.bytes, [theSecretData length], theStringData.bytes, [theStringData length], cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}

- (BOOL)verifySignedInput:(NSString *)input withSignature:(NSString *)signature verificationKey:(NSString *)verificationKey
{
    NSString *expectedSignature = [[self encodePayload:input withSecret:verificationKey] base64UrlEncodedString];
    
    return [expectedSignature isEqualToString:signature];
}

- (BOOL)verifySignedInput:(NSString *)input withSignature:(NSString *)signature verificationKeyData:(NSData *)verificationKeyData {
    const char *cString = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *inputData = [NSData dataWithBytes:cString length:strlen(cString)];
    
    NSString *expectedSignature = [[self encodePayloadData:inputData withSecret:verificationKeyData] base64UrlEncodedString];
    
    return [expectedSignature isEqualToString:signature];
}

+ (instancetype)algorithm256 {
    JWTAlgorithmHSBase *base = [JWTAlgorithmHSBase new];
    base.ccSHANumberDigestLength = CC_SHA256_DIGEST_LENGTH;
    base.ccHmacAlgSHANumber = kCCHmacAlgSHA256;
    return base;
}

+ (instancetype)algorithm384 {
    JWTAlgorithmHSBase *base = [JWTAlgorithmHSBase new];
    base.ccSHANumberDigestLength = CC_SHA384_DIGEST_LENGTH;
    base.ccHmacAlgSHANumber = kCCHmacAlgSHA384;
    return base;
}

+ (instancetype)algorithm512 {
    JWTAlgorithmHSBase *base = [JWTAlgorithmHSBase new];
    base.ccSHANumberDigestLength = CC_SHA512_DIGEST_LENGTH;
    base.ccHmacAlgSHANumber = kCCHmacAlgSHA512;
    return base;
}

@end
