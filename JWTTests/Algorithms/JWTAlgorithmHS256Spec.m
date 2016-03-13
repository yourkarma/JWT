//
//  JWTAlgorithmHS512.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright 2013 Karma. All rights reserved.
//

//#import <Kiwi/Kiwi.h>
#import <Specta/Specta.h> 
#import <Expecta/Expecta.h>
#import <Base64/MF_Base64Additions.h>

#import "JWTAlgorithmHS256.h"
#import "JWTAlgorithmHSBase.h"

SpecBegin(AlgorithmHS256)

describe(@"AlgorithmHS256", ^{
    NSString *algorithmBehaviour = @"AlgoritmHS256";
    NSString *algorithmKey = @"alg";
    sharedExamplesFor(algorithmBehaviour, ^(NSDictionary *data){
        __block id<JWTAlgorithm> algorithm;
        beforeEach(^{
            algorithm = data[algorithmKey];
        });

        pending(@"name is HS256", ^{
            expect(algorithm.name).to.equal(@"HS256");
        });
        
        it(@"HMAC encodes the payload using SHA256", ^{
            NSData *encodedPayload = [algorithm encodePayload:@"payload" withSecret:@"secret"];
            NSString *actual = [encodedPayload base64String];
            NSString *expected = @"uC/LeRrOxXhZuYm0MKgmSIzi5Hn9+SMmvQoug3WkK6Q=";
            expect(actual).to.equal(expected);
        });
        
        it(@"HMAC encodes the payload data using SHA256", ^{
            NSData *payloadData = [NSData dataWithBase64String:[@"payload" base64String]];
            NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
            
            NSData *encodedPayload = [algorithm encodePayloadData:payloadData withSecret:secretData];
            NSString *actual = [encodedPayload base64String];
            NSString *expected = @"uC/LeRrOxXhZuYm0MKgmSIzi5Hn9+SMmvQoug3WkK6Q=";
            expect(actual).to.equal(expected);
        });
        
        it(@"should verify JWT with valid signature and secret", ^{
            NSString *secret = @"secret";
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = @"TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
            
            expect([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]).to.beTruthy();
        });
        
        it(@"should fail to verify JWT with invalid secret", ^{
            NSString *secret = @"notTheSecret";
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = @"TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
            
            expect([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]).to.beFalsy();
        });
        
        it(@"should fail to verify JWT with invalid signature", ^{
            NSString *secret = @"secret";
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = nil;
            
            expect([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]).to.beFalsy();
        });
        
        it(@"should verify JWT with valid signature and secret Data", ^{
            NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = @"TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
            
            expect([algorithm verifySignedInput:signingInput withSignature:signature verificationKeyData:secretData]).to.beTruthy();
        });
        
        it(@"should fail to verify JWT with invalid secret", ^{
            NSData *secretData = [NSData dataWithBase64String:[@"notTheSecret" base64String]];
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = @"TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
            
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
        itShouldBehaveLike(algorithmBehaviour, @{algorithmKey: [[JWTAlgorithmHS256 alloc] init]});
    });
    
    context(@"HSBased", ^{
        itShouldBehaveLike(algorithmBehaviour, @{algorithmKey: [JWTAlgorithmHSBase algorithm256]});
    });
});

SpecEnd

//SPEC_BEGIN(JWTAlgorithmHS256Spec)
//
//__block JWTAlgorithmHS256 *algorithm;
//
//beforeEach(^{
//    algorithm = [[JWTAlgorithmHS256 alloc] init];
//});
//
//it(@"name is HS256", ^{
//    [[algorithm.name should] equal:@"HS256"];
//});
//
//it(@"HMAC encodes the payload using SHA256", ^{
//    NSData *encodedPayload = [algorithm encodePayload:@"payload" withSecret:@"secret"];
//    [[[encodedPayload base64String] should] equal:@"uC/LeRrOxXhZuYm0MKgmSIzi5Hn9+SMmvQoug3WkK6Q="];
//});
//
//it(@"HMAC encodes the payload data using SHA256", ^{
//    NSData *payloadData = [NSData dataWithBase64String:[@"payload" base64String]];
//    NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
//    
//    NSData *encodedPayload = [algorithm encodePayloadData:payloadData withSecret:secretData];
//    [[[encodedPayload base64String] should] equal:@"uC/LeRrOxXhZuYm0MKgmSIzi5Hn9+SMmvQoug3WkK6Q="];
//});
//
//it(@"should verify JWT with valid signature and secret", ^{
//    NSString *secret = @"secret";
//    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
//    NSString *signature = @"TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
//    
//    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]) should] beTrue];
//});
//
//it(@"should fail to verify JWT with invalid secret", ^{
//    NSString *secret = @"notTheSecret";
//    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
//    NSString *signature = @"TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
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
//it(@"should verify JWT with valid signature and secret Data", ^{
//    NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
//    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
//    NSString *signature = @"TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
//    
//    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKeyData:secretData]) should] beTrue];
//});
//
//it(@"should fail to verify JWT with invalid secret", ^{
//    NSData *secretData = [NSData dataWithBase64String:[@"notTheSecret" base64String]];
//    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
//    NSString *signature = @"TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
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