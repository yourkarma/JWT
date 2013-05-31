//
//  JWTSpec.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright 2013 Karma. All rights reserved.
//

#import "Kiwi.h"

#import "Base64.h"

#import "JWT.h"
#import "JWTClaimsSetSerializer.h"

SPEC_BEGIN(JWTSpec)

it(@"encodes JWTs with arbitrary payloads", ^{
    NSString *secret = @"secret";
    NSDictionary *payload = @{@"key": @"value"};
    
    id algorithmMock = [KWMock mockForProtocol:@protocol(JWTAlgorithm)];
    [algorithmMock stub:@selector(name) andReturn:@"Test"];
    [[algorithmMock should] receive:@selector(encodePayload:withSecret:) andReturn:@"encoded" withArguments:@"eyJhbGciOiJUZXN0IiwidHlwZSI6IkpXVCJ9.eyJrZXkiOiJ2YWx1ZSJ9", secret];
    
    [[[JWT encodePayload:payload withSecret:secret algorithm:algorithmMock] should] equal:[@"encoded" base64EncodedString]];
});

it(@"encodes JWTs with JWTClaimsSet payloads", ^{
    NSDictionary *dictionary = @{
        @"iss": @"Facebook",
        @"sub": @"Token",
        @"aud": @"http://yourkarma.com",
        @"exp": @(64092211200),
        @"nbf": @(-62135769600),
        @"iat": @(1370005175.80196),
        @"jti": @"thisisunique",
        @"typ": @"test"
    };
    JWTClaimsSet *claimsSet = [JWTClaimsSetSerializer claimsSetWithDictionary:dictionary];
    
    NSString *headerSegment = [[NSJSONSerialization dataWithJSONObject:@{@"type": @"JWT", @"alg": @"Test"} options:0 error:nil] base64EncodedString];
    NSString *payloadSegment = [[NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil] base64EncodedString];
    NSString *segments = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];

    id algorithmMock = [KWMock mockForProtocol:@protocol(JWTAlgorithm)];
    [algorithmMock stub:@selector(name) andReturn:@"Test"];
    [[algorithmMock should] receive:@selector(encodePayload:withSecret:) andReturn:@"encoded" withArguments:segments, @"secret"];
    
    [JWTClaimsSetSerializer stub:@selector(dictionaryWithClaimsSet:) andReturn:dictionary];

    [[[JWT encodeClaimsSet:claimsSet withSecret:@"secret" algorithm:algorithmMock] should] equal:[@"encoded" base64EncodedString]];
});

SPEC_END


