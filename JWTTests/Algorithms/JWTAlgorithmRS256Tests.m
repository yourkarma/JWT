//
//  JWTAlgorithmRS256Tests.m
//  JWT
//
//  Created by Marcelo Schroeder on 11/03/2016.
//  Copyright © 2016 Karma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JWT.h"
#import "MF_Base64Additions.h"

@interface JWTAlgorithmRS256Tests : XCTestCase

@property(nonatomic) NSString *tokenToDecode;
@property(nonatomic, copy) NSString *publicKeyCertificateString;
@property(nonatomic, strong) NSData *privateKeyCertificateData;
@property(nonatomic, copy) NSString *algorithmName;
@property(nonatomic, strong) NSDictionary *headerAndPayloadDictionary;
@end

@implementation JWTAlgorithmRS256Tests

- (void)testEncodeCertificateData {
    NSString *token = [JWTBuilder encodePayload:self.headerAndPayloadDictionary].secretData(self.privateKeyCertificateData).algorithmName(self.algorithmName).encode;
//    NSLog(@"token = %@", token);
    [self assertToken:token];
}

- (void)testEncodeCertificateString {
    NSString *certificateString = [self.privateKeyCertificateData base64UrlEncodedString];
    NSString *token = [JWTBuilder encodePayload:self.headerAndPayloadDictionary].secret(certificateString).algorithmName(self.algorithmName).encode;
    [self assertToken:token];
}

- (void)testDecodeCertificateString {
    JWTBuilder *builder = [JWTBuilder decodeMessage:self.tokenToDecode].secret(self.publicKeyCertificateString).algorithmName(self.algorithmName);
    NSDictionary *decodedDictionary = builder.decode;
    [self assertDecodedDictionary:decodedDictionary];
}

- (void)testDecodeCertificateData {
    NSData *certificateData = [NSData dataWithBase64UrlEncodedString:self.publicKeyCertificateString];
    JWTBuilder *builder = [JWTBuilder decodeMessage:self.tokenToDecode].secretData(certificateData).algorithmName(self.algorithmName);
    NSDictionary *decodedDictionary = builder.decode;
    [self assertDecodedDictionary:decodedDictionary];
}

#pragma mark - Overrides

- (void)setUp {
    [super setUp];
    self.tokenToDecode = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJoZWxsbyI6ICJ3b3JsZCJ9.AzXfyb6BuwLgNUqVkfiKeQRctG25u3-5DJIsGyDnFxOGTet74SjW6Aabm3LSXZ2HgQ5yp8_tCfqA12oDmPiviq4muhgc0LKujTpGtFlf0fcSJQJpxSTMGQZdZnxdKpz7dCSlQNvW6j1tGy1UWkXod-kf4FZckoDkGEbnRAVVVL7xRupFtLneUJGoWZCiMz5oYAoYMUY1bVil1S6lIwUJLtgsvrQMoVIcjlivjZ8fzF3tjQdInxCjYeOKD3WQ2-n3APg-1GEJT-l_2y-scbE55TPSxo9fpHoDn7G0Kcgl8wpjY4j3KR9dEa4unJN3necd83yCMOUzs6vmFncEMTrRZw";
    self.publicKeyCertificateString = @"MIICnTCCAYUCBEReYeAwDQYJKoZIhvcNAQEFBQAwEzERMA8GA1UEAxMIand0LTIwNDgwHhcNMTQwMTI0MTMwOTE2WhcNMzQwMjIzMjAwMDAwWjATMREwDwYDVQQDEwhqd3QtMjA0ODCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKhWb9KXmv45+TKOKhFJkrboZbpbKPJ9Yp12xKLXf8060KfStEStIX+7dCuAYylYWoqiGpuLVVUL5JmHgXmK9TJpzv9Dfe3TAc/+35r8r9IYB2gXUOZkebty05R6PLY0RO/hs2ZhrOozHMo+x216Gwz0CWaajcuiY5Yg1V8VvJ1iQ3rcRgZapk49RNX69kQrGS63gzj0gyHnRtbqc/Ua2kobCA83nnznCom3AGinnlSN65AFPP5jmri0l79+4ZZNIerErSW96mUF8jlJFZI1yJIbzbv73tL+y4i0+BvzsWBs6TkHAp4pinaI8zT+hrVQ2jD4fkJEiRN9lAqLPUd8CNkCAwEAATANBgkqhkiG9w0BAQUFAAOCAQEAnqBw3UHOSSHtU7yMi1+HE+9119tMh7X/fCpcpOnjYmhW8uy9SiPBZBl1z6vQYkMPcURnDMGHdA31kPKICZ6GLWGkBLY3BfIQi064e8vWHW7zX6+2Wi1zFWdJlmgQzBhbr8pYh9xjZe6FjPwbSEuS0uE8dWSWHJLdWsA4xNX9k3pr601R2vPVFCDKs3K1a8P/Xi59kYmKMjaX6vYT879ygWt43yhtGTF48y85+eqLdFRFANTbBFSzdRlPQUYa5d9PZGxeBTcg7UBkK/G+d6D5sd78T2ymwlLYrNi+cSDYD6S4hwZaLeEK6h7p/OoG02RBNuT4VqFRu5DJ6Po+C6JhqQ==";
    self.algorithmName = @"RS256";
    self.headerAndPayloadDictionary = @{
            @"header" : @{
                    @"alg" : @"RS256",
                    @"typ" : @"JWT",
            },
            @"payload" : @{
                    @"hello" : @"world",
            }
    };
    NSString *p12FilePath = [[NSBundle bundleForClass:[JWTAlgorithmRS256Tests class]] pathForResource:@"Test certificate and private key"
                                                                                               ofType:@"p12"];
    self.privateKeyCertificateData = [NSData dataWithContentsOfFile:p12FilePath];
}

#pragma mark - Private

- (void)assertDecodedDictionary:(NSDictionary *)decodedDictionary {
    XCTAssertNotNil(decodedDictionary);
    XCTAssertEqualObjects(decodedDictionary, self.headerAndPayloadDictionary);
}

- (void)assertToken:(NSString *)token {
    XCTAssertEqualObjects(token, @"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJoZWFkZXIiOnsiYWxnIjoiUlMyNTYiLCJ0eXAiOiJKV1QifSwicGF5bG9hZCI6eyJoZWxsbyI6IndvcmxkIn19.5_up87yyEBBWWifXQyuUdYHFpxoZB7tiEdUS1sVceI1AcR3WseGoCqHEY2i2KEhm3LWd_TQDksUwGayss4Z-WwneFJy1QQIyLZHkukJRy_FNTVJhPm-l7dKdmMCzVaVarx9MPXDPx94S0PJ29UuNwFu75ZB9rYb3rQNkt2V9oBlON3rGGlUO_gKT1DjzCgTbndW82SJh8np4TMKQti6tKxza-0iSGu1KUMYqX9Uxl0babj67IdnU93M9Hb3vcD0kiLb7S9j0WZk9BA26ERgJudat_ojxUNiuQ9tk0PwKeADMCu_M4RFCB7xvIDCwDppg0r43i_5kCDju-JVYXEpGtA");
}

@end
