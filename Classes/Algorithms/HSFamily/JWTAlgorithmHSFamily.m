//
//  JWTAlgorithmHSFamily.m
//  JWT
//
//  Created by Lobanov Dmitry on 23.02.16.
//  Copyright © 2016 Karma. All rights reserved.
//

#import "JWTAlgorithmHSFamily.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonHMAC.h>
#import "JWTAlgorithmHS256.h"
#import "JWTAlgorithmHS384.h"
#import "JWTAlgorithmHS512.h"

//uncomment later for refactoring
//@interface JWTAlgorithmHS256 : NSObject <JWTAlgorithm>
//
//@end
//
//@implementation JWTAlgorithmHS256
//
//- (NSString *)name;
//{
//    return @"HS256";
//}
//
//- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret;
//{
//    const char *cString = [theString cStringUsingEncoding:NSUTF8StringEncoding];
//    const char *cSecret = [theSecret cStringUsingEncoding:NSUTF8StringEncoding];
//    
//    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
//    CCHmac(kCCHmacAlgSHA256, cSecret, strlen(cSecret), cString, strlen(cString), cHMAC);
//    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
//}
//
//- (BOOL)verifySignedInput:(NSString *)input withSignature:(NSString *)signature verificationKey:(NSString *)verificationKey
//{
//    NSString *expectedSignature = [[self encodePayload:input withSecret:verificationKey] base64UrlEncodedString];
//    
//    return [expectedSignature isEqualToString:signature];
//}
//
//@end
//
//@interface JWTAlgorithmHS384 : NSObject <JWTAlgorithm>
//
//@end
//
//@implementation JWTAlgorithmHS384
//
//- (NSString *)name;
//{
//    return @"HS384";
//}
//
//- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret;
//{
//    const char *cString = [theString cStringUsingEncoding:NSUTF8StringEncoding];
//    const char *cSecret = [theSecret cStringUsingEncoding:NSUTF8StringEncoding];
//    
//    unsigned char cHMAC[CC_SHA384_DIGEST_LENGTH];
//    CCHmac(kCCHmacAlgSHA384, cSecret, strlen(cSecret), cString, strlen(cString), cHMAC);
//    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
//}
//
//- (BOOL)verifySignedInput:(NSString *)input withSignature:(NSString *)signature verificationKey:(NSString *)verificationKey
//{
//    NSString *expectedSignature = [[self encodePayload:input withSecret:verificationKey] base64UrlEncodedString];
//    
//    return [expectedSignature isEqualToString:signature];
//}
//
//@end
//
//@interface JWTAlgorithmHS512 : NSObject <JWTAlgorithm>
//
//@end
//
//@implementation JWTAlgorithmHS512
//
//- (NSString *)name;
//{
//    return @"HS512";
//}
//
//- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret;
//{
//    const char *cString = [theString cStringUsingEncoding:NSUTF8StringEncoding];
//    const char *cSecret = [theSecret cStringUsingEncoding:NSUTF8StringEncoding];
//    
//    unsigned char cHMAC[CC_SHA512_DIGEST_LENGTH];
//    CCHmac(kCCHmacAlgSHA512, cSecret, strlen(cSecret), cString, strlen(cString), cHMAC);
//    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
//}
//
//- (BOOL)verifySignedInput:(NSString *)input withSignature:(NSString *)signature verificationKey:(NSString *)verificationKey
//{
//    NSString *expectedSignature = [[self encodePayload:input withSecret:verificationKey] base64UrlEncodedString];
//    
//    return [expectedSignature isEqualToString:signature];
//}
//
//@end

@implementation JWTAlgorithmHSFamily

+ (id<JWTAlgorithm>)jwtAlgorithmWithName:(NSString *)name {
	id<JWTAlgorithm> algorithm = nil;
    if ([name isEqualToString:JWTAlgorithmHSFamilyLength256]) {
    	algorithm = [JWTAlgorithmHS256 new];
    }
    else if ([name isEqualToString:JWTAlgorithmHSFamilyLength384]) {
    	algorithm = [JWTAlgorithmHS384 new];
    }
	else if ([name isEqualToString:JWTAlgorithmHSFamilyLength512]) {
		algorithm = [JWTAlgorithmHS512 new];
	}
    return algorithm;
}

@end
