//
//  JWTCodingTests.m
//  
//
//  Created by Dmitry Lobanov on 06.02.2022.
//

#import <XCTest/XCTest.h>
@import JWT;

@interface JWTCodingTests : XCTestCase

@end

@implementation JWTCodingTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testJWTCodingBuilderShouldEncode {
    __auto_type expectedToken = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
    __auto_type secret = @"secret";
    __auto_type payload = @{
        @"sub": @"1234567890",
        @"name": @"John Doe",
        @"admin": @(YES),
    };
    
    __auto_type holder = [JWTAlgorithmHSFamilyDataHolder new].algorithmName(JWTAlgorithmNameHS256).secret(secret);
    __auto_type result = [JWTEncodingBuilder encodePayload:payload].addHolder(holder).result;
    XCTAssertNotNil(result.successResult);
    XCTAssertEqualObjects(result.successResult.encoded, expectedToken);
    XCTAssertNil(result.errorResult);
}


- (void)testJWTCodingBuilderShouldDecode {
    __auto_type token = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
    __auto_type secret = @"secret";
    __auto_type expectedHeaders = @{
        @"typ": @"JWT",
        @"alg": @"HS256"
    };
    __auto_type expectedPayload = @{
        @"admin": @(1),
        @"name": @"John Doe",
        @"sub": @"1234567890"
    };
    
    __auto_type holder = [JWTAlgorithmHSFamilyDataHolder new].algorithmName(JWTAlgorithmNameHS256).secret(secret);
    __auto_type result = [JWTDecodingBuilder decodeMessage:token].addHolder(holder).result;
    XCTAssertNotNil(result.successResult);
    XCTAssertEqualObjects(result.successResult.headers, expectedHeaders);
    XCTAssertEqualObjects(result.successResult.payload, expectedPayload);
    XCTAssertNil(result.errorResult);
}

@end
