//
//  JWTBuilder+FluentStyle.h
//  JWT
//
//  Created by Dmitry Lobanov on 15/06/2019.
//  Copyright © 2019 JWTIO. All rights reserved.
//

#import "JWTCoding+VersionTwo.h"
#import "JWTDeprecations.h"

NS_ASSUME_NONNULL_BEGIN

// Fluent ( Objective-C exclusive ).
@interface JWTBuilder (FluentStyle)
/**
 Sets jwtMessage and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^message)(NSString *message) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

/**
 Sets jwtPayload and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^payload)(NSDictionary *payload) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

/**
 Sets jwtHeaders and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^headers)(NSDictionary *headers) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

/**
 Sets jwtClaimsSet and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^claimsSet)(JWTClaimsSet *claimsSet) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

/**
 Sets jwtSecret and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^secret)(NSString *secret) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

/**
 Sets jwtSecretData and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^secretData)(NSData *secretData) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

/**
 Sets jwtPrivateKeyCertificatePassphrase and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^privateKeyCertificatePassphrase)(NSString *privateKeyCertificatePassphrase) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

/**
 Sets jwtAlgorithm and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^algorithm)(id<JWTAlgorithm>algorithm) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

/**
 Sets jwtAlgorithmName and returns the JWTBuilder to allow for method chaining. See list of names in appropriate headers.
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^algorithmName)(NSString *algorithmName) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

/**
 Sets jwtOptions and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^options)(NSNumber *options) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;

/**
 Sets algorithmWhitelist and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^whitelist)(NSArray *whitelist) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
