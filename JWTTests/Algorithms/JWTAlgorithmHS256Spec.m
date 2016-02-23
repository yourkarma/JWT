//
//  JWTAlgorithmHS512.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright 2013 Karma. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Base64/MF_Base64Additions.h>

#import "JWTAlgorithmHS256.h"


SPEC_BEGIN(JWTAlgorithmHS256Spec)

__block JWTAlgorithmHS256 *algorithm;

beforeEach(^{
    algorithm = [[JWTAlgorithmHS256 alloc] init];
});

it(@"name is HS256", ^{
    [[algorithm.name should] equal:@"HS256"];
});

it(@"HMAC encodes the payload using SHA256", ^{
    NSData *encodedPayload = [algorithm encodePayload:@"payload" withSecret:@"secret"];
    [[[encodedPayload base64String] should] equal:@"uC/LeRrOxXhZuYm0MKgmSIzi5Hn9+SMmvQoug3WkK6Q="];
});

it(@"should verify JWT with valid signature and secret", ^{
    NSString *secret = @"secret";
    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
    NSString *signature = @"TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
    
    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]) should] beTrue];
});

it(@"should fail to verify JWT with invalid secret", ^{
    NSString *secret = @"notTheSecret";
    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
    NSString *signature = @"TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
    
    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]) should] beFalse];
});

it(@"should fail to verify JWT with invalid signature", ^{
    NSString *secret = @"secret";
    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
    NSString *signature = nil;
    
    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]) should] beFalse];
});

SPEC_END