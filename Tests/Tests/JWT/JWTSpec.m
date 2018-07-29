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

#import <Base64/MF_Base64Additions.h>

SPEC_BEGIN(JWTSpec)
describe(@"encoding", ^{
    context(@"general", ^{
        it(@"encodes JWTs with arbitrary payloads", ^{
        
        __auto_type algorithmName = @"Test";
        __auto_type secret = @"secret";
        __auto_type payload = @{@"key": @"value"};
        
        __auto_type headerSegment = [[NSJSONSerialization dataWithJSONObject:@{@"typ":@"JWT", @"alg":algorithmName} options:0 error:nil] base64UrlEncodedString];
        
        __auto_type payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
        
        __auto_type signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
        
        __auto_type signedOutput = @"signed";
        
        __auto_type jwt = [@[headerSegment, payloadSegment, [signedOutput base64UrlEncodedString]] componentsJoinedByString:@"."];
        
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
            __auto_type secret = @"secret";
            __auto_type headers = @{};
            __auto_type algorithmName = @"none";
            __auto_type signedOutput = @"oh";
            //__auto_type signingInput = @"uh";
            id algorithm = [KWMock mockForProtocol:@protocol(JWTAlgorithm)];
            [algorithm stub:@selector(name) andReturn:algorithmName];
            [algorithm stub:@selector(encodePayload:withSecret:) andReturn:signedOutput];
            //[[algorithm should] receive:@selector(encodePayload:withSecret:) andReturn:signedOutput withArguments:signingInput, secret];
            
            NSError *error = nil;
            
            __auto_type encoded = [JWT encodePayload:nil withSecret:secret withHeaders:headers algorithm:algorithm withError:&error];
            
            NSLog(@"info is: %@\n error is: %@", encoded, error);
            
            [[@(error.code) should] equal:@(JWTEncodingPayloadError)];
            //fluent
            __auto_type builder = [JWT encodePayload:nil].secret(secret).headers(headers).algorithm(algorithm);
            encoded = builder.encode;
            
            error = builder.jwtError;
            
            NSLog(@"info is: %@\n error is: %@", encoded, error);
            
            [[@(error.code) should] equal:@(JWTEncodingPayloadError)];
        });
        it(@"encode should generate mysterious signing error", ^{
            __auto_type secret = @"secret";
            __auto_type headers = @{};
            __auto_type payload = @{@"payload":@"payload"};
            __auto_type algorithmName = @"none";
            NSString *signedOutput = nil;
            //__auto_type signingInput = @"uh";
            id algorithm = [KWMock mockForProtocol:@protocol(JWTAlgorithm)];
            [algorithm stub:@selector(name) andReturn:algorithmName];
            [algorithm stub:@selector(encodePayload:withSecret:) andReturn:signedOutput];
            
            NSError *error = nil;
            __auto_type builder = [JWT encodePayload:payload].secret(secret).headers(headers).algorithm(algorithm);
            __auto_type encoded = builder.encode;
            
            error = builder.jwtError;
            NSLog(@"ERROR!");
            NSLog(@"info is: %@\n error is: %@", encoded, error);
            
            [[@(error.code) should] equal:@(JWTEncodingSigningError)];
        });
    });
    context(@"headers", ^{
        it(@"encodes JWTs with headers", ^{
        
        __auto_type algorithmName = @"Test";
        __auto_type secret = @"secret";
        __auto_type payload = @{@"key": @"value"};
        __auto_type headers = @{@"header": @"value"};
        
        __auto_type allHeaders = (NSMutableDictionary *)[@{@"typ":@"JWT", @"alg":algorithmName} mutableCopy];
        
        [allHeaders addEntriesFromDictionary:headers];
        
        __auto_type headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
        
        __auto_type payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
        
        __auto_type signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
        
        __auto_type signedOutput = @"signed";
        
        __auto_type jwt = [@[headerSegment, payloadSegment, [signedOutput base64UrlEncodedString]] componentsJoinedByString:@"."];
        
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
        __auto_type dictionary = @{
                                     @"iss": @"Facebook",
                                     @"sub": @"Token",
                                     @"aud": @"https://jwt.io",
                                     @"exp": @(64092211200),
                                     @"nbf": @(-62135769600),
                                     @"iat": @(1370005175.80196),
                                     @"jti": @"thisisunique",
                                     @"typ": @"test",
                                     @"scope": @"https://www.googleapis.com/auth/devstorage.read_write"
                                     };
        
        __auto_type algorithmName = @"Test";
        __auto_type secret = @"secret";
        __auto_type claimsSet = [JWTClaimsSetSerializer claimsSetWithDictionary:dictionary];
        
        __auto_type headerSegment = [[NSJSONSerialization dataWithJSONObject:@{@"typ": @"JWT", @"alg": algorithmName} options:0 error:nil] base64UrlEncodedString];

        __auto_type payloadSegment = [[NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil] base64UrlEncodedString];

        __auto_type signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
        
        __auto_type signedOutput = @"signed";
        
        __auto_type jwt = [@[headerSegment, payloadSegment, [signedOutput base64UrlEncodedString]] componentsJoinedByString:@"."];
        
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
        it(@"encodes and decodes JWT with none algorithm & nil secret", ^{
            __auto_type algorithmName = @"none";
            NSString *secret = nil;
            __auto_type payload = @{@"key": @"value"};
            __auto_type headers = @{@"header" : @"value"};
            
            __auto_type allHeaders = (NSMutableDictionary *)[@{@"typ":@"JWT", @"alg":algorithmName} mutableCopy];
            
            [allHeaders addEntriesFromDictionary:headers];
            
            __auto_type headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
            
            __auto_type payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
            
            __auto_type signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
            
            __auto_type signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
            
            __auto_type jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];
            
            __auto_type info = [JWT decodeMessage:jwt withSecret:secret withError:nil withForcedAlgorithmByName:algorithmName];
            NSLog(@"info is: %@", info);
            
            [[info[@"payload"] should] equal:payload];
            [[info[@"header"] should] equal:allHeaders];

            // fluent
            info = [JWT decodeMessage:jwt].secret(secret).algorithmName(algorithmName).decode;
            NSLog(@"info is: %@", info);
            
            [[info[@"payload"] should] equal:payload];
            [[info[@"header"] should] equal:allHeaders];
        });
        
        it(@"encodes and decodes JWT with none algorithm & blank secret", ^{
            __auto_type algorithmName = @"none";
            __auto_type secret = @"";
            __auto_type payload = @{@"key": @"value"};
            __auto_type headers = @{@"header" : @"value"};
            
            __auto_type allHeaders = (NSMutableDictionary *)[@{@"typ":@"JWT", @"alg":algorithmName} mutableCopy];
            
            [allHeaders addEntriesFromDictionary:headers];
            
            __auto_type headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
            
            __auto_type payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
            
            __auto_type signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
            
            __auto_type signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
            
            __auto_type jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];
            
            __auto_type info = [JWT decodeMessage:jwt withSecret:secret withError:nil withForcedAlgorithmByName:algorithmName];
            NSLog(@"info is: %@", info);
            
            [[info[@"payload"] should] equal:payload];
            [[info[@"header"] should] equal:allHeaders];
            
            // fluent
            info = [JWT decodeMessage:jwt].secret(secret).algorithmName(algorithmName).decode;
            NSLog(@"info is: %@", info);
            
            [[info[@"payload"] should] equal:payload];
            [[info[@"header"] should] equal:allHeaders];
        });
        
        it(@"fails to decoded JWT with none algorithm when secret specified", ^{
            __auto_type algorithmName = @"none";
            __auto_type secret = @"secret";
            __auto_type payload = @{@"key": @"value"};
            __auto_type headers = @{@"header" : @"value"};
            
            __auto_type allHeaders = (NSMutableDictionary *)[@{@"typ":@"JWT", @"alg":algorithmName} mutableCopy];
            
            [allHeaders addEntriesFromDictionary:headers];
            
            __auto_type headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
            
            __auto_type payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
            
            __auto_type signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
            
            __auto_type signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
            
            __auto_type jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];
            
            __auto_type info = [JWT decodeMessage:jwt withSecret:secret];
            NSLog(@"info is: %@", info);
            
            [[info[@"payload"] should] beNil];
            [[info[@"header"] should] beNil];
            
            // fluent
            info = [JWT decodeMessage:jwt].secret(secret).decode;
            NSLog(@"info is: %@", info);
            
            [[info[@"payload"] should] beNil];
            [[info[@"header"] should] beNil];
        });

    });
});

