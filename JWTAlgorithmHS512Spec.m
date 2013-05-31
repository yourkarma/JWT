//
//  JWTAlgorithmHS512.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright 2013 Karma. All rights reserved.
//

#import "Kiwi.h"

#import "JWTAlgorithmHS512.h"

SPEC_BEGIN(JWTAlgorithmHS512Spec)

__block JWTAlgorithmHS512 *algorithm;

beforeEach(^{
    algorithm = [[JWTAlgorithmHS512 alloc] init];
});

it(@"name is HS512", ^{
    [[algorithm.name should] equal:@"HS512"];
});

pending(@"HMAC encodes the payload using SHA512", ^{
    
});

SPEC_END