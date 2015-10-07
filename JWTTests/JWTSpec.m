//
//  JWTSpec.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright 2013 Karma. All rights reserved.
//

#import "Kiwi.h"

#import "MF_Base64Additions.h"

#import "JWT.h"
#import "JWTClaimsSetSerializer.h"
#import "NSData+JWT.h"
#import "NSString+JWT.h"

SPEC_BEGIN(JWTSpec)

it(@"encodes JWTs with arbitrary payloads", ^{

    NSString *algorithmName = @"Test";
    NSString *secret = @"secret";
    NSDictionary *payload = @{@"key": @"value"};

    NSString *headerSegment = [[NSJSONSerialization dataWithJSONObject:@{@"typ":@"JWT", @"alg":algorithmName} options:0 error:nil] base64UrlEncodedString];
    
    NSString *payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
    
    NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
    
    NSString *signedOutput = @"signed";
    
    NSString *jwt = [@[headerSegment, payloadSegment, [signedOutput base64UrlEncodedString]] componentsJoinedByString:@"."];

    id algorithmMock = [KWMock mockForProtocol:@protocol(JWTAlgorithm)];
    [algorithmMock stub:@selector(name) andReturn:algorithmName];
    [algorithmMock stub:@selector(encodePayload:withSecret:) andReturn:signedOutput];
    [[algorithmMock should] receive:@selector(encodePayload:withSecret:) andReturn:signedOutput withArguments:signingInput, secret];
    
    [[[JWT encodePayload:payload withSecret:secret algorithm:algorithmMock] should] equal:jwt];
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
    
    NSString *algorithmName = @"Test";
    NSString *secret = @"secret";
    JWTClaimsSet *claimsSet = [JWTClaimsSetSerializer claimsSetWithDictionary:dictionary];
    
    NSString *headerSegment = [[NSJSONSerialization dataWithJSONObject:@{@"typ": @"JWT", @"alg": algorithmName} options:0 error:nil] base64UrlEncodedString];
    
    NSString *payloadSegment = [[NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil] base64UrlEncodedString];
    
    NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
    
    NSString *signedOutput = @"signed";
    
    NSString *jwt = [@[headerSegment, payloadSegment, [signedOutput base64UrlEncodedString]] componentsJoinedByString:@"."];

    id algorithmMock = [KWMock mockForProtocol:@protocol(JWTAlgorithm)];
    [algorithmMock stub:@selector(name) andReturn:algorithmName];
    [algorithmMock stub:@selector(encodePayload:withSecret:) andReturn:signedOutput];
    [[algorithmMock should] receive:@selector(encodePayload:withSecret:) andReturn:signedOutput withArguments:signingInput, secret];

    [JWTClaimsSetSerializer stub:@selector(dictionaryWithClaimsSet:) andReturn:dictionary];

    [[[JWT encodeClaimsSet:claimsSet withSecret:secret algorithm:algorithmMock] should] equal:jwt];
});

SPEC_END


