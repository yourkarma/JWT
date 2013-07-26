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

__block JWTClaimsSet *claims;

beforeEach(^{
    claims = [[JWTClaimsSet alloc] init];
});

it(@"should have a future expiration date if none was set", ^{
    [[claims.expirationDate should] beGreaterThan:[NSDate date]];
});

it(@"should have a past before date if none was set", ^{
    [[claims.notBeforeDate should] beLessThanOrEqualTo:[NSDate date]];
});

SPEC_END