describe(@"decoding", ^{
    context(@"general", ^{
        it(@"decodes JWTs with headers and arbitrary payloads", ^{
            
            __auto_type algorithmName = @"HS512";
            __auto_type secret = @"secret";
            __auto_type payload = @{@"key": @"value"};
            __auto_type headers = @{@"header" : @"value"};
            
            __auto_type allHeaders = (NSMutableDictionary *)[@{@"typ":@"JWT", @"alg":algorithmName} mutableCopy];
            
            [allHeaders addEntriesFromDictionary:headers];
            
            __auto_type headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
            
            __auto_type payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
            
            __auto_type signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
            
            __auto_type signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
            
            __auto_type jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];
            
            __auto_type info = [JWT decodeMessage:jwt withSecret:secret];
            
            NSLog(@"info is: %@", info);
            
            [[info[@"payload"] should] equal:payload];
            [[info[@"header"] should] equal:allHeaders];

            //fluent
            info = [JWT decodeMessage:jwt].secret(secret).algorithmName(algorithmName).decode;
            
            NSLog(@"info is: %@", info);
            
            [[info[@"payload"] should] equal:payload];
            [[info[@"header"] should] equal:allHeaders];
        });
        
        it(@"decode should fail if algorithm type isn't specified", ^{
            __auto_type secret = @"secret";
            __auto_type message = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
            
            NSError *error = nil;
            NSDictionary *decoded = nil;
            
            decoded = [JWT decodeMessage:message withSecret:secret withError:&error withForcedAlgorithmByName:nil];
            
            [[error shouldNot] beNil];
            [[theValue(error.code) should] equal:theValue(JWTUnspecifiedAlgorithmError)];
            [[decoded should] beNil];
            
            decoded = nil;
            error = nil;
            
            __auto_type claimsSet = [[JWTClaimsSet alloc] init];
            
            decoded = [JWT decodeMessage:message withSecret:secret withTrustedClaimsSet:claimsSet withError:&error withForcedAlgorithmByName:nil];
            
            [[error shouldNot] beNil];
            [[theValue(error.code) should] equal:theValue(JWTUnspecifiedAlgorithmError)];
            [[decoded should] beNil];
        });
        
    });
    
    context(@"errors", ^{
        it(@"decode should generate errors", ^{
            __auto_type secret = @"secret";
            __auto_type jwt = @"jwt";
            NSError *error = nil;
            __auto_type info = [JWT decodeMessage:jwt withSecret:secret withError:&error];
            NSLog(@"info is: %@\n error is: %@", info, error);
            [[@(error.code) should] equal:@(JWTInvalidFormatError)];

            //fluent
            error = nil;
            __auto_type builder = [JWT decodeMessage:jwt];
            info = builder.secret(secret).decode;
            error = builder.jwtError;
            NSLog(@"info is: %@\n error is: %@", info, error);
            [[@(error.code) should] equal:@(JWTInvalidFormatError)];
        });
    });
    
    context(@"forced option", ^{
        it(@"decode message forced option works correctly", ^{
            __auto_type algorithmName = @"HS256";
            __auto_type secret = @"secret";
            __auto_type payload = @{@"key": @"value"};
            __auto_type headers = @{@"header" : @"value"};
            
            __auto_type allHeaders = (NSMutableDictionary *)[@{@"typ":@"JWT", @"alg":@"HS16"} mutableCopy];
            
            [allHeaders addEntriesFromDictionary:headers];
            
            __auto_type headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
            
            __auto_type payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
            
            __auto_type signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
            
            __auto_type signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
            
            __auto_type jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];
            
            
            NSError *forcedError = nil;
            __auto_type forcedInfo = [JWT decodeMessage:jwt withSecret:secret withError:&forcedError withForcedAlgorithmByName:algorithmName skipVerification:YES];
            
            NSLog(@"forcedInfo is: %@ forcedError: %@", forcedInfo, forcedError);
            
            [[forcedInfo[@"payload"] should] equal:payload];
            [[forcedInfo[@"header"] should] equal:allHeaders];
            
            NSError *error = nil;
            __auto_type info = [JWT decodeMessage:jwt withSecret:secret withError:&error withForcedAlgorithmByName:algorithmName skipVerification:NO];
            
            NSLog(@"info is: %@ error: %@", info, error);
            [[@(error.code) should] equal:@(JWTUnsupportedAlgorithmError)];

            //fluent
            error = nil;
            __auto_type builder = [JWT decodeMessage:jwt];
            info = builder.secret(secret).options(@NO).algorithmName(algorithmName).decode;
            error = builder.jwtError;
            NSLog(@"info is: %@ error: %@", info, error);
            [[@(error.code) should] equal:@(JWTAlgorithmNameMismatchError)];
        });
        
        it(@"decode should generate errors on unsupported algorithms without forced option", ^{
            __auto_type algorithmName = @"HS256";
            __auto_type secret = @"secret";
            __auto_type payload = @{@"key": @"value"};
            __auto_type headers = @{@"header" : @"value"};
            
            __auto_type allHeaders = (NSMutableDictionary *)[@{@"typ":@"JWT", @"alg":@"HS16"} mutableCopy];
            
            [allHeaders addEntriesFromDictionary:headers];
            
            __auto_type headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
            
            __auto_type payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
            
            __auto_type signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
            
            __auto_type signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
            
            __auto_type jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];
            
            __auto_type info = [JWT decodeMessage:jwt withSecret:secret];
            
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
        pending(@"decode claims set and verify it correctly", ^{
            __auto_type algorithmName = @"HS256";
            __auto_type secret = @"secret";
            __auto_type claimsSet = [[JWTClaimsSet alloc] init];
            claimsSet.issuer = @"Facebook";
            claimsSet.subject = @"Token";
            claimsSet.audience = @"https://jwt.io";
            claimsSet.expirationDate = [NSDate distantFuture];
            claimsSet.notBeforeDate = [NSDate distantPast];
            claimsSet.issuedAt = [NSDate date];
            claimsSet.identifier = @"thisisunique";
            claimsSet.type = @"test";
            claimsSet.scope = @"https://www.googleapis.com/auth/devstorage.read_write";
            
            
            __auto_type payload = [JWTClaimsSetSerializer dictionaryWithClaimsSet:claimsSet];//@{@"key": @"value"};
            __auto_type headers = @{@"header" : @"value"};
            
            __auto_type allHeaders = (NSMutableDictionary *)[@{@"typ":@"JWT", @"alg":algorithmName} mutableCopy];
            
            [allHeaders addEntriesFromDictionary:headers];
            
            __auto_type headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
            
            __auto_type payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
            
            __auto_type signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
            
            __auto_type signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
            
            __auto_type jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];
            __auto_type trustedClaimsSet = (typeof(claimsSet))claimsSet.copy;
            trustedClaimsSet.expirationDate = [NSDate date];
            trustedClaimsSet.notBeforeDate = [NSDate date];
            trustedClaimsSet.issuedAt = [NSDate date];
            __auto_type builder = [JWT decodeMessage:jwt].secret(secret).claimsSet(trustedClaimsSet).algorithmName(algorithmName);
            __auto_type info = builder.decode;
            
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
            __auto_type algorithmName = @"HS256";
            __auto_type secret = @"secret";
            __auto_type payload = @{@"key": @"value"};
            __auto_type headers = @{@"header" : @"value"};
            
            __auto_type allHeaders = (NSMutableDictionary *)[@{@"typ":@"JWT", @"alg":algorithmName} mutableCopy];
            
            [allHeaders addEntriesFromDictionary:headers];
            
            __auto_type headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
            
            __auto_type payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
            
            __auto_type signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
            
            __auto_type signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
            
            __auto_type jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];
            __auto_type info = [JWT decodeMessage:jwt].secret(secret).algorithmName(algorithmName).decode;
            
            NSLog(@"info is: %@", info);
            
            [[info[@"payload"] should] equal:payload];
            [[info[@"header"] should] equal:allHeaders];
        });
    });
    context(@"long tokens", ^{
        it(@"it should encode tons of data in payload corretly", ^{
            [[@(1) shouldNot] beNil];
            __auto_type dictionary = @{
                                         @"new": @"item"
                                         };
            
            // oh :/
            NSInteger expectedCount = 100;
            __auto_type array = [NSMutableArray array];
            for (NSInteger i = 0; i < expectedCount; ++i) {
                array[array.count] = [dictionary copy];
            }
            
            __auto_type payload = @{ @"data" : array };
            
            __auto_type secret = @"secret";
            __auto_type builder = [JWTBuilder encodePayload:payload].secret(secret).algorithmName(@"HS256");
            __auto_type encode = builder.encode;
            NSLog(@"LONG: %@ and ERROR: %@", encode, builder.jwtError);
            [[encode shouldNot] beNil];
            [[builder.jwtError should] beNil];
        });
        it(@"it should decode tons of data correctly", ^{
            __auto_type dictionary = @{
                                         @"new": @"item"
                                         };
            
            // oh :/
            NSInteger expectedCount = 1000;
            __auto_type array = [NSMutableArray array];
            for (NSInteger i = 0; i < expectedCount; ++i) {
                array[array.count] = [dictionary copy];
            }
            
            __auto_type payload = @{ @"data" : array };
            
            __auto_type secret = @"secret";
            __auto_type encodeBuilder = [JWTBuilder encodePayload:payload].secret(secret).algorithmName(@"HS256");
            __auto_type encode = encodeBuilder.encode;
            NSLog(@"LONG: %@ and ERROR: %@", encode, encodeBuilder.jwtError);
            [[encode shouldNot] beNil];
            [[encodeBuilder.jwtError should] beNil];
            
            __auto_type decodeBuilder = [JWTBuilder decodeMessage:encode].algorithmName(@"HS256").secret(secret);
            __auto_type decoded = decodeBuilder.decode;
            __auto_type decodedPayload = (NSDictionary *)decoded[@"payload"];
            
            [[decodedPayload shouldNot] beNil];
            [[decodedPayload[@"data"] should] beKindOfClass:[NSArray class]];
            [[@([decodedPayload[@"data"] count]) should] equal:@(expectedCount)];
            
            [[decodeBuilder.jwtError should] beNil];
        });
    });
});

