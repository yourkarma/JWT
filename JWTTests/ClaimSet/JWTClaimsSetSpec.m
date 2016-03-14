//
//  JWTClaimsSetSpec.m
//  JWT
//
//  Created by Klaas Pieter Annema on 26-07-13.
//  Copyright 2013 Karma. All rights reserved.
//

//#import <Kiwi/Kiwi.h>
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "JWTClaimsSet.h"

SpecBegin(JWTClaimsSetSpec)

describe(@"ClaimsSet", ^{
    __block JWTClaimsSet *claims;
    
    beforeEach(^{
        claims = [[JWTClaimsSet alloc] init];
    });
    
    it(@"should have a future expiration date if none was set", ^{
        expect(claims.expirationDate).to.beGreaterThan([NSDate date]);
    });
    
    it(@"should have a past before date if none was set", ^{
        expect(claims.notBeforeDate).to.beLessThanOrEqualTo([NSDate date]);
    });
    
    it(@"should have the current date as issuedAt date if none was set", ^{
        expect(claims.issuedAt).to.beGreaterThan([NSDate dateWithTimeIntervalSinceNow:-1.0]);
        expect(claims.issuedAt).to.beLessThan([NSDate dateWithTimeIntervalSinceNow:1.0]);
        //    expect(claims.issuedAt).to.beBetween([NSDate dateWithTimeIntervalSinceNow:-1.0]).and([NSDate dateWithTimeIntervalSinceNow:1.0]);
    });
});

SpecEnd

//SPEC_BEGIN(JWTClaimsSetSpec)
//
//__block JWTClaimsSet *claims;
//
//beforeEach(^{
//    claims = [[JWTClaimsSet alloc] init];
//});
//
//it(@"should have a future expiration date if none was set", ^{
//    [[claims.expirationDate should] beGreaterThan:[NSDate date]];
//});
//
//it(@"should have a past before date if none was set", ^{
//    [[claims.notBeforeDate should] beLessThanOrEqualTo:[NSDate date]];
//});
//
//it(@"should have the current date as issuedAt date if none was set", ^{
//    [[claims.issuedAt should] beBetween:[NSDate dateWithTimeIntervalSinceNow:-1.0] and:[NSDate dateWithTimeIntervalSinceNow:1.0]];
//});
//
//SPEC_END


