//
//  JWTAlgorithmHS384.m
//  JWT
//
//  Created by Lobanov Dmitry on 06-02-16.
//  Copyright (c) 2016 lolgear. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonHMAC.h>

#import "JWTAlgorithmHS384.h"
#import "NSData+JWT.h"

@implementation JWTAlgorithmHS384

- (NSString *)name;
{
    return @"HS384";
}

- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret;
{
    const char *cString = [theString cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cSecret = [theSecret cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA384_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA384, cSecret, strlen(cSecret), cString, strlen(cString), cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}

- (NSData *)encodePayloadData:(NSData *)theStringData withSecret:(NSData *)theSecretData
{
    unsigned char cHMAC[CC_SHA384_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA384, theSecretData.bytes, [theSecretData length], theStringData.bytes, [theStringData length], cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}

- (BOOL)verifySignedInput:(NSString *)input withSignature:(NSString *)signature verificationKey:(NSString *)verificationKey
{
    NSString *expectedSignature = [[self encodePayload:input withSecret:verificationKey] base64UrlEncodedString];
    
    return [expectedSignature isEqualToString:signature];
}

@end