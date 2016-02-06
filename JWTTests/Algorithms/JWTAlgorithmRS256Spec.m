//
//  JWTAlgorithmRS256Spec.m
//  JWT
//
//  Created by Lobanov Dmitry on 21.11.15.
//  Copyright © 2015 Karma. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Base64/MF_Base64Additions.h>

#import "JWTAlgorithmRS256.h"


SPEC_BEGIN(JWTAlgorithmRS256Spec)

__block JWTAlgorithmRS256 *algorithm;

beforeEach(^{
  algorithm = [[JWTAlgorithmRS256 alloc] init];
});

it(@"name is RS256", ^{
  [[algorithm.name should] equal:@"RS256"];
});

it(@"HMAC encodes the payload using RSA256", ^{
  NSData *encodedPayload = [algorithm encodePayload:@"payload" withSecret:@"secret"];
    
    // not implemented yet, always return nil 
    NSNumber *result  = @([encodedPayload base64String] == nil);
    [[result should] equal:@(1)];//@"uC/LeRrOxXhZuYm0MKgmSIzi5Hn9+SMmvQoug3WkK6Q="];
});

SPEC_END
