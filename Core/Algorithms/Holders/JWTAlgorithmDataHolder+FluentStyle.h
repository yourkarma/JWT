//
//  JWTAlgorithmDataHolder+FluentStyle.h
//  JWT
//
//  Created by Dmitry Lobanov on 07/06/2019.
//  Copyright © 2019 JWTIO. All rights reserved.
//

#import <JWT/JWTAlgorithmDataHolder.h>
#import <JWT/JWTDeprecations.h>

#if DEPLOYMENT_RUNTIME_SWIFT
#else
NS_ASSUME_NONNULL_BEGIN

// Fluent ( Objective-C exclusive ).
@interface JWTAlgorithmBaseDataHolder (FluentStyle)
/**
 Sets jwtSecret and returns the JWTAlgorithmBaseDataHolder to allow for method chaining
 */
 @property (copy, nonatomic, readonly) JWTAlgorithmBaseDataHolder *(^secret)(NSString *secret) NS_SWIFT_UNAVAILABLE("");

/**
 Sets jwtSecretData and returns the JWTAlgorithmBaseDataHolder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTAlgorithmBaseDataHolder *(^secretData)(NSData *secretData) NS_SWIFT_UNAVAILABLE("");

/**
 Sets jwtAlgorithm and returns the JWTAlgorithmBaseDataHolder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTAlgorithmBaseDataHolder *(^algorithm)(id<JWTAlgorithm>algorithm) NS_SWIFT_UNAVAILABLE("");

/**
 Sets jwtAlgorithmName and returns the JWTAlgorithmBaseDataHolder to allow for method chaining. See list of names in appropriate headers.
 */
@property (copy, nonatomic, readonly) JWTAlgorithmBaseDataHolder *(^algorithmName)(NSString *algorithmName) NS_SWIFT_UNAVAILABLE("");

/**
 Sets stringCoder and returns the JWTAlgorithmBaseDataHolder to allow for method chaining. See list of names in appropriate headers.
 */
@property (copy, nonatomic, readonly) JWTAlgorithmBaseDataHolder *(^stringCoder)(id<JWTStringCoderProtocol> stringCoder) NS_SWIFT_UNAVAILABLE("");
@end

@interface JWTAlgorithmRSFamilyDataHolder (FluentStyle)
/**
 Sets jwtPrivateKeyCertificatePassphrase and returns the JWTAlgorithmRSFamilyDataHolder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTAlgorithmRSFamilyDataHolder *(^privateKeyCertificatePassphrase)(NSString *privateKeyCertificatePassphrase) NS_SWIFT_UNAVAILABLE("");
@property (copy, nonatomic, readonly) JWTAlgorithmRSFamilyDataHolder *(^keyExtractorType)(NSString *keyExtractorType) NS_SWIFT_UNAVAILABLE("");

// BUG:
// If you set sign/verify keys, you should also set .secretData([NSData data]);
// Yes, this is a bug.
// Please, set it.
@property (copy, nonatomic, readonly) JWTAlgorithmRSFamilyDataHolder *(^signKey)(id<JWTCryptoKeyProtocol> signKey) NS_SWIFT_UNAVAILABLE("");
@property (copy, nonatomic, readonly) JWTAlgorithmRSFamilyDataHolder *(^verifyKey)(id<JWTCryptoKeyProtocol> verifyKey) NS_SWIFT_UNAVAILABLE("");
@end

NS_ASSUME_NONNULL_END
#endif