describe(@"Whitelist tests", ^{
    it(@"Enabling whitelist should enforce whitelist algorithms", ^{
        __auto_type algorithmName = @"HS256";
        __auto_type secret = @"secret";
        __auto_type message = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
        
        
        __auto_type expectedHeader = @{
                                         @"alg": @"HS256",
                                         @"typ": @"JWT"
                                         };
        __auto_type expectedPayload = @{
                                          @"sub": @"1234567890",
                                          @"name": @"John Doe",
                                          @"admin": @(YES)
                                          };
        
        __auto_type builder = [JWT decodeMessage:message].algorithmName(algorithmName).secret(secret).whitelist(@[]);
        
        __auto_type decoded = builder.decode;
        
        [[builder.jwtError shouldNot] beNil];
        [[theValue(builder.jwtError.code) should] equal:theValue(JWTBlacklistedAlgorithmError)];
        [[decoded should] beNil];
        

        builder = [JWT decodeMessage:message].algorithmName(algorithmName).secret(secret).whitelist(@[algorithmName]);
        decoded = builder.decode;
        
        [[builder.jwtError should] beNil];
        [[decoded shouldNot] beNil];
        __auto_type header = (NSDictionary *)[decoded objectForKey:@"header"];
        __auto_type payload = (NSDictionary *)[decoded objectForKey:@"payload"];
        
        [[theValue([header isEqualToDictionary:expectedHeader]) should] beTrue];
        [[theValue([payload isEqualToDictionary:expectedPayload]) should] beTrue];
        
    });
    it(@"Using whitelist should be optional", ^{
        __auto_type algorithmName = @"HS256";
        __auto_type secret = @"secret";
        __auto_type message = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
        
        
        __auto_type expectedHeader = @{
                                         @"alg": @"HS256",
                                         @"typ": @"JWT"
                                         };
        __auto_type expectedPayload = @{
                                          @"sub": @"1234567890",
                                          @"name": @"John Doe",
                                          @"admin": @(YES)
                                          };
        
        __auto_type builder = [JWT decodeMessage:message].algorithmName(algorithmName).secret(secret);
        
        __auto_type decoded = builder.decode;
        
        [[builder.jwtError should] beNil];
        [[decoded shouldNot] beNil];
        
        __auto_type header = (NSDictionary *)[decoded objectForKey:@"header"];
        __auto_type payload = (NSDictionary *)[decoded objectForKey:@"payload"];
        
        [[theValue([header isEqualToDictionary:expectedHeader]) should] beTrue];
        [[theValue([payload isEqualToDictionary:expectedPayload]) should] beTrue];
    });
    it(@"Whitelist should be enforced", ^{
        __auto_type algorithmName = @"HS256";
        __auto_type secret = @"secret";
        __auto_type message = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
        
        __auto_type builder = [JWT decodeMessage:message].algorithmName(algorithmName).secret(secret).whitelist(@[@"HS512"]);
        
        __auto_type decoded = builder.decode;
        
        [[builder.jwtError shouldNot] beNil];
        [[theValue(builder.jwtError.code) should] equal:theValue(JWTBlacklistedAlgorithmError)];
        [[decoded should] beNil];
        
    });
    it(@"Whitelist algorithms should still be able to fail verification", ^{
        __auto_type algorithmName = @"HS512";
        __auto_type secret = @"secret";
        //Incorrect signature
        __auto_type message = @"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
        
        __auto_type builder = [JWT decodeMessage:message].algorithmName(algorithmName).secret(secret).whitelist(@[algorithmName]);
        
        __auto_type decoded = builder.decode;
        
        [[builder.jwtError shouldNot] beNil];
        [[theValue(builder.jwtError.code) should] equal:theValue(JWTInvalidSignatureError)];
        [[decoded should] beNil];
    });
    it(@"Whitelist algorithms should be applied to jwt if no algorithm name passed", ^{
        __auto_type algorithmName = @"HS256";
        __auto_type secret = @"secret";
        //Incorrect signature
        __auto_type message = @"eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.";
        
        __auto_type builder = [JWT decodeMessage:message].secret(secret).whitelist(@[algorithmName, @"none"]);
        
        __auto_type decoded = builder.decode;
        
        [[builder.jwtError should] beNil];
        [[decoded shouldNot] beNil];
    });
});

