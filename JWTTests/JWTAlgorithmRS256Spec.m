//
//  JWTAlgorithmRS256Spec.m
//  JWT
//
//  Created by Hernan Zalazar on 10/23/14.
//  Copyright 2014 Karma. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "JWTAlgorithmRS256.h"


SPEC_BEGIN(JWTAlgorithmRS256Spec)

describe(@"JWTAlgorithmRS256", ^{

    __block JWTAlgorithmRS256 *algorithm;

    beforeAll(^{
        NSMutableDictionary *pairAttr = [@{
                                           (__bridge id)kSecAttrKeyType: (__bridge id)kSecAttrKeyTypeRSA,
                                           (__bridge id)kSecAttrKeySizeInBits: @(1024),
                                           } mutableCopy];
        NSDictionary *privateAttr = @{
                                      (__bridge id)kSecAttrIsPermanent: @YES,
                                      (__bridge id)kSecAttrApplicationTag: [@"com.example.key" dataUsingEncoding:NSUTF8StringEncoding],
                                      };
        NSDictionary *publicAttr = @{
                                     (__bridge id)kSecAttrIsPermanent: @YES,
                                     (__bridge id)kSecAttrApplicationTag: [@"com.example.pubkey" dataUsingEncoding:NSUTF8StringEncoding],
                                     };
        pairAttr[(__bridge id)kSecPrivateKeyAttrs] = privateAttr;
        pairAttr[(__bridge id)kSecPublicKeyAttrs] = publicAttr;

        SecKeyRef publicKeyRef;
        SecKeyRef privateKeyRef;

        SecKeyGeneratePair((__bridge CFDictionaryRef)pairAttr, &publicKeyRef, &privateKeyRef);

        CFRelease(publicKeyRef);
        CFRelease(privateKeyRef);
    });

    afterAll(^{
        NSDictionary *deletePubKeyQuery = @{
                                         (__bridge id)kSecClass: (__bridge id)kSecClassKey,
                                         (__bridge id)kSecAttrApplicationTag: [@"com.example.key" dataUsingEncoding:NSUTF8StringEncoding],
                                         (__bridge id)kSecAttrType: (__bridge id)kSecAttrKeyTypeRSA,
                                         };

        SecItemDelete((__bridge CFDictionaryRef)deletePubKeyQuery);

        NSDictionary *deletePrivKeyQuery = @{
                                         (__bridge id)kSecClass: (__bridge id)kSecClassKey,
                                         (__bridge id)kSecAttrApplicationTag: [@"com.example.pubkey" dataUsingEncoding:NSUTF8StringEncoding],
                                         (__bridge id)kSecAttrType: (__bridge id)kSecAttrKeyTypeRSA,
                                         };

        SecItemDelete((__bridge CFDictionaryRef)deletePrivKeyQuery);
    });

    beforeEach(^{
        algorithm = [[JWTAlgorithmRS256 alloc] init];
    });

    it(@"should have the right name", ^{
        [[algorithm.name should] equal:@"RS256"];
    });

    it(@"should encode using RS256", ^{
        NSData *encodedPayload = [algorithm encodePayload:@"payload" withSecret:@"com.example.key"];
        [[encodedPayload should] beNonNil];
    });

    it(@"should return nil when no private key is found", ^{
        [[[algorithm encodePayload:@"payload" withSecret:@"com.example.notfound"] should] beNil];
    });

});

SPEC_END
