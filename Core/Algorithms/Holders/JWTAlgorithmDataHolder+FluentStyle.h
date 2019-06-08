//
//  JWTAlgorithmDataHolder+FluentStyle.h
//  JWT
//
//  Created by Dmitry Lobanov on 07/06/2019.
//  Copyright © 2019 JWTIO. All rights reserved.
//

#import "JWTAlgorithmDataHolder.h"
#import "JWTDeprecations.h"

NS_ASSUME_NONNULL_BEGIN

// Fluent ( Objective-C exclusive ).
@interface JWTAlgorithmBaseDataHolder (FluentStyle)
/**
 Sets jwtSecret and returns the JWTAlgorithmBaseDataHolder to allow for method chaining
 */
 @property (copy, nonatomic, readonly) JWTAlgorithmBaseDataHolder *(^secret)(NSString *secret) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

/**
 Sets jwtSecretData and returns the JWTAlgorithmBaseDataHolder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTAlgorithmBaseDataHolder *(^secretData)(NSData *secretData) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

/**
 Sets jwtAlgorithm and returns the JWTAlgorithmBaseDataHolder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTAlgorithmBaseDataHolder *(^algorithm)(id<JWTAlgorithm>algorithm) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

/**
 Sets jwtAlgorithmName and returns the JWTAlgorithmBaseDataHolder to allow for method chaining. See list of names in appropriate headers.
 */
@property (copy, nonatomic, readonly) JWTAlgorithmBaseDataHolder *(^algorithmName)(NSString *algorithmName) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

/**
 Sets stringCoder and returns the JWTAlgorithmBaseDataHolder to allow for method chaining. See list of names in appropriate headers.
 */
@property (copy, nonatomic, readonly) JWTAlgorithmBaseDataHolder *(^stringCoder)(id<JWTStringCoder__Protocol> stringCoder) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@end

@interface JWTAlgorithmRSFamilyDataHolder (FluentStyle)
/**
 Sets jwtPrivateKeyCertificatePassphrase and returns the JWTAlgorithmRSFamilyDataHolder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTAlgorithmRSFamilyDataHolder *(^privateKeyCertificatePassphrase)(NSString *privateKeyCertificatePassphrase) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@property (copy, nonatomic, readonly) JWTAlgorithmRSFamilyDataHolder *(^keyExtractorType)(NSString *keyExtractorType) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

// BUG:
// If you set sign/verify keys, you should also set .secretData([NSData data]);
// Yes, this is a bug.
// Please, set it.
@property (copy, nonatomic, readonly) JWTAlgorithmRSFamilyDataHolder *(^signKey)(id<JWTCryptoKeyProtocol> signKey) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@property (copy, nonatomic, readonly) JWTAlgorithmRSFamilyDataHolder *(^verifyKey)(id<JWTCryptoKeyProtocol> verifyKey) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END

