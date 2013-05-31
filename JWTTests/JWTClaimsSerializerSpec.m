//
//  JWTClaimsSerializerSpec.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright 2013 Karma. All rights reserved.
//

#import "Kiwi.h"

#import "JWTClaimsSetSerializer.h"

SPEC_BEGIN(JWTClaimsSerializerSpec)

__block JWTClaimsSet *claimsSet;
__block NSDictionary *serialized;

beforeEach(^{
    claimsSet = [[JWTClaimsSet alloc] init];
    claimsSet.issuer = @"Facebook";
    claimsSet.subject = @"Token";
    claimsSet.audience = @"http://yourkarma.com";
    claimsSet.expirationDate = [NSDate distantFuture];
    claimsSet.notBeforeDate = [NSDate distantPast];
    claimsSet.issuedAt = [NSDate date];
    claimsSet.identifier = @"thisisunique";
    claimsSet.type = @"test";
    serialized = [JWTClaimsSetSerializer dictionaryWithClaimsSet:claimsSet];
});

it(@"serializes the issuer property", ^{
    [[serialized should] haveValue:claimsSet.issuer forKey:@"iss"];
});

it(@"serializes the subject property", ^{
    [[serialized should] haveValue:claimsSet.subject forKey:@"sub"];
});

it(@"serializes the audience property", ^{
    [[serialized should] haveValue:claimsSet.audience forKey:@"aud"];
});

it(@"serializes the expiration date property", ^{
    [[serialized should] haveValue:theValue([claimsSet.expirationDate timeIntervalSince1970]) forKey:@"exp"];
});

it(@"serializes the not before date property", ^{
    [[serialized should] haveValue:theValue([claimsSet.notBeforeDate timeIntervalSince1970])  forKey:@"nbf"];
});

it(@"serializes the issued at property", ^{
    [[serialized should] haveValue:theValue([claimsSet.issuedAt timeIntervalSince1970]) forKey:@"iat"];
});

it(@"serializes the JWT ID property", ^{
    [[serialized should] haveValue:claimsSet.identifier forKey:@"jti"];
});

it(@"serializes the type property", ^{
    [[serialized should] haveValue:claimsSet.type forKey:@"typ"];
});

SPEC_END


