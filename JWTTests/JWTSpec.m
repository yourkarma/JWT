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

beforeEach(^{
    [JWT setWhitelistEnabled:NO];
});

describe(@"markdown examples", ^{
    it(@"fluent example should work correctly", ^{
        // suppose, that you create ClaimsSet
        JWTClaimsSet *claimsSet = [[JWTClaimsSet alloc] init];
        // fill it
        claimsSet.issuer = @"Facebook";
        claimsSet.subject = @"Token";
        claimsSet.audience = @"http://yourkarma.com";
        
        // encode it
        NSString *secret = @"secret";
        NSString *algorithmName = @"HS384";
        NSDictionary *headers = @{@"custom":@"value"};
        JWTBuilder *encodeBuilder = [JWT encodeClaimsSet:claimsSet];
        NSString *encodedResult = encodeBuilder.secret(secret).algorithmName(algorithmName).headers(headers).encode;
        
        if (encodeBuilder.jwtError) {
            // handle error
            NSLog(@"encode failed, error: %@", encodeBuilder.jwtError);
        }
        else {
            // handle encoded result
            NSLog(@"encoded result: %@", encodedResult);
        }
        
        // decode it
        // you can set any property that you want, all properties are optional
        JWTClaimsSet *trustedClaimsSet = [claimsSet copy];
        
        // decode forced ? try YES
        BOOL decodeForced = NO;
        NSNumber *options = @(decodeForced);
        NSString *yourJwt = encodedResult; // from previous example
        NSString *yourSecret = secret; // from previous example
        JWTBuilder *decodeBuilder = [JWT decodeMessage:yourJwt];
        NSDictionary *decodedResult = decodeBuilder.message(yourJwt).secret(yourSecret).claimsSet(trustedClaimsSet).options(options).decode;
        if (decodeBuilder.jwtError) {
            // handle error
            NSLog(@"decode failed, error: %@", decodeBuilder.jwtError);
        }
        else {
            // handle decoded result
            NSLog(@"decoded result: %@", decodedResult);
        }
    });
});

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
        it(@"encodes and decodes JWT with none algorithm & nil secret", ^{
            NSString *algorithmName = @"none";
            NSString *secret = nil;
            NSDictionary *payload = @{@"key": @"value"};
            NSDictionary *headers = @{@"header" : @"value"};
            
            NSMutableDictionary *allHeaders = [@{@"typ":@"JWT", @"alg":algorithmName} mutableCopy];
            
            [allHeaders addEntriesFromDictionary:headers];
            
            NSString *headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
            
            NSString *payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
            
            NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
            
            NSString *signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
            
            NSString *jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];
            
            NSDictionary *info = [JWT decodeMessage:jwt withSecret:secret withError:nil withForcedAlgorithmByName:algorithmName];
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
            NSString *algorithmName = @"none";
            NSString *secret = @"";
            NSDictionary *payload = @{@"key": @"value"};
            NSDictionary *headers = @{@"header" : @"value"};
            
            NSMutableDictionary *allHeaders = [@{@"typ":@"JWT", @"alg":algorithmName} mutableCopy];
            
            [allHeaders addEntriesFromDictionary:headers];
            
            NSString *headerSegment = [[NSJSONSerialization dataWithJSONObject:allHeaders options:0 error:nil] base64UrlEncodedString];
            
            NSString *payloadSegment = [[NSJSONSerialization dataWithJSONObject:payload options:0 error:nil] base64UrlEncodedString];
            
            NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
            
            NSString *signingOutput = [[[JWTAlgorithmFactory algorithmByName:algorithmName] encodePayload:signingInput withSecret:secret] base64UrlEncodedString];
            
            NSString *jwt = [@[headerSegment, payloadSegment, signingOutput] componentsJoinedByString:@"."];
            
            NSDictionary *info = [JWT decodeMessage:jwt withSecret:secret withError:nil withForcedAlgorithmByName:algorithmName];
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
            
            NSString *algorithmName = @"HS512";
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
            info = [JWT decodeMessage:jwt].secret(secret).algorithmName(algorithmName).decode;
            
            NSLog(@"info is: %@", info);
            
            [[info[@"payload"] should] equal:payload];
            [[info[@"header"] should] equal:allHeaders];
        });
        
        it(@"decode should fail if algorithm type isn't specified", ^{
            NSString *secret = @"secret";
            NSString *message = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
            
            NSError *error = nil;
            NSDictionary *decoded = nil;
            
            decoded = [JWT decodeMessage:message withSecret:secret withError:&error withForcedAlgorithmByName:nil];
            
            [[error shouldNot] beNil];
            [[theValue(error.code) should] equal:theValue(JWTUnspecifiedAlgorithmError)];
            [[decoded should] beNil];
            
            decoded = nil;
            error = nil;
            
            JWTClaimsSet *claimsSet = [[JWTClaimsSet alloc] init];
            
            decoded = [JWT decodeMessage:message withSecret:secret withTrustedClaimsSet:claimsSet withError:&error withForcedAlgorithmByName:nil];
            
            [[error shouldNot] beNil];
            [[theValue(error.code) should] equal:theValue(JWTUnspecifiedAlgorithmError)];
            [[decoded should] beNil];
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
            NSDictionary *forcedInfo = [JWT decodeMessage:jwt withSecret:secret withError:&forcedError withForcedAlgorithmByName:algorithmName skipVerification:YES];
            
            NSLog(@"forcedInfo is: %@ forcedError: %@", forcedInfo, forcedError);
            
            [[forcedInfo[@"payload"] should] equal:payload];
            [[forcedInfo[@"header"] should] equal:allHeaders];
            
            NSError *error = nil;
            NSDictionary *info = [JWT decodeMessage:jwt withSecret:secret withError:&error withForcedAlgorithmByName:algorithmName skipVerification:NO];
            
            NSLog(@"info is: %@ error: %@", info, error);
            [[@(error.code) should] equal:@(JWTUnsupportedAlgorithmError)];

            //fluent
            error = nil;
            JWTBuilder *builder = [JWT decodeMessage:jwt];
            info = builder.secret(secret).options(@NO).algorithmName(algorithmName).decode;
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
            JWTBuilder *builder = [JWT decodeMessage:jwt].secret(secret).claimsSet(trustedClaimsSet).algorithmName(algorithmName);
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
            NSDictionary *info = [JWT decodeMessage:jwt].secret(secret).algorithmName(algorithmName).decode;
            
            NSLog(@"info is: %@", info);
            
            [[info[@"payload"] should] equal:payload];
            [[info[@"header"] should] equal:allHeaders];
        });
    });
});

