//
//  JWTBuilder+FluentStyle.h
//  JWT
//
//  Created by Dmitry Lobanov on 15/06/2019.
//  Copyright © 2019 JWTIO. All rights reserved.
//

#import <JWT/JWTCoding+VersionTwo.h>
#import <JWT/JWTDeprecations.h>

#if DEPLOYMENT_RUNTIME_SWIFT
#else
NS_ASSUME_NONNULL_BEGIN

// Fluent ( Objective-C exclusive ).
@interface JWTBuilder (FluentStyle)
/**
 Sets jwtMessage and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^message)(NSString *message) NS_SWIFT_UNAVAILABLE("");

/**
 Sets jwtPayload and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^payload)(NSDictionary *payload) NS_SWIFT_UNAVAILABLE("");

/**
 Sets jwtHeaders and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^headers)(NSDictionary *headers) NS_SWIFT_UNAVAILABLE("");

/**
 Sets jwtClaimsSet and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^claimsSet)(JWTClaimsSet *claimsSet) NS_SWIFT_UNAVAILABLE("");

/**
 Sets jwtSecret and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^secret)(NSString *secret) NS_SWIFT_UNAVAILABLE("");

/**
 Sets jwtSecretData and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^secretData)(NSData *secretData) NS_SWIFT_UNAVAILABLE("");

/**
 Sets jwtPrivateKeyCertificatePassphrase and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^privateKeyCertificatePassphrase)(NSString *privateKeyCertificatePassphrase) NS_SWIFT_UNAVAILABLE("");

/**
 Sets jwtAlgorithm and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^algorithm)(id<JWTAlgorithm>algorithm) NS_SWIFT_UNAVAILABLE("");

/**
 Sets jwtAlgorithmName and returns the JWTBuilder to allow for method chaining. See list of names in appropriate headers.
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^algorithmName)(NSString *algorithmName) NS_SWIFT_UNAVAILABLE("");

/**
 Sets jwtOptions and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^options)(NSNumber *options) NS_SWIFT_UNAVAILABLE("");

/**
 Sets algorithmWhitelist and returns the JWTBuilder to allow for method chaining
 */
@property (copy, nonatomic, readonly) JWTBuilder *(^whitelist)(NSArray *whitelist) NS_SWIFT_UNAVAILABLE("");
@end

NS_ASSUME_NONNULL_END
#endif
