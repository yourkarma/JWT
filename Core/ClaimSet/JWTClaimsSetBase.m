//
//  JWTClaimsSetBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimsSetBase.h"

@interface JWTClaimsSetBase ()
@property (copy, nonatomic, readwrite) NSArray <id<JWTClaimProtocol>>* claims;
@end

@implementation JWTClaimsSetBase

@synthesize claims = _claims;

- (nonnull instancetype)initWithClaims:(nonnull NSArray<id<JWTClaimProtocol>> *)claims {
    if (self = [super init]) {
        self.claims = claims;
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [[self.class alloc] initWithClaims:self.claims];
}

@end
