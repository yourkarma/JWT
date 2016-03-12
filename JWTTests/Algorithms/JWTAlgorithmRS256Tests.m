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

@property(nonatomic) NSString *validTokenToDecode;
@property(nonatomic) NSString *invalidTokenToDecode;
@property(nonatomic) NSString *validPublicKeyCertificateString;
@property(nonatomic) NSString *invalidPublicKeyCertificateString;
@property(nonatomic) NSData *privateKeyCertificateData;
@property(nonatomic) NSString *algorithmName;
@property(nonatomic) NSDictionary *headerAndPayloadDictionary;
@end

@implementation JWTAlgorithmRS256Tests

- (void)testEncodeCertificateData {
    NSString *token = [JWTBuilder encodePayload:self.headerAndPayloadDictionary].secretData(self.privateKeyCertificateData).algorithmName(self.algorithmName).encode;
    [self assertToken:token];
}

- (void)testEncodeCertificateString {
    NSString *certificateString = [self.privateKeyCertificateData base64UrlEncodedString];
    NSString *token = [JWTBuilder encodePayload:self.headerAndPayloadDictionary].secret(certificateString).algorithmName(self.algorithmName).encode;
    [self assertToken:token];
}

- (void)testThatDecodeCertificateStringSucceedsWithValidSignatureAndValidPublicKey {
    NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:self.validTokenToDecode].secret(self.validPublicKeyCertificateString).algorithmName(self.algorithmName).decode;
    [self assertDecodedDictionary:decodedDictionary];
}

- (void)testThatDecodeCertificateStringFailsWithInValidSignatureAndValidPublicKey {
    NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:self.invalidTokenToDecode].secret(self.validPublicKeyCertificateString).algorithmName(self.algorithmName).decode;
    XCTAssertNil(decodedDictionary);
}

- (void)testThatDecodeCertificateStringFailsWithValidSignatureAndInvalidPublicKey {
    NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:self.validTokenToDecode].secret(self.invalidPublicKeyCertificateString).algorithmName(self.algorithmName).decode;
    XCTAssertNil(decodedDictionary);
}

- (void)testThatDecodeCertificateDataSucceedsWithValidSignatureAndValidPublicKey {
    NSData *certificateData = [NSData dataWithBase64UrlEncodedString:self.validPublicKeyCertificateString];
    NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:self.validTokenToDecode].secretData(certificateData).algorithmName(self.algorithmName).decode;
    [self assertDecodedDictionary:decodedDictionary];
}

- (void)testThatDecodeCertificateDataFailsWithInValidSignatureAndValidPublicKey {
    NSData *certificateData = [NSData dataWithBase64UrlEncodedString:self.validPublicKeyCertificateString];
    NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:self.invalidTokenToDecode].secretData(certificateData).algorithmName(self.algorithmName).decode;
    XCTAssertNil(decodedDictionary);
}

- (void)testThatDecodeCertificateDataFailsWithValidSignatureAndInvalidPublicKey {
    NSData *certificateData = [NSData dataWithBase64UrlEncodedString:self.invalidPublicKeyCertificateString];
    NSDictionary *decodedDictionary = [JWTBuilder decodeMessage:self.validTokenToDecode].secretData(certificateData).algorithmName(self.algorithmName).decode;
    XCTAssertNil(decodedDictionary);
}

#pragma mark - Overrides

