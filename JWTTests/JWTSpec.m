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

describe(@"encoding", ^{
    context(@"general", ^{
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
//        [[algorithmMock should] receive:@selector(encodePayload:withSecret:) andReturn:signedOutput withArguments:signingInput, secret];
        [[algorithmMock should] receive:@selector(encodePayload:withSecret:) andReturn:signedOutput withCount:2 arguments:signingInput, secret];

        
        [[[JWT encodePayload:payload withSecret:secret algorithm:algorithmMock] should] equal:jwt];

        [[[JWT encodePayload:payload].secret(secret).algorithm(algorithmMock).encode should] equal:jwt];
        });
    });
    context(@"errors", ^{
    it(@"encode should generate errors", ^{
            NSString *secret = @"secret";
            NSDictionary *headers = @{};
            NSString *algorithmName = @"none";
            NSString *signedOutput = @"oh";
            //NSString *signingInput = @"uh";
            id algorithm = [KWMock mockForProtocol:@protocol(JWTAlgorithm)];
            [algorithm stub:@selector(name) andReturn:algorithmName];
            [algorithm stub:@selector(encodePayload:withSecret:) andReturn:signedOutput];
            //[[algorithm should] receive:@selector(encodePayload:withSecret:) andReturn:signedOutput withArguments:signingInput, secret];
            
            NSError *error = nil;
            
            NSString *encoded = [JWT encodePayload:nil withSecret:secret withHeaders:headers algorithm:algorithm withError:&error];
            
            NSLog(@"info is: %@\n error is: %@", encoded, error);
            
            [[@(error.code) should] equal:@(JWTEncodingPayloadError)];
            //fluent            
            JWTBuilder *builder = [JWT encodePayload:nil].secret(secret).headers(headers).algorithm(algorithm);
            encoded = builder.encode;

            error = builder.jwtError;

            NSLog(@"info is: %@\n error is: %@", encoded, error);

            [[@(error.code) should] equal:@(JWTEncodingPayloadError)];
        });
        });
    context(@"headers", ^{
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
        [[algorithmMock should] receive:@selector(encodePayload:withSecret:) andReturn:signedOutput withCount:2 arguments:signingInput, secret];
//        [[algorithmMock should] receive:@selector(encodePayload:withSecret:) andReturn:signedOutput withArguments:signingInput, secret];
        
        [[[JWT encodePayload:payload withSecret:secret withHeaders:headers algorithm:algorithmMock] should] equal:jwt];
        //fluent
        [[[JWT encodePayload:payload].secret(secret).headers(headers).algorithm(algorithmMock).encode should] equal:jwt];
        });
    });

    context(@"claims set", ^{
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
//        [[algorithmMock should] receive:@selector(encodePayload:withSecret:) andReturn:signedOutput withArguments:signingInput, secret];
        
        [[algorithmMock should] receive:@selector(encodePayload:withSecret:) andReturn:signedOutput withCount:2 arguments:signingInput, secret];
        
        [JWTClaimsSetSerializer stub:@selector(dictionaryWithClaimsSet:) andReturn:dictionary];
        
        [[[JWT encodeClaimsSet:claimsSet withSecret:secret algorithm:algorithmMock] should] equal:jwt];
        //fluent
        [[[JWT encodeClaimsSet:claimsSet].secret(secret).algorithm(algorithmMock).encode should] equal:jwt];
        });
    });
    
    context(@"none algorithm", ^{
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

        // fluent
        info = [JWT decodeMessage:jwt].secret(secret).decode;
        NSLog(@"info is: %@", info);
        
        [[info[@"payload"] should] equal:payload];
        [[info[@"header"] should] equal:allHeaders];
        });
    });
});

