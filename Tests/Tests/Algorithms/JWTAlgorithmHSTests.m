//
//  JWTAlgorithmHSTests.m
//  iOS_Tests
//
//  Created by Dmitry on 7/29/18.
//

#import <XCTest/XCTest.h>
#import "MF_Base64Additions.h"
#import <JWT/JWT.h>

@interface JWTAlgorithmHSTestsHelper : NSObject
@property (copy, nonatomic, readwrite) NSString *payload;
@property (copy, nonatomic, readwrite) NSString *signedPayload;
@property (copy, nonatomic, readwrite) NSString *signedPayloadBase64;
@property (copy, nonatomic, readwrite) NSString *secret;
@property (copy, nonatomic, readwrite) NSString *wrongSecret;
@property (copy, nonatomic, readwrite) NSString *signature;
@property (copy, nonatomic, readwrite) NSString *name;
- (instancetype)configuredByName:(NSString *)name;

@property (strong, nonatomic, readwrite) id <JWTAlgorithm> algorithm;
@property (strong, nonatomic, readwrite) JWTAlgorithmHolder *theAlgorithm;
@end

@implementation JWTAlgorithmHSTestsHelper
- (NSDictionary <NSString *, void(^)(void)>*)configurations {
    __weak __auto_type weakSelf = self;
    return @{
             JWTAlgorithmNameHS256 : ^{
                 weakSelf.signedPayload = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
                 weakSelf.signedPayloadBase64 = @"uC/LeRrOxXhZuYm0MKgmSIzi5Hn9+SMmvQoug3WkK6Q=";
                 weakSelf.signature = @"TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
             },

             JWTAlgorithmNameHS384 : ^{
                 weakSelf.signedPayload = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
                 weakSelf.signedPayloadBase64 = @"s62aZf5ZLMSvjtBQpY4kiJbYxSu8wLAUop2D9nod5Eqgd+nyUCEj+iaDuVuI4gaJ";
                 weakSelf.signature = @"hnzqaUFa2kfSFnynQ_WBJ7-wpLCgsyEdilCkRKliadjVuG-hGnc1qhvIjlvxSie5";
             },
             JWTAlgorithmNameHS512 : ^{
                 weakSelf.signedPayload = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9";
                 weakSelf.signedPayloadBase64 = @"KR3aqiPK+jqq4cl1U5H0vvNbvby5JzmlYYpciW9lINKw0o0tKYfayXR54xIUpR2Wz86voo5GpPlhtjxGNSoYng==";
                 weakSelf.signature = @"SerC5MWQIs3fRH6ZD7gKKbq51TsyydXTvl23WpD9sA085SzQ7pK6M0TnYjFITNUkwuniGG5Is2OKJCEIHPn1Kg";
             }
             };
}
- (void)generalConfigure {
    self.payload = @"payload";
    self.secret = @"secret";
    self.wrongSecret = @"notTheSecret";
}
- (instancetype)configuredByName:(NSString *)name {
    __auto_type configured = [self configurations][name];
    if (configured) {
        [self generalConfigure];
        configured();
        self.name = name;
    }
    // choose configuration here?
    self.algorithm = [JWTAlgorithmFactory algorithmByName:name];
    self.theAlgorithm = [[JWTAlgorithmHolder alloc] initWithAlgorithm:self.algorithm];
    return self;
}
@end

@interface JWTAlgorithmHSTests : XCTestCase

@end

@implementation JWTAlgorithmHSTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAlgorithms {
    {
        [self theTestForAlgorithmName:@"HS256"];
    }
    {
        [self theTestForAlgorithmName:@"HS384"];
    }
    {
        [self theTestForAlgorithmName:@"HS512"];
    }
}

- (void)theTestForAlgorithmName:(NSString *)name {
    __block __auto_type helper = [[JWTAlgorithmHSTestsHelper new] configuredByName:name];

    XCTAssertNotNil(helper);
    XCTAssertNotNil(helper.algorithm);

    [XCTContext runActivityNamed:@"name is from HS family" block:^(id<XCTActivity>  _Nonnull activity) {
        XCTAssertEqualObjects(helper.algorithm.name, helper.name);
    }];
    
    [XCTContext runActivityNamed:@"HMAC encodes the payload using SHA256" block:^(id<XCTActivity> _Nonnull activity) {
        __auto_type encodedPayload = [helper.theAlgorithm encodePayload:helper.payload withSecret:helper.secret];
        XCTAssertEqualObjects([encodedPayload base64String], helper.signedPayloadBase64);
    }];
    
    [XCTContext runActivityNamed:@"HMAC encodes the payload data using SHA256" block:^(id<XCTActivity> _Nonnull activity) {
        __auto_type payloadData = [NSData dataWithBase64String:[helper.payload base64String]];
        __auto_type secretData = [NSData dataWithBase64String:[helper.secret base64String]];
        
        __auto_type encodedPayload = [helper.theAlgorithm encodePayloadData:payloadData withSecret:secretData];
        XCTAssertEqualObjects([encodedPayload base64String], helper.signedPayloadBase64);
    }];
    
    [XCTContext runActivityNamed:@"HMAC encodes the payload canonically" block:^(id<XCTActivity> _Nonnull activity) {
        XCTAssertTrue([helper.theAlgorithm verifySignedInput:helper.signedPayload withSignature:helper.signature verificationKey:helper.secret]);
    }];

    [XCTContext runActivityNamed:@"should verify JWT with valid signature and secret" block:^(id<XCTActivity> _Nonnull activity) {
        XCTAssertTrue([helper.theAlgorithm verifySignedInput:helper.signedPayload withSignature:helper.signature verificationKey:helper.secret]);
    }];

    [XCTContext runActivityNamed:@"should fail to verify JWT with invalid secret" block:^(id<XCTActivity> _Nonnull activity) {
        XCTAssertFalse([helper.theAlgorithm verifySignedInput:helper.signedPayload withSignature:helper.signature verificationKey:helper.wrongSecret]);
    }];

    [XCTContext runActivityNamed:@"should fail to verify JWT with invalid signature" block:^(id<XCTActivity> _Nonnull activity) {
        XCTAssertFalse([helper.theAlgorithm verifySignedInput:helper.signedPayload withSignature:nil verificationKey:helper.secret]);
    }];

    [XCTContext runActivityNamed:@"should verify JWT with valid signature and secret Data" block:^(id<XCTActivity> _Nonnull activity) {
        __auto_type secretData = [NSData dataWithBase64String:[helper.secret base64String]];
        XCTAssertTrue([helper.theAlgorithm verifySignedInput:helper.signedPayload withSignature:helper.signature verificationKeyData:secretData]);
    }];

    [XCTContext runActivityNamed:@"should fail to verify JWT with invalid secret" block:^(id<XCTActivity> _Nonnull activity) {
        __auto_type secretData = [NSData dataWithBase64String:[helper.wrongSecret base64String]];
        XCTAssertFalse([helper.theAlgorithm verifySignedInput:helper.signedPayload withSignature:helper.signature verificationKeyData:secretData]);
    }];

    [XCTContext runActivityNamed:@"should fail to verify JWT with invalid signature" block:^(id<XCTActivity> _Nonnull activity) {
        __auto_type secretData = [NSData dataWithBase64String:[helper.secret base64String]];
        XCTAssertFalse([helper.theAlgorithm verifySignedInput:helper.signedPayload withSignature:nil verificationKeyData:secretData]);
    }];
}

@end
