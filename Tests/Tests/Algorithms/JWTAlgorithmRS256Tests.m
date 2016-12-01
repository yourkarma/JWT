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
#import "JWTAlgorithmRSBase.h"

static NSString *algorithmBehavior = @"algorithmRS256Behaviour";
static NSString *dataAlgorithmKey = @"dataAlgorithmKey";

SHARED_EXAMPLES_BEGIN(JWTAlgorithmRS256Examples)

sharedExamplesFor(algorithmBehavior, ^(NSDictionary *data) {
    __block id<JWTAlgorithm> algorithm;
    __block NSString *valid_token;
    __block NSString *valid_privateKeyCertificatePassphrase;
    __block NSString *valid_publicKeyCertificateString;
    
    __block NSString *invalid_token;
    __block NSString *invalid_privateKeyCertificatePassphrase;
    __block NSString *invalid_publicKeyCertificateString;
    
    __block NSData *privateKeyCertificateData;
    __block NSString *algorithmName;
    __block NSDictionary *headerAndPayloadDictionary;
    __block NSDictionary *headerDictionary;
    __block NSDictionary *payloadDictionary;
    
    __block void (^assertDecodedDictionary)(NSDictionary *);
    __block void (^assertToken)(NSString *);
    beforeAll(^{
        valid_token     = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJoZWxsbyI6ICJ3b3JsZCJ9.AzXfyb6BuwLgNUqVkfiKeQRctG25u3-5DJIsGyDnFxOGTet74SjW6Aabm3LSXZ2HgQ5yp8_tCfqA12oDmPiviq4muhgc0LKujTpGtFlf0fcSJQJpxSTMGQZdZnxdKpz7dCSlQNvW6j1tGy1UWkXod-kf4FZckoDkGEbnRAVVVL7xRupFtLneUJGoWZCiMz5oYAoYMUY1bVil1S6lIwUJLtgsvrQMoVIcjlivjZ8fzF3tjQdInxCjYeOKD3WQ2-n3APg-1GEJT-l_2y-scbE55TPSxo9fpHoDn7G0Kcgl8wpjY4j3KR9dEa4unJN3necd83yCMOUzs6vmFncEMTrRZw";
        invalid_token   = @"I_have_been_modified_nR5cCI6IkpXVCJ9.eyJoZWxsbyI6ICJ3b3JsZCJ9.AzXfyb6BuwLgNUqVkfiKeQRctG25u3-5DJIsGyDnFxOGTet74SjW6Aabm3LSXZ2HgQ5yp8_tCfqA12oDmPiviq4muhgc0LKujTpGtFlf0fcSJQJpxSTMGQZdZnxdKpz7dCSlQNvW6j1tGy1UWkXod-kf4FZckoDkGEbnRAVVVL7xRupFtLneUJGoWZCiMz5oYAoYMUY1bVil1S6lIwUJLtgsvrQMoVIcjlivjZ8fzF3tjQdInxCjYeOKD3WQ2-n3APg-1GEJT-l_2y-scbE55TPSxo9fpHoDn7G0Kcgl8wpjY4j3KR9dEa4unJN3necd83yCMOUzs6vmFncEMTrRZw";
        
        // From "Test certificate and public key 1.pem"
        valid_publicKeyCertificateString    = @"MIICnTCCAYUCBEReYeAwDQYJKoZIhvcNAQEFBQAwEzERMA8GA1UEAxMIand0LTIwNDgwHhcNMTQwMTI0MTMwOTE2WhcNMzQwMjIzMjAwMDAwWjATMREwDwYDVQQDEwhqd3QtMjA0ODCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKhWb9KXmv45+TKOKhFJkrboZbpbKPJ9Yp12xKLXf8060KfStEStIX+7dCuAYylYWoqiGpuLVVUL5JmHgXmK9TJpzv9Dfe3TAc/+35r8r9IYB2gXUOZkebty05R6PLY0RO/hs2ZhrOozHMo+x216Gwz0CWaajcuiY5Yg1V8VvJ1iQ3rcRgZapk49RNX69kQrGS63gzj0gyHnRtbqc/Ua2kobCA83nnznCom3AGinnlSN65AFPP5jmri0l79+4ZZNIerErSW96mUF8jlJFZI1yJIbzbv73tL+y4i0+BvzsWBs6TkHAp4pinaI8zT+hrVQ2jD4fkJEiRN9lAqLPUd8CNkCAwEAATANBgkqhkiG9w0BAQUFAAOCAQEAnqBw3UHOSSHtU7yMi1+HE+9119tMh7X/fCpcpOnjYmhW8uy9SiPBZBl1z6vQYkMPcURnDMGHdA31kPKICZ6GLWGkBLY3BfIQi064e8vWHW7zX6+2Wi1zFWdJlmgQzBhbr8pYh9xjZe6FjPwbSEuS0uE8dWSWHJLdWsA4xNX9k3pr601R2vPVFCDKs3K1a8P/Xi59kYmKMjaX6vYT879ygWt43yhtGTF48y85+eqLdFRFANTbBFSzdRlPQUYa5d9PZGxeBTcg7UBkK/G+d6D5sd78T2ymwlLYrNi+cSDYD6S4hwZaLeEK6h7p/OoG02RBNuT4VqFRu5DJ6Po+C6JhqQ==";
        
        // From "Test certificate and public key 2.pem"
        invalid_publicKeyCertificateString  = @"MIIDVzCCAj+gAwIBAgIBATANBgkqhkiG9w0BAQsFADBMMR8wHQYDVQQDDBZEaWdpdGFsIFNpZ25pbmcgVGVzdCAyMQswCQYDVQQGEwJBVTEcMBoGCSqGSIb3DQEJARYNdGVzdEB0ZXN0LmNvbTAeFw0xNjAzMTIwMDUzMDJaFw0xNzAzMTIwMDUzMDJaMEwxHzAdBgNVBAMMFkRpZ2l0YWwgU2lnbmluZyBUZXN0IDIxCzAJBgNVBAYTAkFVMRwwGgYJKoZIhvcNAQkBFg10ZXN0QHRlc3QuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtQ57lsgAE5eWahnJ4e9InudO6rtJ12qE/qaeBrU8qcmJ0ku78Ih2gnShRtdmJGaDgGH1hM6J+ucQvl87foNqJPeAN+s5GeiGw4yoaHTnibJ9/v8rzz+PzMwXn6EGykaL6eDAIIOKNcMXvjWZEXtwr/roOFbaEIe6JeqNeSb2mXS+1XI5NGCL4jp8y0WmNCp/0LUMGQyj2ilmIgaV74cB2xdxPozZZJnWDASkgbGzi4ijZCpOP/yksEvJ7JSNBmmAQoFNslMymOO3XYJs3yvR9thwRl/uHbY4gHRPGHramCdJ6s+Lw+gzCjslB87HsIy4pp6PeDiOe/tyc79LWcsLbQIDAQABo0QwQjAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwQwGAYDVR0RBBEwD4ENdGVzdEB0ZXN0LmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAmlDHOKSdE8sRbUHNWZtyghm7FUBcrEEB/mM/dtRbq7aUFEPtHpXdKGf/fC0TZxdLoKfIFvgEuPlvzwgFhHTW3qzY4dES0n2krALVkfT0IR72vR98AGEE2gchSqGtwr1KkvYE8A4IwU+mlrDzVZoE0OjRg73Klpaxc77ln34CB+yAIlL1uunIZj+zmCuhsK4i6QAjzJ1PaNXo5P9F4zfJDW4B0ej6/2V9nxBvWW8hdba/eVbDltkvw0dZZay6YgBmVz9mXbAGZ6pk2XOjTlS3XLFgLUVe8WTXbktQw0cCcf3xfn6HB/Y+5l/0srZ3i5Su5qtdDDbZ3epBjB3K5kiP8g==";
        
        algorithmName = @"RS256";
        
        valid_privateKeyCertificatePassphrase = @"password";
        invalid_privateKeyCertificatePassphrase = @"incorrect_password";
        
        headerAndPayloadDictionary = @{
                                       @"header" : @{
                                               @"alg" : @"RS256",
                                               @"typ" : @"JWT",
                                               },
                                       @"payload" : @{
                                               @"hello" : @"world",
                                               }
                                       };
        headerDictionary = headerAndPayloadDictionary[@"header"];
        payloadDictionary = headerAndPayloadDictionary[@"payload"];
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
            JWTBuilder *builder = [JWTBuilder decodeMessage:token].secret(valid_publicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm);
            
            NSDictionary *decodedDictionary = builder.decode;
            //NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:validTokenToDecode].secret(validPublicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm).decode;
            
            NSError *error = builder.jwtError;
            
            if (error) {
                NSLog(@"error = %@", error);
            }
            
            assertDecodedDictionary(decodedDictionary);
            
            NSLog(@"token = %@", token);
        };
    });

    context(@"Encoding", ^{
        context(@"Valid", ^{
            it(@"DataWithValidPrivateKeyCertificatePassphrase", ^{
                if (/* DISABLES CODE */ (0)){
                    JWTBuilder *builder = [JWTBuilder encodePayload:headerAndPayloadDictionary].secretData(privateKeyCertificateData).privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithmName(algorithmName).algorithm(algorithm);
                    NSString *token = builder.encode;
                    NSLog(@"token: %@\n valid_token: %@\n publicKey: %@\n headerAndPayloadDictionary: %@\n privateKey: %@",token,valid_token, valid_publicKeyCertificateString, headerAndPayloadDictionary, privateKeyCertificateData);
                    assertToken(token);
                }
                {
                    JWTCodingBuilder *newBuilder = [JWTEncodingBuilder encodePayload:headerAndPayloadDictionary].addHolder([JWTAlgorithmRSFamilyDataHolder new].privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithm(algorithm).algorithmName(algorithmName).secretData(privateKeyCertificateData));
                    JWTCodingResultType *result = newBuilder.result;
                    if (result.successResult) {
                        assertToken(result.successResult.encoded);
                    }
                    else {
                        NSLog(@"%@ error: %@",self, result.errorResult.error);
                        assertToken(nil);
                    }
                }
            });
            
            it(@"StringWithValidPrivateKeyCertificatePassphrase", ^{
                NSString *certificateString = [privateKeyCertificateData base64UrlEncodedString];
                NSString *token = [JWTBuilder encodePayload:headerAndPayloadDictionary].secret(certificateString).privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithmName(algorithmName).algorithm(algorithm).encode;
                NSLog(@"token: %@\n valid_token: %@\n publicKey: %@\n headerAndPayloadDictionary: %@\n privateKey: %@",token,valid_token, valid_publicKeyCertificateString, headerAndPayloadDictionary, privateKeyCertificateData);
                assertToken(token);
            });
        });
        
        context(@"Invalid", ^{
            it(@"DataWithInvalidPrivateKeyCertificatePassphrase", ^{
                NSString *token = [JWTBuilder encodePayload:headerAndPayloadDictionary].secretData(privateKeyCertificateData).privateKeyCertificatePassphrase(invalid_privateKeyCertificatePassphrase).algorithmName(algorithmName).algorithm(algorithm).encode;
                [[(token) should] beNil];
            });
            it(@"StringWithInvalidPrivateKeyCertificatePassphrase", ^{
                NSString *certificateString = [privateKeyCertificateData base64UrlEncodedString];
                NSString *token = [JWTBuilder encodePayload:headerAndPayloadDictionary].secret(certificateString).privateKeyCertificatePassphrase(invalid_privateKeyCertificatePassphrase).algorithmName(algorithmName).algorithm(algorithm).encode;
                [[(token) should] beNil];
            });
        });
        pending(@"EncodedTokenAsCanonical", ^{
            // specific test. depends on architecture?.
            // will be removed it later.
            NSString *correctToken = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJwYXlsb2FkIjp7ImhlbGxvIjoid29ybGQifSwiaGVhZGVyIjp7ImFsZyI6IlJTMjU2IiwidHlwIjoiSldUIn19.CkrRDy5Jxp3nFEKY5MqYZIrYIQathtMmnUfxs9oKXbclNQkda5cp_bYhamKrGOKSdxdoHHUdziyFIETWJHrLK2udvxGIYF_kJmhN6-Wkq4_y5K-dqB2DvxsaNjwiw3z9haO5c0k2JzwI794rOzQGeRac3hjscuEsxF-iVE_ZRbK91dfdG6wW7mBQFa8k8I882YoQXJJTdZPiXOAmEd2it65qvp-62WQcwWs9ImPBx7XzfuB1ZnCtp_vXA3qXsbYMkPB5OZSAVmkG1QPD0koqBz9v98hCnQQs0trCWl-CM_g4x0T-kxAdkoUDvIxtUGDWhYRPn2Pw3EDDa3zM7uvHng";
            JWTBuilder *builder = [JWTBuilder encodePayload:headerAndPayloadDictionary].secretData(privateKeyCertificateData).privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithmName(algorithmName).algorithm(algorithm);
            NSString *token = builder.encode;
            [[token should] equal:correctToken];
        });
    });
//    
//    pending(@"FailedTests", ^{
//        it(@"StringFailsWithValidSignatureAndInvalidPublicKey", ^{
//            NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:validTokenToDecode].secret(invalidPublicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm).decode;
//            [[(decodedDictionary) should] beNil];
//        });
//        it(@"DataFailsWithValidSignatureAndInvalidPublicKey", ^{
//            NSData *certificateData = [NSData dataWithBase64UrlEncodedString:invalidPublicKeyCertificateString];
//            NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:validTokenToDecode].secretData(certificateData).algorithmName(algorithmName).algorithm(algorithm).decode;
//            [[(decodedDictionary) should] beNil];
//        });
//        it(@"EncodedTokenAsCanonical", ^{
//            NSString *correctToken = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJwYXlsb2FkIjp7ImhlbGxvIjoid29ybGQifSwiaGVhZGVyIjp7ImFsZyI6IlJTMjU2IiwidHlwIjoiSldUIn19.CkrRDy5Jxp3nFEKY5MqYZIrYIQathtMmnUfxs9oKXbclNQkda5cp_bYhamKrGOKSdxdoHHUdziyFIETWJHrLK2udvxGIYF_kJmhN6-Wkq4_y5K-dqB2DvxsaNjwiw3z9haO5c0k2JzwI794rOzQGeRac3hjscuEsxF-iVE_ZRbK91dfdG6wW7mBQFa8k8I882YoQXJJTdZPiXOAmEd2it65qvp-62WQcwWs9ImPBx7XzfuB1ZnCtp_vXA3qXsbYMkPB5OZSAVmkG1QPD0koqBz9v98hCnQQs0trCWl-CM_g4x0T-kxAdkoUDvIxtUGDWhYRPn2Pw3EDDa3zM7uvHng";
//            JWTBuilder *builder = [JWTBuilder encodePayload:headerAndPayloadDictionary].secretData(privateKeyCertificateData).privateKeyCertificatePassphrase(@"password").algorithmName(algorithmName).algorithm(algorithm);
//            NSString *token = builder.encode;
//            [[correctToken should] equal:token];
//        });
//        it(@"StringSucceedsWithValidSignatureAndValidPublicKey", ^{
//            NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:validTokenToDecode].secret(validPublicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm).decode;
//            assertDecodedDictionary(decodedDictionary);
//        });
//    });
    context(@"Decoding", ^{
        context(@"Valid", ^{
            it(@"StringSucceedsWithValidSignatureAndValidPublicKey", ^{
                {
                    JWTBuilder *builder = [JWTBuilder decodeMessage:valid_token].secret(valid_publicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm);
                    NSDictionary *decodedDictionary = builder.decode;
                    
                    assertDecodedDictionary(decodedDictionary);
                }
                {
                    JWTCodingBuilder *builder = [JWTDecodingBuilder decodeMessage:valid_token].addHolder([JWTAlgorithmRSFamilyDataHolder new].secret(valid_publicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm));
                    JWTCodingResultType *result = builder.result;
                    if (result.successResult) {
                        assertDecodedDictionary(result.successResult.headerAndPayloadDictionary);
                    }
                    else {
                        NSLog(@"%@ error: %@", self, result.errorResult.error);
                    }
                }
            });
            pending(@"DataSucceedsWithValidSignatureAndValidPublicKey", ^{
                NSData *certificateData = [NSData dataWithBase64UrlEncodedString:valid_publicKeyCertificateString];
                JWTBuilder *builder = [JWTBuilder decodeMessage:valid_token].secretData(certificateData).algorithmName(algorithmName).algorithm(algorithm);
                
                NSDictionary *decodedDictionary = builder.decode;
                assertDecodedDictionary(decodedDictionary);
            });
        });
        context(@"Invalid", ^{
            it(@"StringFailsWithInValidSignatureAndValidPublicKey", ^{
                NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:invalid_token].secret(valid_publicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm).decode;
                [[(decodedDictionary) should] beNil];
            });
            it(@"StringFailsWithValidSignatureAndInvalidPublicKey", ^{
                NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:valid_token].secret(invalid_publicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm).decode;
                [[(decodedDictionary) should] beNil];
            });
            it(@"DataFailsWithInValidSignatureAndValidPublicKey", ^{
                NSData *certificateData = [NSData dataWithBase64UrlEncodedString:valid_publicKeyCertificateString];
                NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:invalid_token].secretData(certificateData).algorithmName(algorithmName).algorithm(algorithm).decode;
                [[(decodedDictionary) should] beNil];
            });
            
            it(@"DataFailsWithValidSignatureAndInvalidPublicKey", ^{
                NSData *certificateData = [NSData dataWithBase64UrlEncodedString:invalid_publicKeyCertificateString];
                NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:valid_token].secretData(certificateData).algorithmName(algorithmName).algorithm(algorithm).decode;
                [[(decodedDictionary) should] beNil];
            });
        });
    });
});

SHARED_EXAMPLES_END

SPEC_BEGIN(JWTAlgorithmRS256Spec)

    context(@"Name", ^{
        // Use algorithm by name. JWTBuilder.algorithmName(RS256)
//        itBehavesLike(algorithmBehavior, @{});
    });
    context(@"Clean", ^{        
//        itBehavesLike(algorithmBehavior, @{dataAlgorithmKey: [JWTAlgorithmRS256 new]});
    });
    context(@"RSBased", ^{
        itBehavesLike(algorithmBehavior, @{dataAlgorithmKey: [JWTAlgorithmRSBase algorithm256]});
    });

SPEC_END
