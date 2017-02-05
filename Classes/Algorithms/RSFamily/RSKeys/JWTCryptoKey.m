//
//  JWTCryptoKey.m
//  JWT
//
//  Created by Lobanov Dmitry on 04.02.17.
//  Copyright © 2017 JWTIO. All rights reserved.
//

#import "JWTCryptoKey.h"
#import "JWTCryptoSecurity.h"
#import "JWTBase64Coder.h"
@interface JWTCryptoKey ()
@property (copy, nonatomic, readwrite) NSString *tag;
@property (assign, nonatomic, readwrite) SecKeyRef key;
+ (NSString *)uniqueTag;
@end
@implementation JWTCryptoKey
+ (NSString *)uniqueTag {
    return [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""].lowercaseString;
}
- (instancetype)initWithData:(NSData *)data {
    return [super init];
}
- (instancetype)initWithBase64String:(NSString *)base64String {
    return [self initWithData:[JWTBase64Coder dataWithBase64UrlEncodedString:base64String]];
}
- (instancetype)initWithPemEncoded:(NSString *)encoded {
    NSString *clean = [JWTCryptoSecurity stringByRemovingPemHeadersFromString:encoded];
    return [self initWithBase64String:clean];
}
- (instancetype)initWithPemAtURL:(NSURL *)url {
    // contents of url
    NSError *error = nil;
    NSString *pemEncoded = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    return [self initWithPemEncoded:pemEncoded];
}
@end
@implementation JWTCryptoKeyPublic
- (instancetype)initWithData:(NSData *)data {
    self = [super initWithData:data];
    if (self) {
        self.tag = [self.class uniqueTag];
        
        if (!data) {
            return nil;
        }
        
        NSData *keyData = [JWTCryptoSecurity dataByRemovingPublicKeyHeader:data];
        
        if (!keyData) {
            return nil;
        }
        
        NSError *error = nil;
        self.key = [JWTCryptoSecurity addKeyWithData:keyData asPublic:YES tag:self.tag error:&error];
        if (!self.key || error) {
            return nil;
        }
    }
    return self;
}
- (instancetype)initWithCertificateData:(NSData *)certificateData {
    SecKeyRef key = [JWTCryptoSecurity publicKeyFromCertificate:certificateData];
    if (key == NULL) {
        return nil;
    }

    if (self = [super init]) {
        self.key = key;
    }

    return self;
}
- (instancetype)initWithCertificateBase64String:(NSString *)certificate {
    // cleanup certificate if needed.
    // call initWithCertificateData:(NSData *)certificateData
    NSData *certificateData = nil;
    return [self initWithCertificateData:certificateData];
}
@end

@implementation JWTCryptoKeyPrivate
- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.tag = [self.class uniqueTag];
        NSError *error;
        NSData *keyData = data;
        if (!data) {
            return nil;
        }
        self.key = [JWTCryptoSecurity addKeyWithData:keyData asPublic:NO tag:self.tag error:&error];
        if (!self.key || error) {
            return nil;
        }
    }
    return self;
}
// Exists
- (instancetype)initWithP12AtURL:(NSURL *)url withPassphrase:(NSString *)passphrase {
    // take data.
    // cleanup if needed.
    NSData *data = [NSData dataWithContentsOfURL:url];
    return [self initWithP12Data:data withPassphrase:passphrase];
}
- (instancetype)initWithP12Data:(NSData *)p12Data withPassphrase:(NSString *)passphrase {
    if (p12Data == nil) {
        return nil;
    }

    // cleanup if needed.
    SecIdentityRef identity = nil;
    SecTrustRef trust = nil;
    [JWTCryptoSecurity extractIdentityAndTrustFromPKCS12:(__bridge CFDataRef)p12Data password:(__bridge CFStringRef)passphrase identity:&identity trust:&trust];
    BOOL identityAndTrust = identity && trust;

    if (identityAndTrust) {
        self = [super init];
        SecKeyRef privateKey;
        SecIdentityCopyPrivateKey(identity, &privateKey);
        if (self) {
            self.key = privateKey;
        }
    }

    if (identity) {
        CFRelease(identity);
    }

    if (trust) {
        CFRelease(trust);
    }

    if (!identityAndTrust) {
        return nil;
    }

    return self;
}
@end
