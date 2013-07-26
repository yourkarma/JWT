//
//  JWTClaimsSetSpec.m
//  JWT
//
//  Created by Klaas Pieter Annema on 26-07-13.
//  Copyright 2013 Karma. All rights reserved.
//

#import "Kiwi.h"

#import "JWTClaimsSet.h"

SPEC_BEGIN(JWTClaimsSetSpec)

it(@"should have a future expiration date if none was set", ^{
    JWTClaimsSet *claims = [[JWTClaimsSet alloc] init];
    [[claims.expirationDate should] beGreaterThan:[NSDate date]];
});

SPEC_END


