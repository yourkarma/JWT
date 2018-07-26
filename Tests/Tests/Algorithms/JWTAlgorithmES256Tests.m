//
//  JWTAlgorithmES256Tests.m
//  iOS_Tests
//
//  Created by Dmitry on 7/25/18.
//

#import <XCTest/XCTest.h>

#import "JWT.h"
#import "JWTAlgorithmRSBase.h"
#import "JWTCryptoKeyExtractor.h"
#import "JWTCryptoSecurity.h"
#import "JWTCryptoKey.h"

@interface JWTAlgorithmES256Tests : XCTestCase

@end

@implementation JWTAlgorithmES256Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMain {
    [XCTContext runActivityNamed:@"Should decode well from certificates" block:^(id<XCTActivity>  _Nonnull activity) {
        // load from file?
        __auto_type passphrase = @"123";
        
        __auto_type parameters = @{
                                   JWTCryptoKey.parametersKeyBuilder : JWTCryptoKeyBuilder.new.keyTypeEC
                                   };
        __auto_type publicKey = ({
            __auto_type certificateString = [JWTCryptoSecurity certificateFromPemFileWithName:@"ec256-cer"];
            __auto_type certificateData = [JWTBase64Coder dataWithBase64UrlEncodedString:certificateString];
            NSError *error = nil;
            __auto_type result = [[JWTCryptoKeyPublic alloc] initWithCertificateData:certificateData parameters:parameters error:&error];
            error ? nil : result;
        });
        
        XCTAssert(publicKey.key != NULL);
        
        __auto_type privateKey = ({
            __auto_type p12FilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ec256" ofType:@"p12"];
            __auto_type privateKeyCertificateData = [NSData dataWithContentsOfFile:p12FilePath];
            NSError *error = nil;
            __auto_type result = [[JWTCryptoKeyPrivate alloc] initWithP12Data:privateKeyCertificateData withPassphrase:passphrase parameters:parameters error:&error];
            error ? nil : result;
        });

        XCTAssert(privateKey.key != NULL);
        
        __auto_type payload = @{
                                @"hello": @"world"
                                };
        
        __auto_type algorithm = JWTAlgorithmAsymmetricBase.withES.with256;
        __auto_type holder = [JWTAlgorithmRSFamilyDataHolder new].signKey(privateKey).verifyKey(publicKey).algorithm(algorithm).secretData([NSData data]);
        __auto_type encoded = [JWTEncodingBuilder encodePayload:payload].addHolder(holder).result;
//        NSLog(@"hey! public -> %@  private -> %@", publicKey, privateKey);        
        XCTAssertNotNil(encoded.successResult);
        
        __auto_type token = encoded.successResult.encoded;
        __auto_type decoded = [JWTDecodingBuilder decodeMessage:token].addHolder(holder).result;
        XCTAssertNotNil(decoded.successResult);
    }];
}

@end
