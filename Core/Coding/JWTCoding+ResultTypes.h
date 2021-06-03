//
//  JWTCoding+ResultTypes.h
//  JWT
//
//  Created by Lobanov Dmitry on 30.11.16.
//  Copyright © 2016 JWTIO. All rights reserved.
//

#import <JWT/JWTCoding.h>
#import <JWT/JWTDeprecations.h>
@protocol JWTClaimsSetProtocol;

@interface JWTCodingResultComponents : NSObject
@property (copy, nonatomic, readonly, class) NSString *headers;
@property (copy, nonatomic, readonly, class) NSString *payload;
@end

@interface JWT (ResultTypes) @end

/*
            ResultType
                /\
               /  \
              /    \
          Success  Error
 
    Protocols: Mutable and Immutable (?!?)
 */

// Public
@protocol JWTCodingResultTypeSuccessEncodedProtocol <NSObject>
@property (copy, nonatomic, readonly) NSString *encoded;
- (instancetype)initWithEncoded:(NSString *)encoded;
@property (copy, nonatomic, readonly) NSString *token;
- (instancetype)initWithToken:(NSString *)token;
@end

// Public
@protocol JWTCodingResultTypeSuccessDecodedProtocol <NSObject>
@property (copy, nonatomic, readonly) NSDictionary *headers;
@property (copy, nonatomic, readonly) NSDictionary *payload;

/// This is a dictionary that contains header and payload.
///
/// @discussion
/// You may access to its guts via `JWTCodingResultComponents`.
///
/// dictionary = {
///   JWTCodingResultComponents.headers : headers,
///   JWTCodingResultComponents.payload : payload
/// }
///
@property (copy, nonatomic, readonly) NSDictionary *headerAndPayloadDictionary;
@property (copy, nonatomic, readonly) id<JWTClaimsSetProtocol> claimsSetStorage;

- (instancetype)initWithHeadersAndPayload:(NSDictionary *)headersAndPayloadDictionary;
- (instancetype)initWithHeaders:(NSDictionary *)headers withPayload:(NSDictionary *)payload;
- (instancetype)initWithClaimsSetStorage:(id<JWTClaimsSetProtocol>)claimsSetStorage;
@end

// Public
@interface JWTCodingResultTypeSuccess : NSObject <JWTCodingResultTypeSuccessEncodedProtocol,JWTCodingResultTypeSuccessDecodedProtocol> @end

// Public
@protocol JWTCodingResultTypeErrorProtocol <NSObject>
@property (copy, nonatomic, readonly) NSError *error;
- (instancetype)initWithError:(NSError *)error;
@end

@interface JWTCodingResultTypeError : NSObject <JWTCodingResultTypeErrorProtocol> @end

@interface JWTCodingResultType : NSObject
- (instancetype)initWithSuccessResult:(JWTCodingResultTypeSuccess *)success;
- (instancetype)initWithErrorResult:(JWTCodingResultTypeError *)error;
@property (strong, nonatomic, readonly) JWTCodingResultTypeSuccess *successResult;
@property (strong, nonatomic, readonly) JWTCodingResultTypeError *errorResult;
@end
