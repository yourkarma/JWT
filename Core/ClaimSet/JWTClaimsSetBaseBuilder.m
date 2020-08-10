//
//  JWTClaimsSetBaseBuilder.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimsSetBaseBuilder.h"
#import "JWTClaimsSetBase.h"
@implementation JWTClaimsSetBaseBuilder

- (nonnull id<JWTClaimsSetProtocol>)claimsSetWithClaims:(nonnull NSArray<id<JWTClaimProtocol>> *)claims {
    return [[JWTClaimsSetBase alloc] initWithClaims:claims];
}

@end
