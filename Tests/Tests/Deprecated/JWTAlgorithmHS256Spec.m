//
//  JWTAlgorithmHS512.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright 2013 Karma. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Base64/MF_Base64Additions.h>

#import <JWT/JWTAlgorithmHSBase.h>

static __auto_type dataAlgorithmKey = @"algorithm";
static __auto_type algorithmBehavior = @"algorithmHS256Behaviour";

SHARED_EXAMPLES_BEGIN(JWTAlgorithmHS256SpecExamples)

sharedExamplesFor(algorithmBehavior, ^(NSDictionary *data) {
    __block JWTAlgorithmHSBase *algorithm;
    __block __auto_type payload = @"payload";
    __block __auto_type signedPayload = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
    __block __auto_type signedPayloadBase64 = @"uC/LeRrOxXhZuYm0MKgmSIzi5Hn9+SMmvQoug3WkK6Q=";
    __block __auto_type secret = @"secret";
    __block __auto_type wrongSecret = @"notTheSecret";
    __block __auto_type signature = @"TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
    __block __auto_type name = @"HS256";
    beforeEach(^{
        algorithm = data[dataAlgorithmKey];
    });
    
    it(@"name is HS256", ^{
        [[algorithm.name should] equal:name];
    });
    
    it(@"HMAC encodes the payload canonically", ^{
        [[theValue([algorithm verifySignedInput:signedPayload withSignature:signature verificationKey:secret]) should] beTrue];
    });
    
    it(@"HMAC encodes the payload using SHA256", ^{
        __auto_type encodedPayload = [algorithm encodePayload:payload withSecret:secret];
        [[[encodedPayload base64String] should] equal:signedPayloadBase64];
    });
    
    it(@"HMAC encodes the payload data using SHA256", ^{
        __auto_type payloadData = [NSData dataWithBase64String:[payload base64String]];
        __auto_type secretData = [NSData dataWithBase64String:[secret base64String]];
        
        __auto_type encodedPayload = [algorithm encodePayloadData:payloadData withSecret:secretData];
        [[[encodedPayload base64String] should] equal:signedPayloadBase64];
    });
    
    it(@"should verify JWT with valid signature and secret", ^{
        [[theValue([algorithm verifySignedInput:signedPayload withSignature:signature verificationKey:secret]) should] beTrue];
    });
    
    it(@"should fail to verify JWT with invalid secret", ^{
        [[theValue([algorithm verifySignedInput:signedPayload withSignature:signature verificationKey:wrongSecret]) should] beFalse];
    });
    
    it(@"should fail to verify JWT with invalid signature", ^{
        [[theValue([algorithm verifySignedInput:signedPayload withSignature:nil verificationKey:secret]) should] beFalse];
    });
    
    it(@"should verify JWT with valid signature and secret Data", ^{
        __auto_type secretData = [NSData dataWithBase64String:[secret base64String]];
        [[theValue([algorithm verifySignedInput:signedPayload withSignature:signature verificationKeyData:secretData]) should] beTrue];
    });
    
    it(@"should fail to verify JWT with invalid secret", ^{
        __auto_type secretData = [NSData dataWithBase64String:[wrongSecret base64String]];
        [[theValue([algorithm verifySignedInput:signedPayload withSignature:signature verificationKeyData:secretData]) should] beFalse];
    });
    
    it(@"should fail to verify JWT with invalid signature", ^{
        __auto_type secretData = [NSData dataWithBase64String:[secret base64String]];
        [[theValue([algorithm verifySignedInput:signedPayload withSignature:nil verificationKeyData:secretData]) should] beFalse];
    });
});

SHARED_EXAMPLES_END

SPEC_BEGIN(JWTAlgorithmHS256Spec)

context(@"HSBased", ^{
    itBehavesLike(algorithmBehavior, @{dataAlgorithmKey: [JWTAlgorithmHSBase algorithm256]});
});

SPEC_END
