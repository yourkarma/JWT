//
//  JWTSpec.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright 2013 Karma. All rights reserved.
//

#import "Kiwi.h"

#import "JWT.h"

SPEC_BEGIN(JWTSpec)

it(@"encodes JWTs", ^{
    NSString *secret = @"secret";
    NSDictionary *payload = @{@"key": @"value"};
    
    id algorithmMock = [KWMock mockForProtocol:@protocol(JWTAlgorithm)];
    
    [[algorithmMock should] receive:@selector(encodePayload:withSecret:) andReturn:@"encoded" withArguments:any(), secret];
    
    [[[JWT encodePayload:payload withSecret:secret algorithm:algorithmMock] should] equal:@"encoded"];
});

SPEC_END


