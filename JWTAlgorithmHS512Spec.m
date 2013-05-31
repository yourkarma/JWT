//
//  JWTAlgorithmHS512.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright 2013 Karma. All rights reserved.
//

#import "Kiwi.h"

#import "JWTAlgorithmHS512.h"
#import "Base64.h"

SPEC_BEGIN(JWTAlgorithmHS512Spec)

__block JWTAlgorithmHS512 *algorithm;

beforeEach(^{
    algorithm = [[JWTAlgorithmHS512 alloc] init];
});

it(@"name is HS512", ^{
    [[algorithm.name should] equal:@"HS512"];
});

it(@"HMAC encodes the payload using SHA512", ^{
    NSData *encodedPayload = [algorithm encodePayload:@"payload" withSecret:@"secret"];
    [[[encodedPayload base64EncodedString] should] equal:@"KR3aqiPK+jqq4cl1U5H0vvNbvby5JzmlYYpciW9lINKw0o0tKYfayXR54xIUpR2Wz86voo5GpPlhtjxGNSoYng=="];
});

SPEC_END