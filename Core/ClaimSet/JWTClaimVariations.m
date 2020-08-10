//
//  JWTClaimVariations.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimVariations.h"

@implementation JWTClaimVariations

@end

@implementation JWTClaimBaseVariationWithEquality

- (BOOL)verifyValue:(NSObject *)value withTrustedValue:(NSObject *)trustedValue {
    return [value isEqualTo:trustedValue] == self.equal;
}

@end

@implementation JWTClaimBaseVariationWithComparison

- (BOOL)verifyValue:(NSObject *)value withTrustedValue:(NSObject *)trustedValue {
    if ([value respondsToSelector:@selector(compare:)]) {
        __auto_type result = (NSComparisonResult)[value performSelector:@selector(compare:) withObject:trustedValue];
        return result == self.expectedComparison == self.equal;
    }
    return NO;
}

@end

