//
//  JWTAlgorithmHSBase.m
//  JWT
//
//  Created by Lobanov Dmitry on 13.03.16.
//  Copyright © 2016 Karma. All rights reserved.
//

#import "JWTAlgorithmHSBase.h"
#import "JWTBase64Coder.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonHMAC.h>

NSString *const JWTAlgorithmNameHS256 = @"HS256";
NSString *const JWTAlgorithmNameHS384 = @"HS384";
NSString *const JWTAlgorithmNameHS512 = @"HS512";

@interface JWTAlgorithmHSBase () @end

@implementation JWTAlgorithmHSBase

- (size_t)ccSHANumberDigestLength {
    @throw [[NSException alloc] initWithName:NSInternalInconsistencyException reason:@"ccSHANumberDigestLength property should be overriden" userInfo:nil];
}

- (uint32_t)ccHmacAlgSHANumber {
    @throw [[NSException alloc] initWithName:NSInternalInconsistencyException reason:@"ccHmacAlgSHANumber property should be overriden" userInfo:nil];
}

- (NSData *)signHash:(NSData *)hash key:(NSData *)key error:(NSError *__autoreleasing *)error {
    size_t amount = self.ccSHANumberDigestLength;
    size_t fullSize = amount * sizeof(unsigned char);
    unsigned char* cHMAC = malloc(fullSize);
    CCHmacAlgorithm ccAlg = self.ccHmacAlgSHANumber;
    
    CCHmac(ccAlg, key.bytes, key.length, hash.bytes, hash.length, cHMAC);
    
    NSData *result = [[NSData alloc] initWithBytes:cHMAC length:fullSize];
    free(cHMAC);
    return result;
}

- (BOOL)verifyHash:(NSData *)hash signature:(NSData *)signature key:(NSData *)key error:(NSError *__autoreleasing *)error {
    NSData *expectedSignatureData = [self signHash:hash key:key error:error];
    return [expectedSignatureData isEqualToData:signature];
}

- (NSString *)name {
    return @"HSBase";
}


@end

@interface JWTAlgorithmHSFamilyMember : JWTAlgorithmHSBase @end
@implementation JWTAlgorithmHSFamilyMember @end

@interface JWTAlgorithmHS256 : JWTAlgorithmHSBase @end
@interface JWTAlgorithmHS384 : JWTAlgorithmHSBase @end
@interface JWTAlgorithmHS512 : JWTAlgorithmHSBase @end

@implementation JWTAlgorithmHS256

- (size_t)ccSHANumberDigestLength {
    return CC_SHA256_DIGEST_LENGTH;
}

- (uint32_t)ccHmacAlgSHANumber {
    return kCCHmacAlgSHA256;
}

- (NSString *)name {
    return @"HS256";
}

@end

@implementation JWTAlgorithmHS384

- (size_t)ccSHANumberDigestLength {
    return CC_SHA384_DIGEST_LENGTH;
}

- (uint32_t)ccHmacAlgSHANumber {
    return kCCHmacAlgSHA384;
}

- (NSString *)name {
    return @"HS384";
}

@end

@implementation JWTAlgorithmHS512

- (size_t)ccSHANumberDigestLength {
    return CC_SHA512_DIGEST_LENGTH;
}

- (uint32_t)ccHmacAlgSHANumber {
    return kCCHmacAlgSHA512;
}

- (NSString *)name {
    return @"HS512";
}

@end

@interface JWTAlgorithmHSFamilyMemberMutable : JWTAlgorithmHSFamilyMember
@property (assign, nonatomic, readwrite) size_t ccSHANumberDigestLength;
@property (assign, nonatomic, readwrite) uint32_t ccHmacAlgSHANumber;
@property (copy, nonatomic, readwrite) NSString *name;
@end

@implementation JWTAlgorithmHSFamilyMemberMutable

@synthesize ccSHANumberDigestLength = _ccSHANumberDigestLength;
@synthesize ccHmacAlgSHANumber = _ccHmacAlgSHANumber;
@synthesize name = _name;

- (size_t)ccSHANumberDigestLength {
    return _ccSHANumberDigestLength;
}

- (uint32_t)ccHmacAlgSHANumber {
    return _ccHmacAlgSHANumber;
}

@end

@implementation JWTAlgorithmHSBase (Create)

+ (instancetype)algorithm256 {
    return [JWTAlgorithmHS256 new];
}

+ (instancetype)algorithm384 {
    return [JWTAlgorithmHS384 new];
}

+ (instancetype)algorithm512 {
    return [JWTAlgorithmHS512 new];
}

@end
