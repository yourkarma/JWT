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

#import "JWTAlgorithmHS512.h"
#import "JWTAlgorithmHSBase.h"

SpecBegin(AlgorithmHS512)

describe(@"AlgorithmHS512", ^{
    NSString *algorithmBehaviour = @"AlgoritmHS512";
    NSString *algorithmKey = @"alg";
    sharedExamplesFor(algorithmBehaviour, ^(NSDictionary *data){
        __block id<JWTAlgorithm> algorithm;
        beforeEach(^{
            algorithm = data[algorithmKey];
        });
        
        pending(@"name is HS512", ^{
            expect(algorithm.name).to.equal(@"HS512");
        });
        
        it(@"HMAC encodes the payload using SHA512", ^{
            NSData *encodedPayload = [algorithm encodePayload:@"payload" withSecret:@"secret"];
            NSString *actual = [encodedPayload base64String];
            NSString *expected = @"KR3aqiPK+jqq4cl1U5H0vvNbvby5JzmlYYpciW9lINKw0o0tKYfayXR54xIUpR2Wz86voo5GpPlhtjxGNSoYng==";
            expect(actual).to.equal(expected);
        });
        
        it(@"HMAC encodes the payload data using SHA512", ^{
            NSData *payloadData = [NSData dataWithBase64String:[@"payload" base64String]];
            NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
            
            NSData *encodedPayload = [algorithm encodePayloadData:payloadData withSecret:secretData];
            NSString *actual = [encodedPayload base64String];
            NSString *expected = @"KR3aqiPK+jqq4cl1U5H0vvNbvby5JzmlYYpciW9lINKw0o0tKYfayXR54xIUpR2Wz86voo5GpPlhtjxGNSoYng==";
            expect(actual).to.equal(expected);
        });
        
        it(@"should verify JWT with valid signature and secret", ^{
            NSString *secret = @"secret";
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = @"SerC5MWQIs3fRH6ZD7gKKbq51TsyydXTvl23WpD9sA085SzQ7pK6M0TnYjFITNUkwuniGG5Is2OKJCEIHPn1Kg";
            
            expect([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]).to.beTruthy();
        });
        
        it(@"should fail to verify JWT with invalid secret", ^{
            NSString *secret = @"notTheSecret";
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = @"SerC5MWQIs3fRH6ZD7gKKbq51TsyydXTvl23WpD9sA085SzQ7pK6M0TnYjFITNUkwuniGG5Is2OKJCEIHPn1Kg";
            
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
            NSString *signature = @"SerC5MWQIs3fRH6ZD7gKKbq51TsyydXTvl23WpD9sA085SzQ7pK6M0TnYjFITNUkwuniGG5Is2OKJCEIHPn1Kg";
            
            expect([algorithm verifySignedInput:signingInput withSignature:signature verificationKeyData:secretData]).to.beTruthy();
        });
        
        it(@"should fail to verify JWT with invalid secret data", ^{
            NSData *secretData = [NSData dataWithBase64String:[@"notTheSecret" base64String]];
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = @"SerC5MWQIs3fRH6ZD7gKKbq51TsyydXTvl23WpD9sA085SzQ7pK6M0TnYjFITNUkwuniGG5Is2OKJCEIHPn1Kg";
            
            expect([algorithm verifySignedInput:signingInput withSignature:signature verificationKeyData:secretData]).to.beFalsy();
        });
        
        it(@"should fail to verify JWT with invalid signature data", ^{
            NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
            NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            NSString *signature = nil;
            
            expect([algorithm verifySignedInput:signingInput withSignature:signature verificationKeyData:secretData]).to.beFalsy();
        });
    });
    
    context(@"Clean", ^{
        itShouldBehaveLike(algorithmBehaviour, @{algorithmKey: [[JWTAlgorithmHS512 alloc] init]});
    });
    
    context(@"HSBased", ^{
        itShouldBehaveLike(algorithmBehaviour, @{algorithmKey: [JWTAlgorithmHSBase algorithm512]});
    });

});

SpecEnd

//SPEC_BEGIN(JWTAlgorithmHS512Spec)
//
//__block JWTAlgorithmHS512 *algorithm;
//
//beforeEach(^{
//    algorithm = [[JWTAlgorithmHS512 alloc] init];
//});
//
//it(@"name is HS512", ^{
//    [[algorithm.name should] equal:@"HS512"];
//});
//
//it(@"HMAC encodes the payload using SHA512", ^{
//    NSData *encodedPayload = [algorithm encodePayload:@"payload" withSecret:@"secret"];
//    [[[encodedPayload base64String] should] equal:@"KR3aqiPK+jqq4cl1U5H0vvNbvby5JzmlYYpciW9lINKw0o0tKYfayXR54xIUpR2Wz86voo5GpPlhtjxGNSoYng=="];
//});
//
//it(@"HMAC encodes the payload data using SHA512", ^{
//    NSData *payloadData = [NSData dataWithBase64String:[@"payload" base64String]];
//    NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
//
//    NSData *encodedPayload = [algorithm encodePayloadData:payloadData withSecret:secretData];
//    [[[encodedPayload base64String] should] equal:@"KR3aqiPK+jqq4cl1U5H0vvNbvby5JzmlYYpciW9lINKw0o0tKYfayXR54xIUpR2Wz86voo5GpPlhtjxGNSoYng=="];
//});
//
//it(@"should verify JWT with valid signature and secret", ^{
//    NSString *secret = @"secret";
//    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
//    NSString *signature = @"SerC5MWQIs3fRH6ZD7gKKbq51TsyydXTvl23WpD9sA085SzQ7pK6M0TnYjFITNUkwuniGG5Is2OKJCEIHPn1Kg";
//
//    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]) should] beTrue];
//});
//
//it(@"should fail to verify JWT with invalid secret", ^{
//    NSString *secret = @"notTheSecret";
//    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
//    NSString *signature = @"SerC5MWQIs3fRH6ZD7gKKbq51TsyydXTvl23WpD9sA085SzQ7pK6M0TnYjFITNUkwuniGG5Is2OKJCEIHPn1Kg";
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
//    NSString *signature = @"SerC5MWQIs3fRH6ZD7gKKbq51TsyydXTvl23WpD9sA085SzQ7pK6M0TnYjFITNUkwuniGG5Is2OKJCEIHPn1Kg";
//
//    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKeyData:secretData]) should] beTrue];
//});
//
//it(@"should fail to verify JWT with invalid secret data", ^{
//    NSData *secretData = [NSData dataWithBase64String:[@"notTheSecret" base64String]];
//    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
//    NSString *signature = @"SerC5MWQIs3fRH6ZD7gKKbq51TsyydXTvl23WpD9sA085SzQ7pK6M0TnYjFITNUkwuniGG5Is2OKJCEIHPn1Kg";
//
//    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKeyData:secretData]) should] beFalse];
//});
//
//it(@"should fail to verify JWT with invalid signature data", ^{
//    NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
//    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
//    NSString *signature = nil;
//
//    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKeyData:secretData]) should] beFalse];
//});
//
//SPEC_END