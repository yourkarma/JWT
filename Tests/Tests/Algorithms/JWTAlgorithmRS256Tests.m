//
//  JWTAlgorithmRS256Tests.m
//  JWT
//
//  Created by Marcelo Schroeder on 11/03/2016.
//  Copyright © 2016 Karma. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "JWTBase64Coder.h"
#import "JWT.h"
#import "JWTAlgorithmRSBase.h"
#import "JWTCryptoKeyExtractor.h"
#import "JWTCryptoSecurity.h"
#import "JWTCryptoKey.h"

static __auto_type algorithmBehavior = @"algorithmRS256Behaviour";
static __auto_type dataAlgorithmKey = @"dataAlgorithmKey";

@interface JWTAlgorithmRS256Examples_RSA_Helper : NSObject
+ (NSString *)extractCertificateFromPemFileWithName:(NSString *)name;
+ (NSString *)extractKeyFromPemFileWithName:(NSString *)name;
@end

@implementation JWTAlgorithmRS256Examples_RSA_Helper
+ (NSString *)extractCertificateFromPemFileWithName:(NSString *)name; {
    return [JWTCryptoSecurity certificateFromPemFileWithName:name];
}
+ (NSString *)extractKeyFromPemFileWithName:(NSString *)name {
    return [JWTCryptoSecurity keyFromPemFileWithName:name];
}
@end

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

        algorithmName = @"RS256";

        valid_privateKeyCertificatePassphrase = @"password";
        invalid_privateKeyCertificatePassphrase = @"incorrect_password";

        // From "Test certificate and public key 1.pem"
        valid_publicKeyCertificateString    = [JWTAlgorithmRS256Examples_RSA_Helper extractCertificateFromPemFileWithName:@"rs256-public"];

        // From "Test certificate and public key 2.pem"
        invalid_publicKeyCertificateString  = [JWTAlgorithmRS256Examples_RSA_Helper extractCertificateFromPemFileWithName:@"rs256-wrong-public"];

        payloadDictionary = @{@"hello":@"world"};
        headerDictionary = @{@"alg":algorithmName, @"typ":@"JWT"};
        headerAndPayloadDictionary = @{JWTCodingResultHeaders : headerDictionary, JWTCodingResultPayload : payloadDictionary};

        __auto_type p12FilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"rs256-private" ofType:@"p12"];
        privateKeyCertificateData = [NSData dataWithContentsOfFile:p12FilePath];


        __auto_type generated_token_result = [JWTEncodingBuilder encodePayload:payloadDictionary].addHolder([JWTAlgorithmRSFamilyDataHolder new].privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithmName(algorithmName).secretData(privateKeyCertificateData)).result;
        valid_token     = generated_token_result.successResult.encoded;
        invalid_token   = [valid_token stringByReplacingOccurrencesOfString:@"F" withString:@"D"];

        assertDecodedDictionary = ^(NSDictionary *decodedDictionary) {
            [[(decodedDictionary) shouldNot] beNil];
            [[(decodedDictionary) should] equal:headerAndPayloadDictionary];
        };
    });
    beforeEach(^{
        algorithm = data[dataAlgorithmKey];
        assertToken = ^(NSString *token) {
            [[theValue(token) shouldNot] beNil];
            __auto_type builder = [JWTBuilder decodeMessage:token].secret(valid_publicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm);

            __auto_type decodedDictionary = builder.decode;

            __auto_type error = builder.jwtError;

            if (error) {
                NSLog(@"%@ error(%@)", self.debugDescription, error);
            }

            NSLog(@"%@ decodedDictionary(%@)", self.debugDescription, decodedDictionary);
            assertDecodedDictionary(decodedDictionary);

            NSLog(@"%@ token(%@)", self.debugDescription, token);
        };
    });

    context(@"KeyExtracting", ^{
        __block __auto_type keyExtractingTokens = @{};
        __block __auto_type keyExtractingDataHolders = @{};
        __block __auto_type privateFromP12Key = @"privateFromP12Key";
        __block __auto_type privatePemEncodedKey = @"privatePemEncodedKey";
        __block __auto_type publicWithCertificateKey = @"publicWithCertificateKey";
        __block __auto_type publicPemEncodedKey = @"publicPemEncodedKey";

        beforeAll(^{
            __auto_type mutableKeyExtractingTokens = (NSMutableDictionary *)[keyExtractingTokens mutableCopy];
            __auto_type mutableKeyExtractingDataHolders = (NSMutableDictionary *)[keyExtractingDataHolders mutableCopy];
            __auto_type privatePemEncodedString = [JWTAlgorithmRS256Examples_RSA_Helper extractKeyFromPemFileWithName:@"rs256-private"];
            __auto_type publicPemEncodedString = [JWTAlgorithmRS256Examples_RSA_Helper extractKeyFromPemFileWithName:@"rs256-public"];
            {
                // private from p12
                __auto_type key = privateFromP12Key;
                id<JWTAlgorithmDataHolderProtocol> dataHolder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor privateKeyInP12].type).privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithm(algorithm).secretData(privateKeyCertificateData);

                mutableKeyExtractingDataHolders[key] = dataHolder;

                __auto_type newBuilder = [JWTEncodingBuilder encodePayload:payloadDictionary].addHolder(dataHolder);
                
                __auto_type result = newBuilder.result;
                if (result.successResult) {
                    mutableKeyExtractingTokens[key] = result.successResult.encoded;
                }
            }
            {
                // private pem encoded
                __auto_type key = privatePemEncodedKey;
                id<JWTAlgorithmDataHolderProtocol> dataHolder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor privateKeyWithPEMBase64].type).algorithm(algorithm).secret(privatePemEncodedString);

                mutableKeyExtractingDataHolders[key] = dataHolder;

                __auto_type newBuilder = [JWTEncodingBuilder encodePayload:payloadDictionary].addHolder(dataHolder);

                __auto_type result = newBuilder.result;
                if (result.successResult) {
                    mutableKeyExtractingTokens[key] = result.successResult.encoded;
                }
            }
            {
                // public from certificate
                __auto_type key = publicWithCertificateKey;
                id<JWTAlgorithmDataHolderProtocol> dataHolder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor publicKeyWithCertificate].type).algorithm(algorithm).secret(valid_publicKeyCertificateString);

                mutableKeyExtractingDataHolders[key] = dataHolder;

                __auto_type newBuilder = [JWTEncodingBuilder encodePayload:payloadDictionary].addHolder(dataHolder);

                __auto_type result = newBuilder.result;

                if (result.successResult) {
//                    mutableKeyExtractingTokens[key] = result.successResult.encoded;
                }
            }
            {
                // public pem encoded.
                __auto_type key = publicPemEncodedKey;
                
                id<JWTAlgorithmDataHolderProtocol> dataHolder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor publicKeyWithPEMBase64].type).algorithm(algorithm).secret(publicPemEncodedString);

                mutableKeyExtractingDataHolders[key] = dataHolder;

                __auto_type newBuilder = [JWTEncodingBuilder encodePayload:payloadDictionary].addHolder(dataHolder);

                __auto_type result = newBuilder.result;
                if (result.successResult) {
//                    mutableKeyExtractingTokens[key] = result.successResult.encoded;
                }
            }
            keyExtractingTokens = [mutableKeyExtractingTokens copy];
            keyExtractingDataHolders = [mutableKeyExtractingDataHolders copy];
        });
        context(@"Canonical", ^{
            __auto_type payloadString = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
            __auto_type payload = @{
                @"sub": @"1234567890",
                @"name": @"John Doe",
                @"admin": @(YES)
            };
            __auto_type signature = @"EkN-DOsnsuRjRO6BxXemmJDm3HbxrbRzXglbN2S4sOkopdU4IsDxTI8jO19W_A4K8ZPJijNLis4EZsHeY559a4DFOd50_OqgHGuERTqYZyuhtF39yxJPAjUESwxk2J5k_4zM3O-vtd1Ghyo4IbqKKSy6J9mTniYJPenn5-HIirE";
            __auto_type privateKeyPemEncodedString = @"MIICWwIBAAKBgQDdlatRjRjogo3WojgGHFHYLugdUWAY9iR3fy4arWNA1KoS8kVw33cJibXr8bvwUAUparCwlvdbH6dvEOfou0/gCFQsHUfQrSDv+MuSUMAe8jzKE4qW+jK+xQU9a03GUnKHkkle+Q0pX/g6jXZ7r1/xAK5Do2kQ+X5xK9cipRgEKwIDAQABAoGAD+onAtVye4ic7VR7V50DF9bOnwRwNXrARcDhq9LWNRrRGElESYYTQ6EbatXS3MCyjjX2eMhu/aF5YhXBwkppwxg+EOmXeh+MzL7Zh284OuPbkglAaGhV9bb6/5CpuGb1esyPbYW+Ty2PC0GSZfIXkXs76jXAu9TOBvD0ybc2YlkCQQDywg2R/7t3Q2OE2+yo382CLJdrlSLVROWKwb4tb2PjhY4XAwV8d1vy0RenxTB+K5Mu57uVSTHtrMK0GAtFr833AkEA6avx20OHo61Yela/4k5kQDtjEf1N0LfI+BcWZtxsS3jDM3i1Hp0KSu5rsCPb8acJo5RO26gGVrfAsDcIXKC+bQJAZZ2XIpsitLyPpuiMOvBbzPavd4gY6Z8KWrfYzJoI/Q9FuBo6rKwl4BFoToD7WIUS+hpkagwWiz+6zLoX1dbOZwJACmH5fSSjAkLRi54PKJ8TFUeOP15h9sQzydI8zJU+upvDEKZsZc/UhT/SySDOxQ4G/523Y0sz/OZtSWcol/UMgQJALesy++GdvoIDLfJX5GBQpuFgFenRiRDabxrE9MNUZ2aPFaFp+DyAe+b4nDwuJaW2LURbr8AEZga7oQj0uYxcYw==";
            __auto_type publicKeyPemEncodedString = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDdlatRjRjogo3WojgGHFHYLugdUWAY9iR3fy4arWNA1KoS8kVw33cJibXr8bvwUAUparCwlvdbH6dvEOfou0/gCFQsHUfQrSDv+MuSUMAe8jzKE4qW+jK+xQU9a03GUnKHkkle+Q0pX/g6jXZ7r1/xAK5Do2kQ+X5xK9cipRgEKwIDAQAB";
            __auto_type algorithmName = @"RS256";
            id<JWTRSAlgorithm> algorithm = (id<JWTRSAlgorithm>)[JWTAlgorithmFactory algorithmByName:algorithmName];
            __auto_type verifyKey = [[JWTCryptoKeyPublic alloc] initWithPemEncoded:publicKeyPemEncodedString parameters:nil error:nil];
            algorithm.verifyKey = verifyKey;
            [[theValue([algorithm verifySignedInput:payloadString withSignature:signature verificationKeyData:nil]) should] beTrue];
        });
        context(@"Decoding", ^{
            it(@"ByExtractedKeys", ^{
                NSLog(@"tokens are: %@", keyExtractingTokens);
                for (NSString *decodeByKey in keyExtractingDataHolders) {
                    id<JWTAlgorithmDataHolderProtocol> dataHolder = keyExtractingDataHolders[decodeByKey];
                    for (NSString *key in keyExtractingTokens) {
                        if ([key hasPrefix:[decodeByKey substringToIndex:2]]) {
                            // skip public and public or private and private.
                            NSLog(@"Pair: <%@> decodeBy <%@> skipped", key, decodeByKey);
                            continue;
                        }
//                        if ([decodeByKey hasPrefix:publicPemEncodedKey]) {
//                            continue;
//                        }
                        __auto_type token = (NSString *)keyExtractingTokens[key];
                        __auto_type newBuilder = [JWTDecodingBuilder decodeMessage:token].addHolder(dataHolder);
                        __auto_type result = newBuilder.result;
                        if (result.successResult) {
                            NSLog(@"Pair: <%@> decodeBy <%@> passed", key, decodeByKey);
                            assertDecodedDictionary(result.successResult.headerAndPayloadDictionary);
                        }
                        else {
                            NSLog(@"Pair: <%@> decodeBy <%@> failed. Error: %@", key, decodeByKey, result.errorResult.error);
                            assertDecodedDictionary(nil);
                        }
                    }
                }
            });

        });
    });
    context(@"Encoding", ^{
        context(@"Valid", ^{
            it(@"DataWithValidPrivateKeyCertificatePassphrase", ^{
                {
                    __auto_type builder = [JWTBuilder encodePayload:payloadDictionary].secretData(privateKeyCertificateData).privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithmName(algorithmName).algorithm(algorithm);
                    __auto_type token = builder.encode;
                    assertToken(token);
                }
                {
                    __auto_type newBuilder = [JWTEncodingBuilder encodePayload:payloadDictionary].addHolder([JWTAlgorithmRSFamilyDataHolder new].privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithm(algorithm).algorithmName(algorithmName).secretData(privateKeyCertificateData));
                    __auto_type result = newBuilder.result;
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
                __auto_type certificateString = [JWTBase64Coder base64UrlEncodedStringWithData:privateKeyCertificateData];
                __auto_type token = [JWTBuilder encodePayload:payloadDictionary].secret(certificateString).privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithmName(algorithmName).algorithm(algorithm).encode;
                NSLog(@"token: %@\n valid_token: %@\n publicKey: %@\n headerAndPayloadDictionary: %@\n privateKey: %@",token,valid_token, valid_publicKeyCertificateString, headerAndPayloadDictionary, privateKeyCertificateData);
                assertToken(token);
            });
        });

        context(@"Invalid", ^{
            it(@"DataWithInvalidPrivateKeyCertificatePassphrase", ^{
                __auto_type token = [JWTBuilder encodePayload:payloadDictionary].secretData(privateKeyCertificateData).privateKeyCertificatePassphrase(invalid_privateKeyCertificatePassphrase).algorithmName(algorithmName).algorithm(algorithm).encode;
                [[(token) should] beNil];
            });
            it(@"StringWithInvalidPrivateKeyCertificatePassphrase", ^{
                __auto_type certificateString = [JWTBase64Coder base64UrlEncodedStringWithData:privateKeyCertificateData];
                __auto_type token = [JWTBuilder encodePayload:payloadDictionary].secret(certificateString).privateKeyCertificatePassphrase(invalid_privateKeyCertificatePassphrase).algorithmName(algorithmName).algorithm(algorithm).encode;
                [[(token) should] beNil];
            });
        });
    });
//
//    pending(@"FailedTests", ^{
//        it(@"StringFailsWithValidSignatureAndInvalidPublicKey", ^{
//            __auto_type decodedDictionary = [JWTBuilder decodeMessage:validTokenToDecode].secret(invalidPublicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm).decode;
//            [[(decodedDictionary) should] beNil];
//        });
//        it(@"DataFailsWithValidSignatureAndInvalidPublicKey", ^{
//            __auto_type certificateData = [NSData dataWithBase64UrlEncodedString:invalidPublicKeyCertificateString];
//            __auto_type decodedDictionary = [JWTBuilder decodeMessage:validTokenToDecode].secretData(certificateData).algorithmName(algorithmName).algorithm(algorithm).decode;
//            [[(decodedDictionary) should] beNil];
//        });
//        it(@"EncodedTokenAsCanonical", ^{
//            __auto_type correctToken = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJwYXlsb2FkIjp7ImhlbGxvIjoid29ybGQifSwiaGVhZGVyIjp7ImFsZyI6IlJTMjU2IiwidHlwIjoiSldUIn19.CkrRDy5Jxp3nFEKY5MqYZIrYIQathtMmnUfxs9oKXbclNQkda5cp_bYhamKrGOKSdxdoHHUdziyFIETWJHrLK2udvxGIYF_kJmhN6-Wkq4_y5K-dqB2DvxsaNjwiw3z9haO5c0k2JzwI794rOzQGeRac3hjscuEsxF-iVE_ZRbK91dfdG6wW7mBQFa8k8I882YoQXJJTdZPiXOAmEd2it65qvp-62WQcwWs9ImPBx7XzfuB1ZnCtp_vXA3qXsbYMkPB5OZSAVmkG1QPD0koqBz9v98hCnQQs0trCWl-CM_g4x0T-kxAdkoUDvIxtUGDWhYRPn2Pw3EDDa3zM7uvHng";
//            __auto_type builder = [JWTBuilder encodePayload:headerAndPayloadDictionary].secretData(privateKeyCertificateData).privateKeyCertificatePassphrase(@"password").algorithmName(algorithmName).algorithm(algorithm);
//            __auto_type token = builder.encode;
//            [[correctToken should] equal:token];
//        });
//        it(@"StringSucceedsWithValidSignatureAndValidPublicKey", ^{
//            __auto_type decodedDictionary = [JWTBuilder decodeMessage:validTokenToDecode].secret(validPublicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm).decode;
//            assertDecodedDictionary(decodedDictionary);
//        });
//    });
    context(@"Decoding", ^{
        context(@"Valid", ^{
            it(@"StringSucceedsWithValidSignatureAndValidPublicKey", ^{
                {
                    __auto_type builder = [JWTBuilder decodeMessage:valid_token].secret(valid_publicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm);
                    __auto_type decodedDictionary = builder.decode;

                    assertDecodedDictionary(decodedDictionary);
                }
                {
                    __auto_type builder = [JWTDecodingBuilder decodeMessage:valid_token].addHolder([JWTAlgorithmRSFamilyDataHolder new].secret(valid_publicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm));
                    __auto_type result = builder.result;
                    if (result.successResult) {
                        assertDecodedDictionary(result.successResult.headerAndPayloadDictionary);
                    }
                    else {
                        NSLog(@"%@ error: %@", self, result.errorResult.error);
                    }
                }
            });
            it(@"DataSucceedsWithValidSignatureAndValidPublicKey", ^{
                __auto_type certificateData = [JWTBase64Coder dataWithBase64UrlEncodedString:valid_publicKeyCertificateString];
                __auto_type builder = [JWTBuilder decodeMessage:valid_token].secretData(certificateData).algorithmName(algorithmName).algorithm(algorithm);

                __auto_type decodedDictionary = builder.decode;
                assertDecodedDictionary(decodedDictionary);
            });
        });
        context(@"Invalid", ^{
            it(@"StringFailsWithInValidSignatureAndValidPublicKey", ^{
                __auto_type decodedDictionary = [JWTBuilder decodeMessage:invalid_token].secret(valid_publicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm).decode;
                [[(decodedDictionary) should] beNil];
            });
            it(@"StringFailsWithValidSignatureAndInvalidPublicKey", ^{
                __auto_type decodedDictionary = [JWTBuilder decodeMessage:valid_token].secret(invalid_publicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm).decode;
                [[(decodedDictionary) should] beNil];
            });
            it(@"DataFailsWithInValidSignatureAndValidPublicKey", ^{
                __auto_type certificateData = [JWTBase64Coder dataWithBase64UrlEncodedString:valid_publicKeyCertificateString];
                __auto_type decodedDictionary = [JWTBuilder decodeMessage:invalid_token].secretData(certificateData).algorithmName(algorithmName).algorithm(algorithm).decode;
                [[(decodedDictionary) should] beNil];
            });

            it(@"DataFailsWithValidSignatureAndInvalidPublicKey", ^{
                __auto_type certificateData = [JWTBase64Coder dataWithBase64UrlEncodedString:invalid_publicKeyCertificateString];
                __auto_type decodedDictionary = [JWTBuilder decodeMessage:valid_token].secretData(certificateData).algorithmName(algorithmName).algorithm(algorithm).decode;
                [[(decodedDictionary) should] beNil];
            });
        });
    });
});

SHARED_EXAMPLES_END

SPEC_BEGIN(JWTAlgorithmRS256Spec)

//    context(@"Name", ^{
//        // Use algorithm by name. JWTBuilder.algorithmName(RS256)
////        itBehavesLike(algorithmBehavior, @{});
//    });
//    context(@"Clean", ^{
////        itBehavesLike(algorithmBehavior, @{dataAlgorithmKey: [JWTAlgorithmRS256 new]});
//    });
    context(@"RSBased", ^{
        itBehavesLike(algorithmBehavior, @{dataAlgorithmKey: [JWTAlgorithmRSBase algorithm256]});
    });

SPEC_END
