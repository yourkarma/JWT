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
    JWTInvalidSegmentSerializationError,
    JWTUnspecifiedAlgorithmError
};

@class JWTBuilder;
@interface JWT : NSObject

#pragma mark - Encode
+ (NSString *)encodeClaimsSet:(JWTClaimsSet *)theClaimsSet withSecret:(NSString *)theSecret __attribute__((deprecated));
+ (NSString *)encodeClaimsSet:(JWTClaimsSet *)theClaimsSet withSecret:(NSString *)theSecret algorithm:(id<JWTAlgorithm>)theAlgorithm __attribute__((deprecated));

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret __attribute__((deprecated));
+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret algorithm:(id<JWTAlgorithm>)theAlgorithm __attribute__((deprecated));

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret withHeaders:(NSDictionary *)theHeaders algorithm:(id<JWTAlgorithm>)theAlgorithm __attribute__((deprecated));

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret withHeaders:(NSDictionary *)theHeaders algorithm:(id<JWTAlgorithm>)theAlgorithm withError:(NSError * __autoreleasing *)theError __attribute__((deprecated));

//Will be deprecated in later releases
#pragma mark - Decode

/**
 Decodes a JWT and returns the decoded Header and Payload
 @param theMessage The encoded JWT
 @param theSecret The verification key to use for validating the JWT signature
 @param theTrustedClaimsSet The JWTClaimsSet to use for verifying the JWT values
 @param theError Error pointer, if there is an error decoding the message, upon return contains an NSError object that describes the problem.
 @param theAlgorithmName The name of the algorithm to use for verifying the signature. Required, unless skipping verification
 @param theForcedOption BOOL indicating if verifying the JWT signature should be skipped. Should only be used for debugging
 @return A dictionary containing the header and payload dictionaries. Keyed to "header" and "payload", respectively. Or nil if an error occurs.
 */
+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withTrustedClaimsSet:(JWTClaimsSet *)theTrustedClaimsSet withError:(NSError *__autoreleasing *)theError withForcedAlgorithmByName:(NSString *)theAlgorithmName withForcedOption:(BOOL)theForcedOption __attribute__((deprecated));

/**
 Decodes a JWT and returns the decoded Header and Payload
 @param theMessage The encoded JWT
 @param theSecret The verification key to use for validating the JWT signature
 @param theTrustedClaimsSet The JWTClaimsSet to use for verifying the JWT values
 @param theError Error pointer, if there is an error decoding the message, upon return contains an NSError object that describes the problem.
 @param theAlgorithmName The name of the algorithm to use for verifying the signature. Required.
 @return A dictionary containing the header and payload dictionaries. Keyed to "header" and "payload", respectively. Or nil if an error occurs.
 */
+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withTrustedClaimsSet:(JWTClaimsSet *)theTrustedClaimsSet withError:(NSError *__autoreleasing *)theError withForcedAlgorithmByName:(NSString *)theAlgorithmName __attribute__((deprecated));

/**
 Decodes a JWT and returns the decoded Header and Payload.
 
 Uses the JWTAlgorithmHS512 for decoding
 
 @param theMessage The encoded JWT
 @param theSecret The verification key to use for validating the JWT signature
 @param theTrustedClaimsSet The JWTClaimsSet to use for verifying the JWT values
 @param theError Error pointer, if there is an error decoding the message, upon return contains an NSError object that describes the problem.
 @param theForcedOption BOOL indicating if verifying the JWT signature should be skipped. Should only be used for debugging
 @return A dictionary containing the header and payload dictionaries. Keyed to "header" and "payload", respectively. Or nil if an error occurs.
 */
+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withTrustedClaimsSet:(JWTClaimsSet *)theTrustedClaimsSet withError:(NSError *__autoreleasing *)theError withForcedOption:(BOOL)theForcedOption __attribute__((deprecated));

