//
//  JWTClaimVerifierVariations.h
//  JWT
//
//  Created by Dmitry Lobanov on 30.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JWT/JWTClaimVerifierBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWTClaimVerifierVariations : NSObject
+ (id<JWTClaimVerifierProtocol>)issuer;
+ (id<JWTClaimVerifierProtocol>)subject;
+ (id<JWTClaimVerifierProtocol>)audienceEqualSingle;
+ (id<JWTClaimVerifierProtocol>)audienceInSet;
+ (id<JWTClaimVerifierProtocol>)expirationTime;
+ (id<JWTClaimVerifierProtocol>)notBefore;
+ (id<JWTClaimVerifierProtocol>)issuedAt;
+ (id<JWTClaimVerifierProtocol>)jwtID;
+ (id<JWTClaimVerifierProtocol>)type;
+ (id<JWTClaimVerifierProtocol>)scope;
@end

@interface JWTClaimVerifierBaseConcreteEquality : JWTClaimVerifierBase
@property (assign, nonatomic, readwrite) BOOL equal;
@end

@interface JWTClaimVerifierBaseConcreteComparison : JWTClaimVerifierBase
@property (assign, nonatomic, readwrite) NSComparisonResult expectedComparison;
@property (assign, nonatomic, readwrite) BOOL trustedValueAtLeft;
@property (assign, nonatomic, readwrite) BOOL notEqual;
@end

@interface JWTClaimVerifierBaseConcreteEqualityForString : JWTClaimVerifierBaseConcreteEquality
@end

@interface JWTClaimVerifierBaseConcreteInclusionInSet : JWTClaimVerifierBase
@end

NS_ASSUME_NONNULL_END
