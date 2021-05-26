//
//  JWTClaimsSetBuilderBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimsSetBuilderBase.h"
#import "JWTClaimsSetBase.h"
@implementation JWTClaimsSetBuilderBase

- (nonnull id<JWTClaimsSetProtocol>)claimsSetWithClaims:(nonnull NSArray<id<JWTClaimProtocol>> *)claims {
    return [self.claimsSetProvider copyWithClaims:claims];
}

@end
