//
//  JWTAlgorithmRS256Spec.m
//  JWT
//
//  Created by Lobanov Dmitry on 21.11.15.
//  Copyright © 2015 Karma. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Base64/MF_Base64Additions.h>

#import "JWTAlgorithmRS256.h"


SPEC_BEGIN(JWTAlgorithmRS256Spec)

__block JWTAlgorithmRS256 *algorithm;

beforeEach(^{
  algorithm = [[JWTAlgorithmRS256 alloc] init];
});

it(@"name is RS256", ^{
  [[algorithm.name should] equal:@"RS256"];
});

it(@"HMAC encodes the payload using RSA256", ^{
  NSData *encodedPayload = [algorithm encodePayload:@"payload" withSecret:@"secret"];
    
    // not implemented yet, always return nil 
    NSNumber *result  = @([encodedPayload base64String] == nil);
    [[result should] equal:@(1)];//@"uC/LeRrOxXhZuYm0MKgmSIzi5Hn9+SMmvQoug3WkK6Q="];
});

it(@"HMAC encodes the payload Data using RSA256", ^{
    NSData *payloadData = [NSData dataWithBase64String:[@"payload" base64String]];
    NSData *secretData = [NSData dataWithBase64String:[@"secret" base64String]];
    
    NSData *encodedPayload = [algorithm encodePayloadData:payloadData withSecret:secretData];
    
    // not implemented yet, always return nil
    NSNumber *result  = @([encodedPayload base64String] == nil);
    [[result should] equal:@(1)];//@"uC/LeRrOxXhZuYm0MKgmSIzi5Hn9+SMmvQoug3WkK6Q="];
});

it(@"should fail to verify JWT with valid signature and secret - RS256 not implemented yet", ^{
    NSString *secret = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDdlatRjRjogo3WojgGHFHYLugdUWAY9iR3fy4arWNA1KoS8kVw33cJibXr8bvwUAUparCwlvdbH6dvEOfou0/gCFQsHUfQrSDv+MuSUMAe8jzKE4qW+jK+xQU9a03GUnKHkkle+Q0pX/g6jXZ7r1/xAK5Do2kQ+X5xK9cipRgEKwIDAQAB";
    NSString *signingInput = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
    NSString *signature = @"EkN-DOsnsuRjRO6BxXemmJDm3HbxrbRzXglbN2S4sOkopdU4IsDxTI8jO19W_A4K8ZPJijNLis4EZsHeY559a4DFOd50_OqgHGuERTqYZyuhtF39yxJPAjUESwxk2J5k_4zM3O-vtd1Ghyo4IbqKKSy6J9mTniYJPenn5-HIirE";
    
    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]) should] beFalse];
});

it(@"should fail to verify JWT with invalid secret", ^{
    NSString *secret = @"notTheSecret";
    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
    NSString *signature = @"EkN-DOsnsuRjRO6BxXemmJDm3HbxrbRzXglbN2S4sOkopdU4IsDxTI8jO19W_A4K8ZPJijNLis4EZsHeY559a4DFOd50_OqgHGuERTqYZyuhtF39yxJPAjUESwxk2J5k_4zM3O-vtd1Ghyo4IbqKKSy6J9mTniYJPenn5-HIirE";
    
    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]) should] beFalse];
});

it(@"should fail to verify JWT with invalid signature", ^{
    NSString *secret = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDdlatRjRjogo3WojgGHFHYLugdUWAY9iR3fy4arWNA1KoS8kVw33cJibXr8bvwUAUparCwlvdbH6dvEOfou0/gCFQsHUfQrSDv+MuSUMAe8jzKE4qW+jK+xQU9a03GUnKHkkle+Q0pX/g6jXZ7r1/xAK5Do2kQ+X5xK9cipRgEKwIDAQAB";
    NSString *signingInput = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
    NSString *signature = nil;
    
    [[theValue([algorithm verifySignedInput:signingInput withSignature:signature verificationKey:secret]) should] beFalse];
});

SPEC_END
