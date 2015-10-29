//
//  JWTSpec.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright 2013 Karma. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "JWT.h"
#import "JWTAlgorithmFactory.h"
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

it(@"encodes JWTs with headers", ^{
    
    NSString *algorithmName = @"Test";
    NSString *secret = @"secret";
    NSDictionary *payload = @{@"key": @"value"};
    NSDictionary *headers = @{@"header": @"value"};
    
    NSMutableDictionary *allHeaders = [@{@"typ":@"JWT", @"alg":algorithmName} mutableCopy];
    
    [allHeaders addEntriesFromDictionary:headers];
    
    NSString *headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
    
    NSString *payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
    
    NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
    
    NSString *signedOutput = @"signed";
    
    NSString *jwt = [@[headerSegment, payloadSegment, [signedOutput base64UrlEncodedString]] componentsJoinedByString:@"."];
    
    id algorithmMock = [KWMock mockForProtocol:@protocol(JWTAlgorithm)];
    [algorithmMock stub:@selector(name) andReturn:algorithmName];
    [[algorithmMock should] receive:@selector(encodePayload:withSecret:) andReturn:signedOutput withArguments:signingInput, secret];
    
    [[[JWT encodePayload:payload withSecret:secret withHeaders:headers algorithm:algorithmMock] should] equal:jwt];
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

it(@"decodes JWTs with headers and arbitrary payloads", ^{
    
    NSString *algorithmName = @"HS256";
    NSString *secret = @"secret";
    NSDictionary *payload = @{@"key": @"value"};
    NSDictionary *headers = @{@"header" : @"value"};
    
    NSMutableDictionary *allHeaders = [@{@"typ":@"JWT", @"alg":algorithmName} mutableCopy];
    
    [allHeaders addEntriesFromDictionary:headers];
    
    NSString *headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
    
    NSString *payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
    
    NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
    
    NSString *signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
    
    NSString *jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];

    NSDictionary *info = [JWT decodeMessage:jwt withSecret:secret];
    
    NSLog(@"info is: %@", info);
    
    [[info[@"payload"] should] equal:payload];
    [[info[@"header"] should] equal:allHeaders];
});

// JWT "none" algorithm part

it(@"encodes and decodes JWT with none algorithm", ^{
    NSString *algorithmName = @"none";
    NSString *secret = @"secret";
    NSDictionary *payload = @{@"key": @"value"};
    NSDictionary *headers = @{@"header" : @"value"};

    NSMutableDictionary *allHeaders = [@{@"typ":@"JWT", @"alg":algorithmName} mutableCopy];
    
    [allHeaders addEntriesFromDictionary:headers];
    
    NSString *headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
    
    NSString *payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
    
    NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
    
    NSString *signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
    
    NSString *jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];
    
    NSDictionary *info = [JWT decodeMessage:jwt withSecret:secret];
    NSLog(@"info is: %@", info);
    
    [[info[@"payload"] should] equal:payload];
    [[info[@"header"] should] equal:allHeaders];
});

it(@"should generate errors", ^{
    NSString *secret = @"secret";
    NSString *jwt = @"jwt";
    NSError *error = nil;
    NSDictionary *info = [JWT decodeMessage:jwt withSecret:secret withError:&error];
    NSLog(@"info is: %@\n error is: %@", info, error);
    [[@(error.code) should] equal:@(JWTInvalidFormatError)];
});


it(@"decodes RS256 payload without verifying signature", ^{
    NSString *token = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.EkN-DOsnsuRjRO6BxXemmJDm3HbxrbRzXglbN2S4sOkopdU4IsDxTI8jO19W_A4K8ZPJijNLis4EZsHeY559a4DFOd50_OqgHGuERTqYZyuhtF39yxJPAjUESwxk2J5k_4zM3O-vtd1Ghyo4IbqKKSy6J9mTniYJPenn5-HIirE";
    
    NSError *decodeError = nil;
    NSDictionary *decodedToken = [JWT decodeMessage:token withSecret:nil withDoCheckSignature:FALSE withError:&decodeError];
    if (decodeError) {
        NSLog(@"Decode Error: %@", decodeError);
    }
    
    [[decodeError should] beNil];
    
    NSDictionary *expectedHeader = @{@"alg": @"RS256", @"typ": @"JWT"};
    NSDictionary *expectedPayload = @{@"admin": @TRUE, @"name": @"John Doe", @"sub": @"1234567890"};
    
    [[expectedHeader should] equal:decodedToken[@"header"]];
    [[expectedPayload should] equal:decodedToken[@"payload"]];
    
});

it(@"fails to decode RS256 payload with verifying signature", ^{
    NSString *token = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.EkN-DOsnsuRjRO6BxXemmJDm3HbxrbRzXglbN2S4sOkopdU4IsDxTI8jO19W_A4K8ZPJijNLis4EZsHeY559a4DFOd50_OqgHGuERTqYZyuhtF39yxJPAjUESwxk2J5k_4zM3O-vtd1Ghyo4IbqKKSy6J9mTniYJPenn5-HIirE";
    
    NSError *decodeError = nil;
    NSDictionary *decodedToken = [JWT decodeMessage:token withSecret:nil withDoCheckSignature:TRUE withError:&decodeError];
    if (decodeError) {
        NSLog(@"Decode Error: %@", decodeError);
    }
    [[decodedToken should] beNil];
    [[decodeError shouldNot] beNil];
});


SPEC_END


