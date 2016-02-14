//
//  JWT.h
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright (c) 2013 Karma. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JWTAlgorithm.h"
#import "JWTClaimsSet.h"

typedef NS_ENUM(NSInteger, JWTError) {
    JWTInvalidFormatError = -100,
    JWTUnsupportedAlgorithmError,
    JWTInvalidSignatureError,
    JWTNoPayloadError,
    JWTNoHeaderError,
    JWTEncodingHeaderError,
    JWTEncodingPayloadError,
    JWTClaimsSetVerificationFailed,
    JWTInvalidSegmentSerializationError
};

@class JWTBuilder;
@interface JWT : NSObject

#pragma mark - Encode
+ (NSString *)encodeClaimsSet:(JWTClaimsSet *)theClaimsSet withSecret:(NSString *)theSecret;
+ (NSString *)encodeClaimsSet:(JWTClaimsSet *)theClaimsSet withSecret:(NSString *)theSecret algorithm:(id<JWTAlgorithm>)theAlgorithm;

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret;
+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret algorithm:(id<JWTAlgorithm>)theAlgorithm;

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret withHeaders:(NSDictionary *)theHeaders algorithm:(id<JWTAlgorithm>)theAlgorithm;

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret withHeaders:(NSDictionary *)theHeaders algorithm:(id<JWTAlgorithm>)theAlgorithm withError:(NSError * __autoreleasing *)theError;

//Will be deprecated in later releases
#pragma mark - Decode
+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withTrustedClaimsSet:(JWTClaimsSet *)theTrustedClaimsSet withError:(NSError *__autoreleasing *)theError withForcedOption:(BOOL)theForcedOption;
+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError *__autoreleasing *)theError withForcedOption:(BOOL)theForcedOption;
+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError * __autoreleasing *)theError;
+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret;

#pragma mark - Builder
+ (JWTBuilder *)encodePayload:(NSDictionary *)payload;
+ (JWTBuilder *)encodeClaimsSet:(JWTClaimsSet *)claimsSet;
+ (JWTBuilder *)decodeMessage:(NSString *)message;
@end

@interface JWTBuilder : NSObject 

+ (JWTBuilder *)encodePayload:(NSDictionary *)payload;
+ (JWTBuilder *)encodeClaimsSet:(JWTClaimsSet *)claimsSet;
+ (JWTBuilder *)decodeMessage:(NSString *)message;

@property (copy, nonatomic, readonly) NSString *jwtMessage;
@property (copy, nonatomic, readonly) NSDictionary *jwtPayload;
@property (copy, nonatomic, readonly) NSDictionary *jwtHeaders;
@property (copy, nonatomic, readonly) JWTClaimsSet *jwtClaimsSet;
@property (copy, nonatomic, readonly) NSString *jwtSecret;
@property (copy, nonatomic, readonly) NSError *jwtError;
@property (strong, nonatomic, readonly) id<JWTAlgorithm> jwtAlgorithm;
@property (copy, nonatomic, readonly) NSString *jwtAlgorithmName;
@property (copy, nonatomic, readonly) NSNumber *jwtOptions;

@property (copy, nonatomic, readonly) JWTBuilder *(^message)(NSString *message);
@property (copy, nonatomic, readonly) JWTBuilder *(^payload)(NSDictionary *payload);
@property (copy, nonatomic, readonly) JWTBuilder *(^headers)(NSDictionary *headers);
@property (copy, nonatomic, readonly) JWTBuilder *(^claimsSet)(JWTClaimsSet *claimsSet);
@property (copy, nonatomic, readonly) JWTBuilder *(^secret)(NSString *secret);
@property (copy, nonatomic, readonly) JWTBuilder *(^algorithm)(id<JWTAlgorithm>algorithm);
@property (copy, nonatomic, readonly) JWTBuilder *(^algorithmName)(NSString *algorithmName);
@property (copy, nonatomic, readonly) JWTBuilder *(^options)(NSNumber *options);

@property (copy, nonatomic, readonly) NSString *encode;
@property (copy, nonatomic, readonly) NSDictionary *decode;

@end