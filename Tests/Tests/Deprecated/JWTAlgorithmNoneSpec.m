//
//  JWTAlgorithmNoneSpec.m
//  JWT
//
//  Created by Lobanov Dmitry on 16.10.15.
//  Copyright © 2015 Karma. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Base64/MF_Base64Additions.h>

#import "JWTAlgorithmNone.h"

static __auto_type dataAlgorithmKey = @"algorithm";
static __auto_type algorithmBehavior = @"algorithmNoneBehaviour";

SHARED_EXAMPLES_BEGIN(JWTAlgorithmNoneSpecExamples)

sharedExamplesFor(algorithmBehavior, ^(NSDictionary *data) {
    __block JWTAlgorithmNone *algorithm;
    __block NSString *payload = @"payload";
    __block NSString *secret = @"secret";
    __block NSString *signedPayload = @"eyJhbGciOiJub25lIn0.eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ";
    __block NSString *signedPayloadBase64 = @"";
    __block NSString *signature = @"signed";
    beforeEach(^{
        algorithm = data[dataAlgorithmKey];
    });
    
    it(@"name is none", ^{
        [[algorithm.name should] equal:@"none"];
    });
    
    it(@"should not encode payload and return emptry signature instead", ^{
        __auto_type encodedPayload = [algorithm encodePayload:payload withSecret:secret];
        [[[encodedPayload base64Encoding] should] equal:signedPayloadBase64];
    });
    
    it(@"should not encode payload data and return emptry signature instead", ^{
        __auto_type payloadData = [NSData dataWithBase64String:[payload base64String]];
        __auto_type secretData = [NSData dataWithBase64String:[secret base64String]];
        
        __auto_type encodedPayload = [algorithm encodePayloadData:payloadData withSecret:secretData];
        [[[encodedPayload base64Encoding] should] equal:signedPayloadBase64];
    });
    
    it(@"should not verify JWT with a secret provided", ^{
        [[theValue([algorithm verifySignedInput:signedPayload withSignature:nil verificationKey:secret]) should] beFalse];
    });
    
    it(@"should not verify JWT with a signature provided", ^{
        
        [[theValue([algorithm verifySignedInput:signedPayload withSignature:signature verificationKey:nil]) should] beFalse];
    });
    
    it(@"should verify JWT with no signature and no secret provided", ^{
        __auto_type signingInput = @"eyJhbGciOiJub25lIn0.eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ";
        
        [[theValue([algorithm verifySignedInput:signingInput withSignature:nil verificationKey:nil]) should] beTrue];
    });
    
    it(@"should not verify JWT with a secret data provided", ^{
        __auto_type secretData = [NSData dataWithBase64String:[secret base64String]];
        [[theValue([algorithm verifySignedInput:signedPayload withSignature:nil verificationKeyData:secretData]) should] beFalse];
    });
    
    it(@"should not verify JWT with a signature data provided", ^{
        __auto_type secretData = [NSData dataWithBase64String:nil];
        
        [[theValue([algorithm verifySignedInput:signedPayload withSignature:signature verificationKeyData:secretData]) should] beFalse];
    });
    
    it(@"should verify JWT with no signature and no secret data provided", ^{
        __auto_type secretData = [NSData dataWithBase64String:nil];
        [[theValue([algorithm verifySignedInput:signedPayload withSignature:nil verificationKeyData:secretData]) should] beTrue];
    });
});

SHARED_EXAMPLES_END

SPEC_BEGIN(JWTAlgorithmNoneSpec)

context(@"Clean", ^{
    itBehavesLike(algorithmBehavior, @{dataAlgorithmKey: [[JWTAlgorithmNone alloc] init]});
});

SPEC_END
