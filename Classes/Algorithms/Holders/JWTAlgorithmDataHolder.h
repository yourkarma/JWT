//
//  JWTAlgorithmDataHolder.h
//  JWT
//
//  Created by Lobanov Dmitry on 31.08.16.
//  Copyright © 2016 Karma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JWTAlgorithm.h"
#import "JWTDeprecations.h"

// TODO: available in 3.0
// All methods with secret as NSString in algorithms will be deprecated or removed.

@protocol JWTAlgorithmDataHolderProtocol <NSObject>
/**
 The verification key to use when encoding/decoding a JWT in data form
 */
@property (copy, nonatomic, readwrite) NSData *currentSecretData;

/**
 The <JWTAlgorithm> to use for encoding a JWT
 */
@property (strong, nonatomic, readwrite) id <JWTAlgorithm> currentAlgorithm;
@end

@interface JWTAlgorithmBaseDataHolder : NSObject <JWTAlgorithmDataHolderProtocol>

#pragma mark - Getters
/**
 The verification key to use when encoding/decoding a JWT
 */
@property (copy, nonatomic, readonly) NSString *currentSecret;

/**
 The algorithm name to use for decoding the JWT. Required unless force decode is true
 */
@property (copy, nonatomic, readonly) NSString *currentAlgorithmName;

#pragma mark - Setters
/**
 Sets jwtSecret and returns the JWTAlgorithmBaseDataHolder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTAlgorithmBaseDataHolder *(^secret)(NSString *secret);

/**
 Sets jwtSecretData and returns the JWTAlgorithmBaseDataHolder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTAlgorithmBaseDataHolder *(^secretData)(NSData *secretData);

/**
 Sets jwtAlgorithm and returns the JWTAlgorithmBaseDataHolder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTAlgorithmBaseDataHolder *(^algorithm)(id<JWTAlgorithm>algorithm);

/**
 Sets jwtAlgorithmName and returns the JWTAlgorithmBaseDataHolder to allow for method chaining. See list of names in appropriate headers.
 */
@property (copy, nonatomic, readonly) JWTAlgorithmBaseDataHolder *(^algorithmName)(NSString *algorithmName);

@end

//Discuss: maybe move to protocol?
@interface JWTAlgorithmHSFamilyDataHolder : JWTAlgorithmBaseDataHolder @end

@interface JWTAlgorithmRSFamilyDataHolder : JWTAlgorithmBaseDataHolder
#pragma mark - Getters
/**
 The passphrase for the PKCS12 blob, which represents the certificate containing the private key for the RS algorithms.
 */
@property (copy, nonatomic, readonly) NSString *currentPrivateKeyCertificatePassphrase;

#pragma mark - Setters
/**
 Sets jwtPrivateKeyCertificatePassphrase and returns the JWTAlgorithmRSFamilyDataHolder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTAlgorithmRSFamilyDataHolder *(^privateKeyCertificatePassphrase)(NSString *privateKeyCertificatePassphrase);
@end

// Public
@protocol JWTResultTypeSuccessEncodedProtocol <NSObject>
@property (copy, nonatomic, readonly) NSString *encoded;
- (instancetype)initWithEncoded:(NSString *)encoded;
@end

// Protected?
@protocol JWTMutableResultTypeSuccessEncodedProtocol <JWTResultTypeSuccessEncodedProtocol>
@property (copy, nonatomic, readwrite) NSString *encoded;
@end

// Public
@protocol JWTResultTypeSuccessDecodedProtocol <NSObject>
@property (copy, nonatomic, readonly) NSDictionary *headers;
@property (copy, nonatomic, readonly) NSDictionary *payload;
- (instancetype)initWithHeaders:(NSDictionary *)headers withPayload:(NSDictionary *)payload;
@end

// Protected?
@protocol JWTMutableResultTypeSuccessDecodedProtocol <JWTResultTypeSuccessDecodedProtocol>
@property (copy, nonatomic, readwrite) NSDictionary *headers;
@property (copy, nonatomic, readwrite) NSDictionary *payload;
@end

// Public
@interface JWTResultTypeSuccess : NSObject @end
@interface JWTResultTypeSuccess(JWTResultTypeSuccessEncodedProtocol)<JWTResultTypeSuccessEncodedProtocol>
@end
@interface JWTResultTypeSuccess(JWTResultTypeSuccessDecodedProtocol)<JWTResultTypeSuccessDecodedProtocol>
@end

// Public
@protocol JWTResultTypeErrorProtocol <NSObject>
@property (copy, nonatomic, readonly) NSError *error;
- (instancetype)initWithError:(NSError *)error;
@end

// Protected?
@protocol JWTMutableResultTypeErrorProtocol <JWTResultTypeErrorProtocol>
@property (copy, nonatomic, readwrite) NSError *error;
@end

@interface JWTResultTypeError : NSObject @end
@interface JWTResultTypeError (JWTResultTypeErrorProtocol) <JWTResultTypeErrorProtocol> @end

@interface JWTCodingResultType : NSObject
- (instancetype)initWithSuccess:(JWTResultTypeSuccess *)success withError:(NSError *)error;
@property (strong, nonatomic, readonly) JWTResultTypeSuccess *successType;
@property (strong, nonatomic, readonly) JWTResultTypeError *errorType;
@end