describe(@"Whitelist tests", ^{
    it(@"Adding algorithms to whitelist should work", ^{
        
        NSString *alg1 = @"HS256";
        NSString *alg2 = @"HS512";

        [JWT setWhitelistEnabled:YES];
        
        [[theValue([[JWT algorithmWhitelist] count]) should] equal:theValue(0)];
        
        [JWT addAlgorithmToWhitelist:alg1];
        
        [[theValue([[JWT algorithmWhitelist] count]) should] equal:theValue(1)];
        [[theValue([[JWT algorithmWhitelist] containsObject:alg1]) should] beTrue];

        [JWT addAlgorithmToWhitelist:alg2];
        
        [[theValue([[JWT algorithmWhitelist] count]) should] equal:theValue(2)];
        [[theValue([[JWT algorithmWhitelist] containsObject:alg2]) should] beTrue];
        
        [JWT addAlgorithmToWhitelist:alg2];
        
        [[theValue([[JWT algorithmWhitelist] count]) should] equal:theValue(2)];
    });
    it(@"Removing algorithms from whitelist should work", ^{
        
        NSString *alg1 = @"HS256";
        NSString *alg2 = @"HS512";
        
        [JWT setWhitelistEnabled:YES];
        [JWT addAlgorithmToWhitelist:alg1];
        [JWT addAlgorithmToWhitelist:alg2];
        
        [[theValue([[JWT algorithmWhitelist] count]) should] equal:theValue(2)];
        
        [JWT removeAlgorithmFromWhitelist:alg1];
        
        [[theValue([[JWT algorithmWhitelist] count]) should] equal:theValue(1)];
        [[theValue([[JWT algorithmWhitelist] containsObject:alg1]) should] beFalse];
        
        [JWT removeAlgorithmFromWhitelist:alg2];
        
        [[theValue([[JWT algorithmWhitelist] count]) should] equal:theValue(0)];
        [[theValue([[JWT algorithmWhitelist] containsObject:alg2]) should] beFalse];
    });
    
    it(@"Toggling whitelist enabled should clear whitelist", ^{
        
        NSString *alg1 = @"HS256";
        NSString *alg2 = @"HS512";
        
        [JWT setWhitelistEnabled:YES];
        [JWT addAlgorithmToWhitelist:alg1];
        [JWT addAlgorithmToWhitelist:alg2];

        [[theValue([[JWT algorithmWhitelist] count]) should] equal:theValue(2)];
        [[theValue([[JWT algorithmWhitelist] containsObject:alg1]) should] beTrue];
        [[theValue([[JWT algorithmWhitelist] containsObject:alg2]) should] beTrue];
        
        [JWT setWhitelistEnabled:NO];
        
        [[theValue([[JWT algorithmWhitelist] count]) should] equal:theValue(0)];
        [[theValue([[JWT algorithmWhitelist] containsObject:alg1]) should] beFalse];
        [[theValue([[JWT algorithmWhitelist] containsObject:alg2]) should] beFalse];
        
        [JWT setWhitelistEnabled:YES];
        
        [[theValue([[JWT algorithmWhitelist] count]) should] equal:theValue(0)];
        [[theValue([[JWT algorithmWhitelist] containsObject:alg1]) should] beFalse];
        [[theValue([[JWT algorithmWhitelist] containsObject:alg2]) should] beFalse];
        
        
    });
    
    it(@"Enabling whitelist should enforce whitelist algorithms", ^{
        NSString *algorithmName = @"HS256";
        NSString *secret = @"secret";
        NSString *message = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
        
        [JWT setWhitelistEnabled:YES];

        
        NSDictionary *expectedHeader = @{
                                         @"alg": @"HS256",
                                         @"typ": @"JWT"
                                         };
        NSDictionary *expectedPayload = @{
                                          @"sub": @"1234567890",
                                          @"name": @"John Doe",
                                          @"admin": @(YES)
                                          };
        
        NSError *error = nil;
        NSDictionary *decoded = [JWT decodeMessage:message withSecret:secret withError:&error withForcedAlgorithmByName:algorithmName];
        
        [[error shouldNot] beNil];
        [[theValue(error.code) should] equal:theValue(JWTUnsupportedAlgorithmError)];
        [[decoded should] beNil];
        
        [JWT addAlgorithmToWhitelist:algorithmName];

        error = nil;
        
        decoded = [JWT decodeMessage:message withSecret:secret withError:&error withForcedAlgorithmByName:algorithmName];
        
        [[error should] beNil];
        [[decoded shouldNot] beNil];
        NSDictionary *header = [decoded objectForKey:@"header"];
        NSDictionary *payload = [decoded objectForKey:@"payload"];
        
        [[theValue([header isEqualToDictionary:expectedHeader]) should] beTrue];
        [[theValue([payload isEqualToDictionary:expectedPayload]) should] beTrue];
        
    });
});

SPEC_END




