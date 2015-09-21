//
//  JWTAlgorithmHS512.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright 2013 Karma. All rights reserved.
//

#import "Kiwi.h"

#import "JWTAlgorithmHS256.h"
#import "MF_Base64Additions.h"

SPEC_BEGIN(JWTAlgorithmHS256Spec)

__block JWTAlgorithmHS256 *algorithm;

beforeEach(^{
    algorithm = [[JWTAlgorithmHS256 alloc] init];
});

it(@"name is HS256", ^{
    [[algorithm.name should] equal:@"HS256"];
});

it(@"HMAC encodes the payload using SHA256", ^{
    NSData *encodedPayload = [algorithm encodePayload:@"payload" withSecret:@"secret"];
    [[[encodedPayload base64String] should] equal:@"uC/LeRrOxXhZuYm0MKgmSIzi5Hn9+SMmvQoug3WkK6Q="];
});

SPEC_END