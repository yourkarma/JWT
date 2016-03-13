//
//  JWTAlgorithmHS384Spec.m
//  JWT
//
//  Created by Lobanov Dmitry on 06-02-16.
//  Copyright (c) 2016 lolgear. All rights reserved.
//

//#import <Kiwi/Kiwi.h>
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <Base64/MF_Base64Additions.h>

#import "JWTAlgorithmHS384.h"
#import "JWTAlgorithmHSBase.h"

SpecBegin(AlgorithmHS384)

describe(@"AlgorithmHS384", ^{
    NSString *algorithmBehaviour = @"AlgoritmHS384";
    NSString *algorithmKey = @"alg";
    sharedExamplesFor(algorithmBehaviour, ^(NSDictionary *data){
        __block id<JWTAlgorithm> algorithm;
        
        beforeEach(^{
            algorithm = data[algorithmKey];//[[JWTAlgorithmHS384 alloc] init];
        });
        
        pending(@"name is HS384", ^{
            expect(algorithm.name).to.equal(@"HS384");
        });
        
        it(@"HMAC encodes the payload using SHA384", ^{
            NSData *encodedPayload = [algorithm encodePayload:@"payload" withSecret:@"secret"];
            NSString *actual = [encodedPayload base64String];
            NSString *expected = @"s62aZf5ZLMSvjtBQpY4kiJbYxSu8wLAUop2D9nod5Eqgd+nyUCEj+iaDuVuI4gaJ";
            expect(actual).to.equal(expected);
        });
        
        it(@"HMAC encodes the payload data using SHA384", ^{
            NSData *payloadData = [NSData dataWithBase64String:[@"payload" base64String]];
            NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
            
            NSData *encodedPayload = [algorithm encodePayloadData:payloadData withSecret:secretData];
            NSString *actual = [encodedPayload base64String];
            NSString *expected = @"s62aZf5ZLMSvjtBQpY4kiJbYxSu8wLAUop2D9nod5Eqgd+nyUCEj+iaDuVuI4gaJ";
            expect(actual).to.equal(expected);
        });
        
        it(@"should verify JWT with valid signature and secret", ^{
            NSString *secret = @"secret";
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = @"hnzqaUFa2kfSFnynQ_WBJ7-wpLCgsyEdilCkRKliadjVuG-hGnc1qhvIjlvxSie5";
            
            expect([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]).to.beTruthy();
        });
        
        it(@"should fail to verify JWT with invalid secret", ^{
            NSString *secret = @"notTheSecret";
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = @"hnzqaUFa2kfSFnynQ_WBJ7-wpLCgsyEdilCkRKliadjVuG-hGnc1qhvIjlvxSie5";
            
            expect([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]).to.beFalsy();
        });
        
        it(@"should fail to verify JWT with invalid signature", ^{
            NSString *secret = @"secret";
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = nil;
            
            expect([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]).to.beFalsy();
        });
        
        it(@"should verify JWT with valid signature and secret data", ^{
            NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = @"hnzqaUFa2kfSFnynQ_WBJ7-wpLCgsyEdilCkRKliadjVuG-hGnc1qhvIjlvxSie5";
            
            expect([algorithm verifySignedInput:signingInput withSignature:signature verificationKeyData:secretData]).to.beTruthy();
        });
        
        it(@"should fail to verify JWT with invalid secret data", ^{
            NSData *secretData = [NSData dataWithBase64String:[@"notTheSecret" base64String]];
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = @"hnzqaUFa2kfSFnynQ_WBJ7-wpLCgsyEdilCkRKliadjVuG-hGnc1qhvIjlvxSie5";
            
            expect([algorithm verifySignedInput:signingInput withSignature:signature verificationKeyData:secretData]).to.beFalsy();
        });
        
        it(@"should fail to verify JWT with invalid signature", ^{
            NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = nil;
            
            expect([algorithm verifySignedInput:signingInput withSignature:signature verificationKeyData:secretData]).to.beFalsy();
        });
    });
    
    context(@"Clean", ^{
        itShouldBehaveLike(algorithmBehaviour, @{algorithmKey: [[JWTAlgorithmHS384 alloc] init]});
    });
    
    context(@"HSBased", ^{
        itShouldBehaveLike(algorithmBehaviour, @{algorithmKey: [JWTAlgorithmHSBase algorithm384]});
    });
});

SpecEnd

//SPEC_BEGIN(JWTAlgorithmHS384Spec)
//
//it(@"name is HS384", ^{
//    [[algorithm.name should] equal:@"HS384"];
//});
//
//it(@"HMAC encodes the payload using SHA384", ^{
//    NSData *encodedPayload = [algorithm encodePayload:@"payload" withSecret:@"secret"];
//    [[[encodedPayload base64String] should] equal:@"s62aZf5ZLMSvjtBQpY4kiJbYxSu8wLAUop2D9nod5Eqgd+nyUCEj+iaDuVuI4gaJ"];
//});
//
//it(@"HMAC encodes the payload data using SHA384", ^{
//    NSData *payloadData = [NSData dataWithBase64String:[@"payload" base64String]];
//    NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
//    
//    NSData *encodedPayload = [algorithm encodePayloadData:payloadData withSecret:secretData];
//    [[[encodedPayload base64String] should] equal:@"s62aZf5ZLMSvjtBQpY4kiJbYxSu8wLAUop2D9nod5Eqgd+nyUCEj+iaDuVuI4gaJ"];
//});
//
//it(@"should verify JWT with valid signature and secret", ^{
//    NSString *secret = @"secret";
//    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
//    NSString *signature = @"hnzqaUFa2kfSFnynQ_WBJ7-wpLCgsyEdilCkRKliadjVuG-hGnc1qhvIjlvxSie5";
//    
//    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]) should] beTrue];
//});
//
//it(@"should fail to verify JWT with invalid secret", ^{
//    NSString *secret = @"notTheSecret";
//    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
//    NSString *signature = @"hnzqaUFa2kfSFnynQ_WBJ7-wpLCgsyEdilCkRKliadjVuG-hGnc1qhvIjlvxSie5";
//    
//    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]) should] beFalse];
//});
//
//it(@"should fail to verify JWT with invalid signature", ^{
//    NSString *secret = @"secret";
//    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
//    NSString *signature = nil;
//    
//    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]) should] beFalse];
//});
//
//it(@"should verify JWT with valid signature and secret data", ^{
//    NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
//    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
//    NSString *signature = @"hnzqaUFa2kfSFnynQ_WBJ7-wpLCgsyEdilCkRKliadjVuG-hGnc1qhvIjlvxSie5";
//    
//    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKeyData:secretData]) should] beTrue];
//});
//
//it(@"should fail to verify JWT with invalid secret data", ^{
//    NSData *secretData = [NSData dataWithBase64String:[@"notTheSecret" base64String]];
//    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
//    NSString *signature = @"hnzqaUFa2kfSFnynQ_WBJ7-wpLCgsyEdilCkRKliadjVuG-hGnc1qhvIjlvxSie5";
//    
//    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKeyData:secretData]) should] beFalse];
//});
//
//it(@"should fail to verify JWT with invalid signature", ^{
//    NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
//    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
//    NSString *signature = nil;
//    
//    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKeyData:secretData]) should] beFalse];
//});
//
//SPEC_END