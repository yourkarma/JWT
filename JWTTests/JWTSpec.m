//
//  JWTSpec.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright 2013 Karma. All rights reserved.
//

#import "Kiwi.h"

#import "JWT.h"
#import "Base64.h"

SPEC_BEGIN(JWTSpec)

it(@"encodes JWTs", ^{
    NSString *secret = @"secret";
    NSDictionary *payload = @{@"key": @"value"};
    
    id algorithmMock = [KWMock mockForProtocol:@protocol(JWTAlgorithm)];
    
    [algorithmMock stub:@selector(name) andReturn:@"Test"];
    [[algorithmMock should] receive:@selector(encodePayload:withSecret:) andReturn:@"encoded" withArguments:@"eyJhbGciOiJUZXN0IiwidHlwZSI6IkpXVCJ9.eyJrZXkiOiJ2YWx1ZSJ9", secret];
    
    [[[JWT encodePayload:payload withSecret:secret algorithm:algorithmMock] should] equal:[@"encoded" base64EncodedString]];
});

SPEC_END


