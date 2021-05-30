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
- (instancetype)initWithValue:(NSObject *)value {
    if (self = [super init]) {
        self.value = value;
    }
    return self;
}

// MARK: - NSCopying
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [self copyWithValue:self.value];
}

// MARK: - JWTClaimProtocol
+ (NSString *)name { return @""; }
- (NSString *)name { return self.class.name; }
- (instancetype)copyWithValue:(NSObject *)value {
    return [[self.class alloc] initWithValue:value];
}

@end