/**
 Decodes a JWT and returns the decoded Header and Payload
 @param theMessage The encoded JWT
 @param theSecret The verification key to use for validating the JWT signature
 @param theError Error pointer, if there is an error decoding the message, upon return contains an NSError object that describes the problem.
 @param theAlgorithmName The name of the algorithm to use for verifying the signature. Required, unless skipping verification
 @param skipVerification BOOL indicating if verifying the JWT signature should be skipped. Should only be used for debugging
 @return A dictionary containing the header and payload dictionaries. Keyed to "header" and "payload", respectively. Or nil if an error occurs.
 */
+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError *__autoreleasing *)theError withForcedAlgorithmByName:(NSString *)theAlgorithmName skipVerification:(BOOL)skipVerification __attribute__((deprecated));

/**
 Decodes a JWT and returns the decoded Header and Payload
 @param theMessage The encoded JWT
 @param theSecret The verification key to use for validating the JWT signature
 @param theError Error pointer, if there is an error decoding the message, upon return contains an NSError object that describes the problem.
 @param theAlgorithmName The name of the algorithm to use for verifying the signature. Required.
 @return A dictionary containing the header and payload dictionaries. Keyed to "header" and "payload", respectively. Or nil if an error occurs.
 */
+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError *__autoreleasing *)theError withForcedAlgorithmByName:(NSString *)theAlgorithmName __attribute__((deprecated));

/**
 Decodes a JWT and returns the decoded Header and Payload
 
 Uses the JWTAlgorithmHS512 for decoding
 
 @param theMessage The encoded JWT
 @param theSecret The verification key to use for validating the JWT signature
 @param theError Error pointer, if there is an error decoding the message, upon return contains an NSError object that describes the problem.
 @param theForcedOption BOOL indicating if verifying the JWT signature should be skipped.
 @return A dictionary containing the header and payload dictionaries. Keyed to "header" and "payload", respectively. Or nil if an error occurs.
 */
+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError *__autoreleasing *)theError withForcedOption:(BOOL)theForcedOption __attribute__((deprecated));

/**
 Decodes a JWT and returns the decoded Header and Payload.
 Uses the JWTAlgorithmHS512 for decoding
 @param theMessage The encoded JWT
 @param theSecret The verification key to use for validating the JWT signature
 @param theError Error pointer, if there is an error decoding the message, upon return contains an NSError object that describes the problem.
 @return A dictionary containing the header and payload dictionaries. Keyed to "header" and "payload", respectively. Or nil if an error occurs.
 */
+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError * __autoreleasing *)theError __attribute__((deprecated));

/**
 Decodes a JWT and returns the decoded Header and Payload.
 Uses the JWTAlgorithmHS512 for decoding
 @param theMessage The encoded JWT
 @param theSecret The verification key to use for validating the JWT signature
 @return A dictionary containing the header and payload dictionaries. Keyed to "header" and "payload", respectively. Or nil if an error occurs. 
 */
+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret __attribute__((deprecated));

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
@property (copy, nonatomic, readonly) NSSet *algorithmWhitelist;

@property (copy, nonatomic, readonly) JWTBuilder *(^message)(NSString *message);
@property (copy, nonatomic, readonly) JWTBuilder *(^payload)(NSDictionary *payload);
@property (copy, nonatomic, readonly) JWTBuilder *(^headers)(NSDictionary *headers);
@property (copy, nonatomic, readonly) JWTBuilder *(^claimsSet)(JWTClaimsSet *claimsSet);
@property (copy, nonatomic, readonly) JWTBuilder *(^secret)(NSString *secret);
@property (copy, nonatomic, readonly) JWTBuilder *(^algorithm)(id<JWTAlgorithm>algorithm);
@property (copy, nonatomic, readonly) JWTBuilder *(^algorithmName)(NSString *algorithmName);
@property (copy, nonatomic, readonly) JWTBuilder *(^options)(NSNumber *options);
@property (copy, nonatomic, readonly) JWTBuilder *(^whitelist)(NSArray *whitelist);

@property (copy, nonatomic, readonly) NSString *encode;
@property (copy, nonatomic, readonly) NSDictionary *decode;

@end