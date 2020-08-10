//
//  JWTClaimVariations.h
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JWTClaimBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface JWTClaimVariations : NSObject
@end

@interface JWTClaimBaseVariationWithEquality : JWTClaimBase
@property (assign, nonatomic, readwrite) BOOL equal;
@end

@interface JWTClaimBaseVariationWithComparison : JWTClaimBaseVariationWithEquality
@property (assign, nonatomic, readwrite) NSComparisonResult expectedComparison;
@end

/// And base claims

@interface JWTClaimBaseVariationWithEqualityForString : JWTClaimBaseVariationWithEquality
@end

// TODO(3.0): Claim aud should check include in collection?
// Add claims specification tests.
// "iss" (Issuer) Claim
// "sub" (Subject) Claim
// "aud" (Audience) Claim
// "exp" (Expiration Time) Claim
// "nbf" (Not Before) Claim
// "iat" (Issued At) Claim
// "jti" (JWT ID) Claim
// "typ" (Type) Claim
// "scope" (Scope) Claim


@interface JWTClaimBaseConcreteIssuer : JWTClaimBaseVariationWithEquality
@end

NS_ASSUME_NONNULL_END