- (void)setUp {
    [super setUp];
    self.validTokenToDecode     = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJoZWxsbyI6ICJ3b3JsZCJ9.AzXfyb6BuwLgNUqVkfiKeQRctG25u3-5DJIsGyDnFxOGTet74SjW6Aabm3LSXZ2HgQ5yp8_tCfqA12oDmPiviq4muhgc0LKujTpGtFlf0fcSJQJpxSTMGQZdZnxdKpz7dCSlQNvW6j1tGy1UWkXod-kf4FZckoDkGEbnRAVVVL7xRupFtLneUJGoWZCiMz5oYAoYMUY1bVil1S6lIwUJLtgsvrQMoVIcjlivjZ8fzF3tjQdInxCjYeOKD3WQ2-n3APg-1GEJT-l_2y-scbE55TPSxo9fpHoDn7G0Kcgl8wpjY4j3KR9dEa4unJN3necd83yCMOUzs6vmFncEMTrRZw";
    self.invalidTokenToDecode   = @"I_have_been_modified_nR5cCI6IkpXVCJ9.eyJoZWxsbyI6ICJ3b3JsZCJ9.AzXfyb6BuwLgNUqVkfiKeQRctG25u3-5DJIsGyDnFxOGTet74SjW6Aabm3LSXZ2HgQ5yp8_tCfqA12oDmPiviq4muhgc0LKujTpGtFlf0fcSJQJpxSTMGQZdZnxdKpz7dCSlQNvW6j1tGy1UWkXod-kf4FZckoDkGEbnRAVVVL7xRupFtLneUJGoWZCiMz5oYAoYMUY1bVil1S6lIwUJLtgsvrQMoVIcjlivjZ8fzF3tjQdInxCjYeOKD3WQ2-n3APg-1GEJT-l_2y-scbE55TPSxo9fpHoDn7G0Kcgl8wpjY4j3KR9dEa4unJN3necd83yCMOUzs6vmFncEMTrRZw";

    // From "Test certificate and public key 1.pem"
    self.validPublicKeyCertificateString    = @"MIICnTCCAYUCBEReYeAwDQYJKoZIhvcNAQEFBQAwEzERMA8GA1UEAxMIand0LTIwNDgwHhcNMTQwMTI0MTMwOTE2WhcNMzQwMjIzMjAwMDAwWjATMREwDwYDVQQDEwhqd3QtMjA0ODCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKhWb9KXmv45+TKOKhFJkrboZbpbKPJ9Yp12xKLXf8060KfStEStIX+7dCuAYylYWoqiGpuLVVUL5JmHgXmK9TJpzv9Dfe3TAc/+35r8r9IYB2gXUOZkebty05R6PLY0RO/hs2ZhrOozHMo+x216Gwz0CWaajcuiY5Yg1V8VvJ1iQ3rcRgZapk49RNX69kQrGS63gzj0gyHnRtbqc/Ua2kobCA83nnznCom3AGinnlSN65AFPP5jmri0l79+4ZZNIerErSW96mUF8jlJFZI1yJIbzbv73tL+y4i0+BvzsWBs6TkHAp4pinaI8zT+hrVQ2jD4fkJEiRN9lAqLPUd8CNkCAwEAATANBgkqhkiG9w0BAQUFAAOCAQEAnqBw3UHOSSHtU7yMi1+HE+9119tMh7X/fCpcpOnjYmhW8uy9SiPBZBl1z6vQYkMPcURnDMGHdA31kPKICZ6GLWGkBLY3BfIQi064e8vWHW7zX6+2Wi1zFWdJlmgQzBhbr8pYh9xjZe6FjPwbSEuS0uE8dWSWHJLdWsA4xNX9k3pr601R2vPVFCDKs3K1a8P/Xi59kYmKMjaX6vYT879ygWt43yhtGTF48y85+eqLdFRFANTbBFSzdRlPQUYa5d9PZGxeBTcg7UBkK/G+d6D5sd78T2ymwlLYrNi+cSDYD6S4hwZaLeEK6h7p/OoG02RBNuT4VqFRu5DJ6Po+C6JhqQ==";

    // From "Test certificate and public key 2.pem"
    self.invalidPublicKeyCertificateString  = @"MIIDVzCCAj+gAwIBAgIBATANBgkqhkiG9w0BAQsFADBMMR8wHQYDVQQDDBZEaWdpdGFsIFNpZ25pbmcgVGVzdCAyMQswCQYDVQQGEwJBVTEcMBoGCSqGSIb3DQEJARYNdGVzdEB0ZXN0LmNvbTAeFw0xNjAzMTIwMDUzMDJaFw0xNzAzMTIwMDUzMDJaMEwxHzAdBgNVBAMMFkRpZ2l0YWwgU2lnbmluZyBUZXN0IDIxCzAJBgNVBAYTAkFVMRwwGgYJKoZIhvcNAQkBFg10ZXN0QHRlc3QuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtQ57lsgAE5eWahnJ4e9InudO6rtJ12qE/qaeBrU8qcmJ0ku78Ih2gnShRtdmJGaDgGH1hM6J+ucQvl87foNqJPeAN+s5GeiGw4yoaHTnibJ9/v8rzz+PzMwXn6EGykaL6eDAIIOKNcMXvjWZEXtwr/roOFbaEIe6JeqNeSb2mXS+1XI5NGCL4jp8y0WmNCp/0LUMGQyj2ilmIgaV74cB2xdxPozZZJnWDASkgbGzi4ijZCpOP/yksEvJ7JSNBmmAQoFNslMymOO3XYJs3yvR9thwRl/uHbY4gHRPGHramCdJ6s+Lw+gzCjslB87HsIy4pp6PeDiOe/tyc79LWcsLbQIDAQABo0QwQjAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwQwGAYDVR0RBBEwD4ENdGVzdEB0ZXN0LmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAmlDHOKSdE8sRbUHNWZtyghm7FUBcrEEB/mM/dtRbq7aUFEPtHpXdKGf/fC0TZxdLoKfIFvgEuPlvzwgFhHTW3qzY4dES0n2krALVkfT0IR72vR98AGEE2gchSqGtwr1KkvYE8A4IwU+mlrDzVZoE0OjRg73Klpaxc77ln34CB+yAIlL1uunIZj+zmCuhsK4i6QAjzJ1PaNXo5P9F4zfJDW4B0ej6/2V9nxBvWW8hdba/eVbDltkvw0dZZay6YgBmVz9mXbAGZ6pk2XOjTlS3XLFgLUVe8WTXbktQw0cCcf3xfn6HB/Y+5l/0srZ3i5Su5qtdDDbZ3epBjB3K5kiP8g==";

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
    NSString *p12FilePath = [[NSBundle bundleForClass:[JWTAlgorithmRS256Tests class]] pathForResource:@"Test certificate and private key 1"
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
    NSLog(@"token = %@", token);
}

@end
