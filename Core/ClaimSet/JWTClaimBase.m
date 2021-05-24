//
//  JWTClaimBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimBase.h"

@interface JWTClaimBase ()
@property (nonatomic, readwrite) NSObject *value;
@end
@implementation JWTClaimBase
@synthesize value = _value;
- (NSString *)name { return @""; }
- (instancetype)initWithValue:(NSObject *)value {
    if (self = [super init]) {
        self.value = value;
    }
    return self;
}
- (instancetype)copyWithValue:(NSObject *)value {
    return [[self.class alloc] initWithValue:value];
}

- (BOOL)verifyValue:(nonnull NSObject *)value withTrustedValue:(nonnull NSObject *)trustedValue { return NO; }

- (nonnull id)copyWithZone:(nullable NSZone *)zone { return [[self.class alloc] initWithValue:self.value]; }

@end
