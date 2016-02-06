//
//  JWTAlgorithmHS384Spec.m
//  JWT
//
//  Created by Lobanov Dmitry on 06-02-16.
//  Copyright (c) 2016 lolgear. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Base64/MF_Base64Additions.h>

#import "JWTAlgorithmHS384.h"


SPEC_BEGIN(JWTAlgorithmHS384Spec)

__block JWTAlgorithmHS384 *algorithm;

beforeEach(^{
    algorithm = [[JWTAlgorithmHS384 alloc] init];
});

it(@"name is HS384", ^{
    [[algorithm.name should] equal:@"HS384"];
});

it(@"HMAC encodes the payload using SHA384", ^{
    NSData *encodedPayload = [algorithm encodePayload:@"payload" withSecret:@"secret"];
    [[[encodedPayload base64String] should] equal:@"s62aZf5ZLMSvjtBQpY4kiJbYxSu8wLAUop2D9nod5Eqgd+nyUCEj+iaDuVuI4gaJ"];
});

SPEC_END