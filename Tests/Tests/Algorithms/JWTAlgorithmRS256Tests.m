//
//  JWTAlgorithmRS256Tests.m
//  JWT
//
//  Created by Marcelo Schroeder on 11/03/2016.
//  Copyright © 2016 Karma. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Base64/MF_Base64Additions.h>
#import "JWT.h"
#import "JWTAlgorithmRS256.h"
#import "JWTAlgorithmRSBase.h"

static NSString *algorithmBehavior = @"algorithmRS256Behaviour";
static NSString *dataAlgorithmKey = @"dataAlgorithmKey";

SHARED_EXAMPLES_BEGIN(JWTAlgorithmRS256Examples)

sharedExamplesFor(algorithmBehavior, ^(NSDictionary *data) {
    __block id<JWTAlgorithm> algorithm;
    __block NSString *validTokenToDecode;
    __block NSString *invalidTokenToDecode;
    __block NSString *validPublicKeyCertificateString;
    __block NSString *invalidPublicKeyCertificateString;
    __block NSData *privateKeyCertificateData;
    __block NSString *algorithmName;
    __block NSDictionary *headerAndPayloadDictionary;
    
    __block void (^assertDecodedDictionary)(NSDictionary *);
    __block void (^assertToken)(NSString *);
    beforeAll(^{
        validTokenToDecode     = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJoZWxsbyI6ICJ3b3JsZCJ9.AzXfyb6BuwLgNUqVkfiKeQRctG25u3-5DJIsGyDnFxOGTet74SjW6Aabm3LSXZ2HgQ5yp8_tCfqA12oDmPiviq4muhgc0LKujTpGtFlf0fcSJQJpxSTMGQZdZnxdKpz7dCSlQNvW6j1tGy1UWkXod-kf4FZckoDkGEbnRAVVVL7xRupFtLneUJGoWZCiMz5oYAoYMUY1bVil1S6lIwUJLtgsvrQMoVIcjlivjZ8fzF3tjQdInxCjYeOKD3WQ2-n3APg-1GEJT-l_2y-scbE55TPSxo9fpHoDn7G0Kcgl8wpjY4j3KR9dEa4unJN3necd83yCMOUzs6vmFncEMTrRZw";
        invalidTokenToDecode   = @"I_have_been_modified_nR5cCI6IkpXVCJ9.eyJoZWxsbyI6ICJ3b3JsZCJ9.AzXfyb6BuwLgNUqVkfiKeQRctG25u3-5DJIsGyDnFxOGTet74SjW6Aabm3LSXZ2HgQ5yp8_tCfqA12oDmPiviq4muhgc0LKujTpGtFlf0fcSJQJpxSTMGQZdZnxdKpz7dCSlQNvW6j1tGy1UWkXod-kf4FZckoDkGEbnRAVVVL7xRupFtLneUJGoWZCiMz5oYAoYMUY1bVil1S6lIwUJLtgsvrQMoVIcjlivjZ8fzF3tjQdInxCjYeOKD3WQ2-n3APg-1GEJT-l_2y-scbE55TPSxo9fpHoDn7G0Kcgl8wpjY4j3KR9dEa4unJN3necd83yCMOUzs6vmFncEMTrRZw";
        
        // From "Test certificate and public key 1.pem"
        validPublicKeyCertificateString    = @"MIICnTCCAYUCBEReYeAwDQYJKoZIhvcNAQEFBQAwEzERMA8GA1UEAxMIand0LTIwNDgwHhcNMTQwMTI0MTMwOTE2WhcNMzQwMjIzMjAwMDAwWjATMREwDwYDVQQDEwhqd3QtMjA0ODCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKhWb9KXmv45+TKOKhFJkrboZbpbKPJ9Yp12xKLXf8060KfStEStIX+7dCuAYylYWoqiGpuLVVUL5JmHgXmK9TJpzv9Dfe3TAc/+35r8r9IYB2gXUOZkebty05R6PLY0RO/hs2ZhrOozHMo+x216Gwz0CWaajcuiY5Yg1V8VvJ1iQ3rcRgZapk49RNX69kQrGS63gzj0gyHnRtbqc/Ua2kobCA83nnznCom3AGinnlSN65AFPP5jmri0l79+4ZZNIerErSW96mUF8jlJFZI1yJIbzbv73tL+y4i0+BvzsWBs6TkHAp4pinaI8zT+hrVQ2jD4fkJEiRN9lAqLPUd8CNkCAwEAATANBgkqhkiG9w0BAQUFAAOCAQEAnqBw3UHOSSHtU7yMi1+HE+9119tMh7X/fCpcpOnjYmhW8uy9SiPBZBl1z6vQYkMPcURnDMGHdA31kPKICZ6GLWGkBLY3BfIQi064e8vWHW7zX6+2Wi1zFWdJlmgQzBhbr8pYh9xjZe6FjPwbSEuS0uE8dWSWHJLdWsA4xNX9k3pr601R2vPVFCDKs3K1a8P/Xi59kYmKMjaX6vYT879ygWt43yhtGTF48y85+eqLdFRFANTbBFSzdRlPQUYa5d9PZGxeBTcg7UBkK/G+d6D5sd78T2ymwlLYrNi+cSDYD6S4hwZaLeEK6h7p/OoG02RBNuT4VqFRu5DJ6Po+C6JhqQ==";
        
        // From "Test certificate and public key 2.pem"
        invalidPublicKeyCertificateString  = @"MIIDVzCCAj+gAwIBAgIBATANBgkqhkiG9w0BAQsFADBMMR8wHQYDVQQDDBZEaWdpdGFsIFNpZ25pbmcgVGVzdCAyMQswCQYDVQQGEwJBVTEcMBoGCSqGSIb3DQEJARYNdGVzdEB0ZXN0LmNvbTAeFw0xNjAzMTIwMDUzMDJaFw0xNzAzMTIwMDUzMDJaMEwxHzAdBgNVBAMMFkRpZ2l0YWwgU2lnbmluZyBUZXN0IDIxCzAJBgNVBAYTAkFVMRwwGgYJKoZIhvcNAQkBFg10ZXN0QHRlc3QuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtQ57lsgAE5eWahnJ4e9InudO6rtJ12qE/qaeBrU8qcmJ0ku78Ih2gnShRtdmJGaDgGH1hM6J+ucQvl87foNqJPeAN+s5GeiGw4yoaHTnibJ9/v8rzz+PzMwXn6EGykaL6eDAIIOKNcMXvjWZEXtwr/roOFbaEIe6JeqNeSb2mXS+1XI5NGCL4jp8y0WmNCp/0LUMGQyj2ilmIgaV74cB2xdxPozZZJnWDASkgbGzi4ijZCpOP/yksEvJ7JSNBmmAQoFNslMymOO3XYJs3yvR9thwRl/uHbY4gHRPGHramCdJ6s+Lw+gzCjslB87HsIy4pp6PeDiOe/tyc79LWcsLbQIDAQABo0QwQjAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwQwGAYDVR0RBBEwD4ENdGVzdEB0ZXN0LmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAmlDHOKSdE8sRbUHNWZtyghm7FUBcrEEB/mM/dtRbq7aUFEPtHpXdKGf/fC0TZxdLoKfIFvgEuPlvzwgFhHTW3qzY4dES0n2krALVkfT0IR72vR98AGEE2gchSqGtwr1KkvYE8A4IwU+mlrDzVZoE0OjRg73Klpaxc77ln34CB+yAIlL1uunIZj+zmCuhsK4i6QAjzJ1PaNXo5P9F4zfJDW4B0ej6/2V9nxBvWW8hdba/eVbDltkvw0dZZay6YgBmVz9mXbAGZ6pk2XOjTlS3XLFgLUVe8WTXbktQw0cCcf3xfn6HB/Y+5l/0srZ3i5Su5qtdDDbZ3epBjB3K5kiP8g==";
        
        algorithmName = @"RS256";
        headerAndPayloadDictionary = @{
                                       @"header" : @{
                                               @"alg" : @"RS256",
                                               @"typ" : @"JWT",
                                               },
                                       @"payload" : @{
                                               @"hello" : @"world",
                                               }
                                       };
        NSString *p12FilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Test certificate and private key 1"
                                                                                 ofType:@"p12"];
        NSLog(@"p12FilePath: %@", p12FilePath);
        privateKeyCertificateData = [NSData dataWithContentsOfFile:p12FilePath];
        
        assertDecodedDictionary = ^(NSDictionary *decodedDictionary) {
            [[(decodedDictionary) shouldNot] beNil];
//            expect(decodedDictionary).notTo.beNil();
            [[(decodedDictionary) should] equal:headerAndPayloadDictionary];
//            expect(decodedDictionary).to.equal(headerAndPayloadDictionary);
        };
    });
    beforeEach(^{
        algorithm = data[dataAlgorithmKey];
        assertToken = ^(NSString *token) {
            [[theValue(token) shouldNot] beNil];
            NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:validTokenToDecode].secret(validPublicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm).decode;
            assertDecodedDictionary(decodedDictionary);
            NSLog(@"token = %@", token);
        };
    });

    context(@"Encoding", ^{
        it(@"DataWithValidPrivateKeyCertificatePassphrase", ^{
            JWTBuilder *builder = [JWTBuilder encodePayload:headerAndPayloadDictionary].secretData(privateKeyCertificateData).privateKeyCertificatePassphrase(@"password").algorithmName(algorithmName).algorithm(algorithm);
            NSString *token = builder.encode;
            assertToken(token);
        });
        
        it(@"DataWithInvalidPrivateKeyCertificatePassphrase", ^{
            NSString *token = [JWTBuilder encodePayload:headerAndPayloadDictionary].secretData(privateKeyCertificateData).privateKeyCertificatePassphrase(@"incorrect password").algorithmName(algorithmName).algorithm(algorithm).encode;
            [[(token) should] beNil];
        });
        
        it(@"StringWithValidPrivateKeyCertificatePassphrase", ^{
            NSString *certificateString = [privateKeyCertificateData base64UrlEncodedString];
            NSString *token = [JWTBuilder encodePayload:headerAndPayloadDictionary].secret(certificateString).privateKeyCertificatePassphrase(@"password").algorithmName(algorithmName).algorithm(algorithm).encode;
            assertToken(token);
        });
        it(@"StringWithInvalidPrivateKeyCertificatePassphrase", ^{
            NSString *certificateString = [privateKeyCertificateData base64UrlEncodedString];
            NSString *token = [JWTBuilder encodePayload:headerAndPayloadDictionary].secret(certificateString).privateKeyCertificatePassphrase(@"incorrect password").algorithmName(algorithmName).algorithm(algorithm).encode;
            [[(token) should] beNil];
        });
    });
    context(@"Decoding", ^{
        it(@"StringSucceedsWithValidSignatureAndValidPublicKey", ^{
            NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:validTokenToDecode].secret(validPublicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm).decode;
            assertDecodedDictionary(decodedDictionary);
        });
        
        it(@"StringFailsWithInValidSignatureAndValidPublicKey", ^{
            NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:invalidTokenToDecode].secret(validPublicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm).decode;
            [[(decodedDictionary) should] beNil];
        });
        
        it(@"StringFailsWithValidSignatureAndInvalidPublicKey", ^{
            NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:validTokenToDecode].secret(invalidPublicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm).decode;
            [[(decodedDictionary) should] beNil];
        });
        
        it(@"DataSucceedsWithValidSignatureAndValidPublicKey", ^{
            NSData *certificateData = [NSData dataWithBase64UrlEncodedString:validPublicKeyCertificateString];
            NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:validTokenToDecode].secretData(certificateData).algorithmName(algorithmName).algorithm(algorithm).decode;
            assertDecodedDictionary(decodedDictionary);
        });
        
        it(@"DataFailsWithInValidSignatureAndValidPublicKey", ^{
            NSData *certificateData = [NSData dataWithBase64UrlEncodedString:validPublicKeyCertificateString];
            NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:invalidTokenToDecode].secretData(certificateData).algorithmName(algorithmName).algorithm(algorithm).decode;
            [[(decodedDictionary) should] beNil];
        });
        
        it(@"DataFailsWithValidSignatureAndInvalidPublicKey", ^{
            NSData *certificateData = [NSData dataWithBase64UrlEncodedString:invalidPublicKeyCertificateString];
            NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:validTokenToDecode].secretData(certificateData).algorithmName(algorithmName).algorithm(algorithm).decode;
            [[(decodedDictionary) should] beNil];
        });
        
    });
});

SHARED_EXAMPLES_END

SPEC_BEGIN(JWTAlgorithmRS256Spec)

    context(@"Name", ^{
        // Use algorithm by name. JWTBuilder.algorithmName(RS256)
        itBehavesLike(algorithmBehavior, @{});
    });
    context(@"Clean", ^{
        itBehavesLike(algorithmBehavior, @{dataAlgorithmKey: [JWTAlgorithmRS256 new]});
    });
    context(@"RSBased", ^{
        itBehavesLike(algorithmBehavior, @{dataAlgorithmKey: [JWTAlgorithmRSBase algorithm256]});
    });

SPEC_END