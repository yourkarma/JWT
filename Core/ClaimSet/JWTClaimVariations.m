//
//  JWTClaimVariations.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimVariations.h"

@implementation JWTClaimBaseVariationWithEquality

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


@implementation JWTClaimBaseVariationWithComparison

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

@implementation JWTClaimBaseVariationWithEqualityForString
- (BOOL)verifyValue:(NSObject *)value withTrustedValue:(NSObject *)trustedValue {
    if ([value isKindOfClass:NSString.class] && [trustedValue isKindOfClass:NSString.class]) {
        return [(NSString *)value isEqualToString:(NSString *)trustedValue] == self.equal;
    }
    return [super verifyValue:value withTrustedValue:trustedValue];
}
@end

@implementation JWTClaimBaseVariationWithInclusionInSet
- (BOOL)verifyValue:(NSObject *)value withTrustedValue:(NSObject *)trustedValue {
    if ([trustedValue isKindOfClass:NSSet.class]) {
        return [(NSSet *)trustedValue containsObject:value];
    }
    return NO;
}
@end

// MARK: - Base Concrete Claims
@implementation JWTClaimBaseConcreteIssuer
+ (NSString *)name { return @"iss"; }
@end

@implementation JWTClaimBaseConcreteSubject
+ (NSString *)name { return @"sub"; }
@end

@implementation JWTClaimBaseConcreteAudienceEqualSingle
+ (NSString *)name { return @"aud"; }
@end

@implementation JWTClaimBaseConcreteAudienceInSet
+ (NSString *)name { return @"aud"; }
@end

// trustedValue - current date
// value - expiration date
// trustedValue < value, so
@implementation JWTClaimBaseConcreteExpirationTime
+ (NSString *)name { return @"exp"; }
- (BOOL)trustedValueAtLeft { return YES; }
- (NSComparisonResult)expectedComparison {
    return NSOrderedAscending;
}
@end

// trustedValue - current date
// value - start date
// value <= trustedValue, so
// trustedValue >= value, which means:
// !(trustedValue < value) or NOT OrderedAscending
@implementation JWTClaimBaseConcreteNotBefore
+ (NSString *)name { return @"nbf"; }
- (BOOL)trustedValueAtLeft { return YES; }
- (NSComparisonResult)expectedComparison {
    return NSOrderedAscending;
}
- (BOOL)notEqual { return YES; }
@end

// trustedValue - current date
// value - issued at date
// value < trustedValue, so
// trustedValue > value
@implementation JWTClaimBaseConcreteIssuedAt
+ (NSString *)name { return @"iat"; }
- (BOOL)trustedValueAtLeft { return YES; }
- (NSComparisonResult)expectedComparison {
    return NSOrderedDescending;
}
@end

@implementation JWTClaimBaseConcreteJWTID
+ (NSString *)name { return @"jti"; }
@end

@implementation JWTClaimBaseConcreteType
+ (NSString *)name { return @"typ"; }
@end

@implementation JWTClaimBaseConcreteScope
+ (NSString *)name { return @"scope"; }
@end

