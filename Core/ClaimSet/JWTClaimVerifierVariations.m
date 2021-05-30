//
//  JWTClaimVerifierVariations.m
//  JWT
//
//  Created by Dmitry Lobanov on 30.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import "JWTClaimVerifierVariations.h"

@implementation JWTClaimVerifierVariations
+ (id<JWTClaimVerifierProtocol>)issuer {
    return [JWTClaimVerifierBaseConcreteEqualityForString new];
}

+ (id<JWTClaimVerifierProtocol>)subject {
    return [JWTClaimVerifierBaseConcreteEqualityForString new];
}

+ (id<JWTClaimVerifierProtocol>)audienceEqualSingle {
    return [JWTClaimVerifierBaseConcreteEqualityForString new];
}

+ (id<JWTClaimVerifierProtocol>)audienceInSet {
    return [JWTClaimVerifierBaseConcreteInclusionInSet new];
}

// trustedValue - current date
// value - expiration date
// trustedValue < value, so
+ (id<JWTClaimVerifierProtocol>)expirationTime {
    __auto_type verifier = [JWTClaimVerifierBaseConcreteComparison new];
    verifier.trustedValueAtLeft = YES;
    verifier.expectedComparison = NSOrderedAscending;
    return verifier;
}

// trustedValue - current date
// value - start date
// value <= trustedValue, so
// trustedValue >= value, which means:
// !(trustedValue < value) or NOT OrderedAscending
+ (id<JWTClaimVerifierProtocol>)notBefore {
    __auto_type verifier = [JWTClaimVerifierBaseConcreteComparison new];
    verifier.trustedValueAtLeft = YES;
    verifier.expectedComparison = NSOrderedAscending;
    verifier.notEqual = YES;
    return verifier;
}

// trustedValue - current date
// value - issued at date
// value < trustedValue, so
// trustedValue > value
+ (id<JWTClaimVerifierProtocol>)issuedAt {
    __auto_type verifier = [JWTClaimVerifierBaseConcreteComparison new];
    verifier.trustedValueAtLeft = YES;
    verifier.expectedComparison = NSOrderedDescending;
    return verifier;
}

+ (id<JWTClaimVerifierProtocol>)jwtID {
    return [JWTClaimVerifierBaseConcreteEqualityForString new];
}

+ (id<JWTClaimVerifierProtocol>)type {
    return [JWTClaimVerifierBaseConcreteEqualityForString new];
}

+ (id<JWTClaimVerifierProtocol>)scope {
    return [JWTClaimVerifierBaseConcreteEqualityForString new];
}
@end

@implementation JWTClaimVerifierBaseConcreteEquality
- (instancetype)init {
    if (self = [super init]) {
        self.equal = YES;
    }
    return self;
}
- (BOOL)verifyValue:(NSObject *)value withTrustedValue:(NSObject *)trustedValue {
    return [value isEqual:trustedValue] == self.equal;
}
@end

@implementation JWTClaimVerifierBaseConcreteComparison
- (BOOL)verifyValue:(NSObject *)value withTrustedValue:(NSObject *)trustedValue {
    if (self.trustedValueAtLeft) {
        __auto_type swap = value;
        value = trustedValue;
        trustedValue = swap;
    }
    if ([value respondsToSelector:@selector(compare:)]) {
        __auto_type result = (NSComparisonResult)[value performSelector:@selector(compare:) withObject:trustedValue];
        if (self.notEqual) {
            return result != self.expectedComparison;
        }
        return result == self.expectedComparison;
    }
    return NO;
}
@end

@implementation JWTClaimVerifierBaseConcreteEqualityForString
- (BOOL)verifyValue:(NSObject *)value withTrustedValue:(NSObject *)trustedValue {
    if ([value isKindOfClass:NSString.class] && [trustedValue isKindOfClass:NSString.class]) {
        return [(NSString *)value isEqualToString:(NSString *)trustedValue] == self.equal;
    }
    return [super verifyValue:value withTrustedValue:trustedValue];
}
@end

@implementation JWTClaimVerifierBaseConcreteInclusionInSet
- (BOOL)verifyValue:(NSObject *)value withTrustedValue:(NSObject *)trustedValue {
    if ([trustedValue isKindOfClass:NSSet.class]) {
        return [(NSSet *)trustedValue containsObject:value];
    }
    return NO;
}
@end
