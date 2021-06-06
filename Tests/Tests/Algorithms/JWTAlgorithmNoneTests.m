//
//  JWTAlgorithmNoneTests.m
//  iOS_Tests
//
//  Created by Dmitry on 7/29/18.
//

#import <XCTest/XCTest.h>
#import "MF_Base64Additions.h"
#import <JWT/JWT.h>

@interface JWTAlgorithmTestsHelper__None : NSObject
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

@implementation JWTAlgorithmTestsHelper__None
- (NSDictionary <NSString *, void(^)(void)>*)configurations {
    __weak __auto_type weakSelf = self;
    return @{
             JWTAlgorithmNameNone : ^{
                 weakSelf.signedPayload = @"eyJhbGciOiJub25lIn0.eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ";
                 weakSelf.signedPayloadBase64 = @"";
                 weakSelf.signature = @"signed";
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


@interface JWTAlgorithmNoneTests : XCTestCase

@end

@implementation JWTAlgorithmNoneTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testAlgorithms {
    {
        [self theTestForAlgorithmName:@"none"];
    }
}

- (void)theTestForAlgorithmName:(NSString *)name {
    __block __auto_type helper = [[JWTAlgorithmTestsHelper__None new] configuredByName:name];

    XCTAssertNotNil(helper);
    XCTAssertNotNil(helper.algorithm);

    [XCTContext runActivityNamed:@"name is none" block:^(id<XCTActivity> _Nonnull activity){
        XCTAssertEqualObjects(helper.algorithm.name, name);
    }];

    [XCTContext runActivityNamed:@"should not encode payload and return emptry signature instead" block:^(id<XCTActivity> _Nonnull activity){
        __auto_type encodedPayload = [helper.theAlgorithm encodePayload:helper.payload withSecret:helper.secret];
        XCTAssertEqualObjects([encodedPayload base64EncodedStringWithOptions:0], helper.signedPayloadBase64);
    }];

    [XCTContext runActivityNamed:@"should not encode payload data and return emptry signature instead" block:^(id<XCTActivity> _Nonnull activity){
        __auto_type payloadData = [NSData dataWithBase64String:[helper.payload base64String]];
        __auto_type secretData = [NSData dataWithBase64String:[helper.secret base64String]];

        __auto_type encodedPayload = [helper.theAlgorithm encodePayloadData:payloadData withSecret:secretData];
        XCTAssertEqualObjects([encodedPayload base64EncodedStringWithOptions:0], helper.signedPayloadBase64);
    }];

    [XCTContext runActivityNamed:@"should not verify JWT with a secret provided" block:^(id<XCTActivity> _Nonnull activity){
        XCTAssertFalse([helper.theAlgorithm verifySignedInput:helper.signedPayload withSignature:nil verificationKey:helper.secret]);
    }];

    [XCTContext runActivityNamed:@"should not verify JWT with a signature provided" block:^(id<XCTActivity> _Nonnull activity){
        XCTAssertFalse([helper.theAlgorithm verifySignedInput:helper.signedPayload withSignature:helper.signature verificationKey:nil]);
    }];

    [XCTContext runActivityNamed:@"should verify JWT with no signature and no secret provided" block:^(id<XCTActivity> _Nonnull activity){
        XCTAssertTrue([helper.theAlgorithm verifySignedInput:helper.signedPayload withSignature:nil verificationKey:nil]);
    }];

    [XCTContext runActivityNamed:@"should not verify JWT with a secret data provided" block:^(id<XCTActivity> _Nonnull activity){
        __auto_type secretData = [NSData dataWithBase64String:[helper.secret base64String]];
        XCTAssertFalse([helper.theAlgorithm verifySignedInput:helper.signedPayload withSignature:nil verificationKeyData:secretData]);
    }];

    [XCTContext runActivityNamed:@"should not verify JWT with a signature data provided" block:^(id<XCTActivity> _Nonnull activity){
        __auto_type secretData = [NSData dataWithBase64String:nil];
        XCTAssertFalse([helper.theAlgorithm verifySignedInput:helper.signedPayload withSignature:helper.signature verificationKeyData:secretData]);
    }];

    [XCTContext runActivityNamed:@"should verify JWT with no signature and no secret data provided" block:^(id<XCTActivity> _Nonnull activity){
        __auto_type secretData = [NSData dataWithBase64String:nil];
        XCTAssertTrue([helper.theAlgorithm verifySignedInput:helper.signedPayload withSignature:nil verificationKeyData:secretData]);
    }];
}

@end