describe(@"Header tests", ^{
    it(@"Header alg mismatch should fail verify", ^{
        __auto_type algorithmName = @"HS256";
        __auto_type secret = @"secret";
        //Header specifies HS512
        __auto_type message = @"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";

        
        __auto_type builder = [JWT decodeMessage:message].algorithmName(algorithmName).secret(secret);
        
        __auto_type decoded = builder.decode;
        
        [[builder.jwtError shouldNot] beNil];
        [[theValue(builder.jwtError.code) should] equal:theValue(JWTAlgorithmNameMismatchError)];
        [[decoded should] beNil];
    });
});

describe(@"secretData tests", ^{
    it(@"should decode with data", ^{
        __auto_type algorithmName = @"HS256";
        __auto_type secret = @"secret";
        __auto_type secretData = [NSData dataWithBase64String:[secret base64String]];
        __auto_type message = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
        
        
        __auto_type expectedHeader = @{
                                         @"alg": @"HS256",
                                         @"typ": @"JWT"
                                         };
        __auto_type expectedPayload = @{
                                          @"sub": @"1234567890",
                                          @"name": @"John Doe",
                                          @"admin": @(YES)
                                          };
        
        __auto_type builder = [JWTBuilder decodeMessage:message].algorithmName(algorithmName).secretData(secretData);
        
        __auto_type decoded = builder.decode;
        
        [[builder.jwtError should] beNil];
        [[decoded shouldNot] beNil];
        __auto_type header = (NSDictionary *)[decoded objectForKey:@"header"];
        __auto_type payload = (NSDictionary *)[decoded objectForKey:@"payload"];
        
        [[theValue([header isEqualToDictionary:expectedHeader]) should] beTrue];
        [[theValue([payload isEqualToDictionary:expectedPayload]) should] beTrue];
    });
    it(@"should encode arbitary payloads", ^ {
        __auto_type algorithmName = @"Test";
        __auto_type secret = @"secret";
        __auto_type secretData = [NSData dataWithBase64String:[secret base64String]];
        __auto_type payload = @{@"key": @"value"};
        
        __auto_type headerSegment = [[NSJSONSerialization dataWithJSONObject:@{@"typ":@"JWT", @"alg":algorithmName} options:0 error:nil] base64UrlEncodedString];
        
        __auto_type payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
        
        __auto_type signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
        
        __auto_type signingInputData = [NSData dataWithBase64UrlEncodedString:[signingInput base64UrlEncodedString]];
        
        __auto_type signedOutput = @"signed";
        
        __auto_type jwt = [@[headerSegment, payloadSegment, [signedOutput base64UrlEncodedString]] componentsJoinedByString:@"."];
        
        id algorithmMock = [KWMock mockForProtocol:@protocol(JWTAlgorithm)];
        [algorithmMock stub:@selector(name) andReturn:algorithmName];
        [algorithmMock stub:@selector(encodePayloadData:withSecret:) andReturn:signedOutput];

        [[algorithmMock should] receive:@selector(encodePayloadData:withSecret:) andReturn:signedOutput withCount:1 arguments:signingInputData, secretData];
        
        [[[JWTBuilder encodePayload:payload].secretData(secretData).algorithm(algorithmMock).encode should] equal:jwt];
    });
});

SPEC_END




