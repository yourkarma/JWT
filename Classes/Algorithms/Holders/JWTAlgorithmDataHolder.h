//
//  JWTAlgorithmDataHolder.h
//  JWT
//
//  Created by Lobanov Dmitry on 31.08.16.
//  Copyright © 2016 Karma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JWTAlgorithm.h"

// TODO: available in 3.0
// All methods with secret as NSString in algorithms will be deprecated or removed.

@protocol JWTAlgorithmDataHolder <NSObject>
@property (copy, nonatomic, readonly) NSData *currentSecretData;
@property (strong, nonatomic, readonly) id <JWTAlgorithm> currentAlgorithm;
@end

@interface JWTAlgorithmBaseDataHolder : NSObject <JWTAlgorithmDataHolder>

#pragma mark - Getters
@property (copy, nonatomic, readonly) NSString *currentSecret;
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

@interface JWTAlgorithmHSFamilyDataHolder : JWTAlgorithmBaseDataHolder
@end

@interface JWTAlgorithmRSFamilyDataHolder : JWTAlgorithmBaseDataHolder
#pragma mark - Getters
@property (copy, nonatomic, readonly) NSString *currentPrivateKeyCertificatePassphrase;

#pragma mark - Setters
/**
 Sets jwtPrivateKeyCertificatePassphrase and returns the JWTAlgorithmRSFamilyDataHolder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTAlgorithmRSFamilyDataHolder *(^privateKeyCertificatePassphrase)(NSString *privateKeyCertificatePassphrase);
@end