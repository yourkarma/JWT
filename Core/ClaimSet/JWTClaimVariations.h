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

@interface JWTClaimBaseVariationWithEquality : JWTClaimBase
@property (assign, nonatomic, readwrite) BOOL equal;
@end

@interface JWTClaimBaseVariationWithComparison : JWTClaimBaseVariationWithEquality
@property (assign, nonatomic, readwrite) NSComparisonResult expectedComparison;
@property (assign, nonatomic, readwrite) BOOL trustedValueAtLeft;
@property (assign, nonatomic, readwrite) BOOL notEqual;
@end

/// And base claims

@interface JWTClaimBaseVariationWithEqualityForString : JWTClaimBaseVariationWithEquality
@end

/// In that case we treating a value of a trusted claim as NSSet
@interface JWTClaimBaseVariationWithInclusionInSet : JWTClaimBase
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


@interface JWTClaimBaseConcreteIssuer : JWTClaimBaseVariationWithEqualityForString
@end

@interface JWTClaimBaseConcreteSubject : JWTClaimBaseVariationWithEqualityForString
@end

@interface JWTClaimBaseConcreteAudienceEqualSingle : JWTClaimBaseVariationWithEqualityForString
@end

@interface JWTClaimBaseConcreteAudienceInSet : JWTClaimBaseVariationWithInclusionInSet
@end

typedef JWTClaimBaseConcreteAudienceEqualSingle JWTClaimBaseConcreteAudience;

@interface JWTClaimBaseConcreteExpirationTime : JWTClaimBaseVariationWithComparison
@end

@interface JWTClaimBaseConcreteNotBefore : JWTClaimBaseVariationWithComparison
@end

@interface JWTClaimBaseConcreteIssuedAt : JWTClaimBaseVariationWithComparison
@end

@interface JWTClaimBaseConcreteJWTID : JWTClaimBaseVariationWithEqualityForString
@end

@interface JWTClaimBaseConcreteType : JWTClaimBaseVariationWithEqualityForString
@end

@interface JWTClaimBaseConcreteScope : JWTClaimBaseVariationWithEqualityForString
@end

NS_ASSUME_NONNULL_END