describe(@"decoding", ^{
    context(@"general", ^{
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

            //fluent
            info = [JWT decodeMessage:jwt].secret(secret).decode;
            
            NSLog(@"info is: %@", info);
            
            [[info[@"payload"] should] equal:payload];
            [[info[@"header"] should] equal:allHeaders];
        });
    });
    
    context(@"errors", ^{
        it(@"decode should generate errors", ^{
            NSString *secret = @"secret";
            NSString *jwt = @"jwt";
            NSError *error = nil;
            NSDictionary *info = [JWT decodeMessage:jwt withSecret:secret withError:&error];
            NSLog(@"info is: %@\n error is: %@", info, error);
            [[@(error.code) should] equal:@(JWTInvalidFormatError)];

            //fluent
            error = nil;
            JWTBuilder *builder = [JWT decodeMessage:jwt];
            info = builder.secret(secret).decode;
            error = builder.jwtError;
            NSLog(@"info is: %@\n error is: %@", info, error);
            [[@(error.code) should] equal:@(JWTInvalidFormatError)];
        });
    });
    
    context(@"forced option", ^{
        it(@"decode message forced option works correctly", ^{
            NSString *algorithmName = @"HS256";
            NSString *secret = @"secret";
            NSDictionary *payload = @{@"key": @"value"};
            NSDictionary *headers = @{@"header" : @"value"};
            
            NSMutableDictionary *allHeaders = [@{@"typ":@"JWT", @"alg":@"HS16"} mutableCopy];
            
            [allHeaders addEntriesFromDictionary:headers];
            
            NSString *headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
            
            NSString *payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
            
            NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
            
            NSString *signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
            
            NSString *jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];
            
            
            NSError *forcedError = nil;
            NSDictionary *forcedInfo = [JWT decodeMessage:jwt withSecret:secret withError:&forcedError withForcedOption:YES];
            
            NSLog(@"forcedInfo is: %@ forcedError: %@", forcedInfo, forcedError);
            
            [[forcedInfo[@"payload"] should] equal:payload];
            [[forcedInfo[@"header"] should] equal:allHeaders];
            
            NSError *error = nil;
            NSDictionary *info = [JWT decodeMessage:jwt withSecret:secret withError:&error withForcedOption:NO];
            
            NSLog(@"info is: %@ error: %@", info, error);
            [[@(error.code) should] equal:@(JWTUnsupportedAlgorithmError)];

            //fluent
            error = nil;
            JWTBuilder *builder = [JWT decodeMessage:jwt];
            info = builder.secret(secret).options(@NO).decode;
            error = builder.jwtError;
            NSLog(@"info is: %@ error: %@", info, error);
            [[@(error.code) should] equal:@(JWTUnsupportedAlgorithmError)];
        });
        
        it(@"decode should generate errors on unsupported algorithms without forced option", ^{
            NSString *algorithmName = @"HS256";
            NSString *secret = @"secret";
            NSDictionary *payload = @{@"key": @"value"};
            NSDictionary *headers = @{@"header" : @"value"};
            
            NSMutableDictionary *allHeaders = [@{@"typ":@"JWT", @"alg":@"HS16"} mutableCopy];
            
            [allHeaders addEntriesFromDictionary:headers];
            
            NSString *headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
            
            NSString *payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
            
            NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
            
            NSString *signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
            
            NSString *jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];
            
            NSDictionary *info = [JWT decodeMessage:jwt withSecret:secret];
            
            NSLog(@"info is: %@", info);
            BOOL notDecoded = info == nil;
            [[@(notDecoded) should] equal:@(1)];

            info = [JWT decodeMessage:jwt].secret(secret).decode;            
            NSLog(@"info is: %@", info);
            notDecoded = info == nil;
            [[@(notDecoded) should] equal:@(1)];
        });
    });
    context(@"claims set", ^{
        it(@"decode claims set and verify it correctly", ^{
            NSString *algorithmName = @"HS256";
            NSString *secret = @"secret";
            JWTClaimsSet *claimsSet = [[JWTClaimsSet alloc] init];
            claimsSet.issuer = @"Facebook";
            claimsSet.subject = @"Token";
            claimsSet.audience = @"http://yourkarma.com";
            claimsSet.expirationDate = [NSDate distantFuture];
            claimsSet.notBeforeDate = [NSDate distantPast];
            claimsSet.issuedAt = [NSDate date];
            claimsSet.identifier = @"thisisunique";
            claimsSet.type = @"test";
            
            NSDictionary *payload = [JWTClaimsSetSerializer dictionaryWithClaimsSet:claimsSet];//@{@"key": @"value"};
            NSDictionary *headers = @{@"header" : @"value"};
            
            NSMutableDictionary *allHeaders = [@{@"typ":@"JWT", @"alg":algorithmName} mutableCopy];
            
            [allHeaders addEntriesFromDictionary:headers];
            
            NSString *headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
            
            NSString *payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
            
            NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
            
            NSString *signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
            
            NSString *jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];
            JWTClaimsSet *trustedClaimsSet = claimsSet.copy;
            trustedClaimsSet.expirationDate = [NSDate date];
            trustedClaimsSet.notBeforeDate = [NSDate date];
            trustedClaimsSet.issuedAt = [NSDate date];
            JWTBuilder *builder = [JWT decodeMessage:jwt].secret(secret).claimsSet(trustedClaimsSet);
            NSDictionary *info = builder.decode;
            
            NSLog(@"info is: %@", info);
            NSLog(@"error is: %@", builder.jwtError);
            
            BOOL noError = builder.jwtError == nil;
            
            [[@(noError) should] equal:@(YES)];
            [[info[@"payload"] should] equal:payload];
            [[info[@"header"] should] equal:allHeaders];
        });
    });
    context(@"builder", ^{
        it(@"decode by builder", ^{
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
            NSDictionary *info = [JWT decodeMessage:jwt].secret(secret).decode;
            
            NSLog(@"info is: %@", info);
            
            [[info[@"payload"] should] equal:payload];
            [[info[@"header"] should] equal:allHeaders];
        });
    });
});

SPEC_END




