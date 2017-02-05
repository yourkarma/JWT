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
#import "JWTCryptoKeyExtractor.h"

static NSString *algorithmBehavior = @"algorithmRS256Behaviour";
static NSString *dataAlgorithmKey = @"dataAlgorithmKey";

@interface JWTAlgorithmRS256Examples_RSA_Helper : NSObject
+ (NSString *)extractCertificateFromPemFileWithName:(NSString *)name;
+ (NSString *)extractKeyFromPemFileWithName:(NSString *)name;
+ (NSArray *)extractFromPemFileWithName:(NSString *)name byRegex:(NSRegularExpression *)expression;
@end

@implementation JWTAlgorithmRS256Examples_RSA_Helper
+ (NSString *)extractCertificateFromPemFileWithName:(NSString *)name; {
    NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:@"-----BEGIN CERTIFICATE-----(.+?)-----END CERTIFICATE-----" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    return [self extractFromPemFileWithName:name byRegex:expression].firstObject;
}
+ (NSString *)extractKeyFromPemFileWithName:(NSString *)name {
    NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:@"-----BEGIN(?:[\\w\\s]|)+KEY-----(.+?)-----END(?:[\\w\\s])+KEY-----" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    return [self extractFromPemFileWithName:name byRegex:expression].firstObject;
}
+ (NSArray *)extractFromPemFileWithName:(NSString *)name byRegex:(NSRegularExpression *)expression {
    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:name withExtension:@"pem"];
    NSError *error = nil;
    NSString *fileContent = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"%@ error: %@", self.debugDescription, error);
        return nil;
    }
    
    NSArray *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    NSTextCheckingResult *result = matches.firstObject;
    NSArray *resultArray = @[];
    
    if (result) {
        for (NSUInteger i = 1; i < result.numberOfRanges; ++i) {
            NSString *extractedString = [fileContent substringWithRange:[result rangeAtIndex:i]];
            resultArray = [resultArray arrayByAddingObject:extractedString];
        }
    }
    return resultArray;
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
        valid_publicKeyCertificateString    = [JWTAlgorithmRS256Examples_RSA_Helper extractCertificateFromPemFileWithName:@"public_256_right"];

        // From "Test certificate and public key 2.pem"
        invalid_publicKeyCertificateString  = [JWTAlgorithmRS256Examples_RSA_Helper extractCertificateFromPemFileWithName:@"public_256_wrong"];
        
        payloadDictionary = @{@"hello":@"world"};
        headerDictionary = @{@"alg":algorithmName, @"typ":@"JWT"};
        headerAndPayloadDictionary = @{JWTCodingResultHeaders : headerDictionary, JWTCodingResultPayload : payloadDictionary};
        
        NSString *p12FilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"private_256_right"
                                                                                 ofType:@"p12"];
        privateKeyCertificateData = [NSData dataWithContentsOfFile:p12FilePath];
        
        
        JWTCodingResultType *generated_token_result = [JWTEncodingBuilder encodePayload:payloadDictionary].addHolder([JWTAlgorithmRSFamilyDataHolder new].privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithmName(algorithmName).secretData(privateKeyCertificateData)).result;
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
            JWTBuilder *builder = [JWTBuilder decodeMessage:token].secret(valid_publicKeyCertificateString).algorithmName(algorithmName).algorithm(algorithm);
            
            NSDictionary *decodedDictionary = builder.decode;
            
            NSError *error = builder.jwtError;
            
            if (error) {
                NSLog(@"%@ error(%@)", self.debugDescription, error);
            }
            
            NSLog(@"%@ decodedDictionary(%@)", self.debugDescription, decodedDictionary);
            assertDecodedDictionary(decodedDictionary);
            
            NSLog(@"%@ token(%@)", self.debugDescription, token);
        };
    });

    context(@"KeyExtracting", ^{
        __block NSDictionary *keyExtractingTokens = @{};
        __block NSDictionary *keyExtractingDataHolders = @{};
        __block NSString *privateFromP12Key = @"privateFromP12Key";
        __block NSString *privatePemEncodedKey = @"privatePemEncodedKey";
        __block NSString *publicWithCertificateKey = @"publicWithCertificateKey";
        __block NSString *publicPemEncodedKey = @"publicPemEncodedKey";
        
        beforeAll(^{
//            __block NSDictionary *keyExtractingTokens = @{};
//            
//            __block NSString *privateFromP12Key = @"privateFromP12Key";
//            __block NSString *privatePemEncodedKey = @"privatePemEncodedKey";
//            __block NSString *publicWithCertificateKey = @"publicWithCertificateKey";
//            __block NSString *publicPemEncodedKey = @"publicPemEncodedKey";
            
            NSMutableDictionary *mutableKeyExtractingTokens = [keyExtractingTokens mutableCopy];
            NSMutableDictionary *mutableKeyExtractingDataHolders = [keyExtractingDataHolders mutableCopy];
            NSString *privatePemEncodedString = [JWTAlgorithmRS256Examples_RSA_Helper extractKeyFromPemFileWithName:@"private_256_right"];
            NSString *publicPemEncodedString = [JWTAlgorithmRS256Examples_RSA_Helper extractKeyFromPemFileWithName:@"public_256_right"];
            {
                // private from p12
                NSString *key = privateFromP12Key;
                JWTCodingResultType *result = nil;
                id<JWTAlgorithmDataHolderProtocol> dataHolder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor privateKeyInP12].type).privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithm(algorithm).algorithmName(algorithmName).secretData(privateKeyCertificateData);
                
                mutableKeyExtractingDataHolders[key] = dataHolder;
                
                JWTCodingBuilder *newBuilder = [JWTEncodingBuilder encodePayload:payloadDictionary].addHolder(dataHolder);
                
                result = newBuilder.result;
                if (result.successResult) {
                    mutableKeyExtractingTokens[key] = result.successResult.encoded;
                }
            }
            {
                // private pem encoded
                NSString *key = privatePemEncodedKey;
                JWTCodingResultType *result = nil;
                id<JWTAlgorithmDataHolderProtocol> dataHolder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor privateKeyWithPEMBase64].type).privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithm(algorithm).algorithmName(algorithmName).secret(privatePemEncodedString);
                
                mutableKeyExtractingDataHolders[key] = dataHolder;
                
                JWTCodingBuilder *newBuilder = [JWTEncodingBuilder encodePayload:payloadDictionary].addHolder(dataHolder);
                
                result = newBuilder.result;
                if (result.successResult) {
                    mutableKeyExtractingTokens[key] = result.successResult.encoded;
                }
            }
            {
                // public from certificate
                NSString *key = publicWithCertificateKey;
                JWTCodingResultType *result = nil;
                id<JWTAlgorithmDataHolderProtocol> dataHolder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor publicKeyWithCertificate].type).algorithm(algorithm).algorithmName(algorithmName).secret(valid_publicKeyCertificateString);
                
                mutableKeyExtractingDataHolders[key] = dataHolder;
                
                JWTCodingBuilder *newBuilder = [JWTEncodingBuilder encodePayload:payloadDictionary].addHolder(dataHolder);
                
                result = newBuilder.result;
                
                if (result.successResult) {
//                    mutableKeyExtractingTokens[key] = result.successResult.encoded;
                }
            }
            
            {
                // public pem encoded.
                NSString *key = publicPemEncodedKey;
                JWTCodingResultType *result = nil;
                id<JWTAlgorithmDataHolderProtocol> dataHolder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor publicKeyWithPEMBase64].type).algorithm(algorithm).algorithmName(algorithmName).secret(publicPemEncodedString);
                
                mutableKeyExtractingDataHolders[key] = dataHolder;
                
                JWTCodingBuilder *newBuilder = [JWTEncodingBuilder encodePayload:payloadDictionary].addHolder(dataHolder);
                
                result = newBuilder.result;
                if (result.successResult) {
//                    mutableKeyExtractingTokens[key] = result.successResult.encoded;
                }
            }
            keyExtractingTokens = [mutableKeyExtractingTokens copy];
            keyExtractingDataHolders = [mutableKeyExtractingDataHolders copy];
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
                        if ([decodeByKey hasPrefix:@"publicPem"]) {
                            continue;
                        }
                        NSString *token = keyExtractingTokens[key];
                        JWTCodingBuilder *newBuilder = [JWTDecodingBuilder decodeMessage:token].addHolder(dataHolder);
                        JWTCodingResultType *result = newBuilder.result;
                        if (result.successResult) {
                            NSLog(@"Pair: <%@> decodeBy <%@> passed", key, decodeByKey);
                            assertDecodedDictionary(result.successResult.headerAndPayloadDictionary);
                        }
                        else {
                            NSLog(@"Pair: <%@> decodeBy <%@> failed", key, decodeByKey);
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
                    JWTBuilder *builder = [JWTBuilder encodePayload:payloadDictionary].secretData(privateKeyCertificateData).privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithmName(algorithmName).algorithm(algorithm);
                    NSString *token = builder.encode;
                    assertToken(token);
                }
                {
                    JWTCodingBuilder *newBuilder = [JWTEncodingBuilder encodePayload:payloadDictionary].addHolder([JWTAlgorithmRSFamilyDataHolder new].privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithm(algorithm).algorithmName(algorithmName).secretData(privateKeyCertificateData));
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
                NSString *token = [JWTBuilder encodePayload:payloadDictionary].secret(certificateString).privateKeyCertificatePassphrase(valid_privateKeyCertificatePassphrase).algorithmName(algorithmName).algorithm(algorithm).encode;
                NSLog(@"token: %@\n valid_token: %@\n publicKey: %@\n headerAndPayloadDictionary: %@\n privateKey: %@",token,valid_token, valid_publicKeyCertificateString, headerAndPayloadDictionary, privateKeyCertificateData);
                assertToken(token);
            });
        });
        
        context(@"Invalid", ^{
            it(@"DataWithInvalidPrivateKeyCertificatePassphrase", ^{
                NSString *token = [JWTBuilder encodePayload:payloadDictionary].secretData(privateKeyCertificateData).privateKeyCertificatePassphrase(invalid_privateKeyCertificatePassphrase).algorithmName(algorithmName).algorithm(algorithm).encode;
                [[(token) should] beNil];
            });
            it(@"StringWithInvalidPrivateKeyCertificatePassphrase", ^{
                NSString *certificateString = [privateKeyCertificateData base64UrlEncodedString];
                NSString *token = [JWTBuilder encodePayload:payloadDictionary].secret(certificateString).privateKeyCertificatePassphrase(invalid_privateKeyCertificatePassphrase).algorithmName(algorithmName).algorithm(algorithm).encode;
                [[(token) should] beNil];
            });
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
            it(@"DataSucceedsWithValidSignatureAndValidPublicKey", ^{
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
