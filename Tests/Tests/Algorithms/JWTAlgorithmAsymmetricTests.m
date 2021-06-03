//
//  JWTAlgorithmAsymmetricTests.m
//  iOS_Tests
//
//  Created by Dmitry on 7/29/18.
//

#import <XCTest/XCTest.h>
#import <JWT/JWT.h>

@interface JWTAlgorithmAsymmetricTestsHelperAssetAccessor : NSObject
@property (copy, nonatomic, readwrite) NSString *folder;
- (instancetype)initWithFolder:(NSString *)folder;
- (instancetype)initWithAlgorithmType:(NSString *)type shaSize:(NSNumber *)size;
- (instancetype)initWithAlgorithName:(NSString *)name;
@end

@interface JWTAlgorithmAsymmetricTestsHelperAssetAccessor (Validation)
- (instancetype)checked;
- (BOOL)check;
@end

@interface JWTAlgorithmAsymmetricTestsHelperAssetAccessor (FolderAccess)
- (NSString *)stringFromFileWithName:(NSString *)name;
- (NSData *)dataFromFileWithName:(NSString *)name;
@end

@implementation JWTAlgorithmAsymmetricTestsHelperAssetAccessor (FolderAccess)
- (NSString *)stringFromFileWithName:(NSString *)name {
    __auto_type data = [self dataFromFileWithName:name];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSData *)dataFromFileWithName:(NSString *)name {
    __auto_type path = [self.folder stringByAppendingPathComponent:name];
    __auto_type asset = [[NSDataAsset alloc] initWithName:path bundle:[NSBundle bundleForClass:self.class]];
    __auto_type data = asset.data;
    return data;
}
@end

@interface JWTAlgorithmAsymmetricTestsHelperAssetAccessor (Getters)
@property (copy, nonatomic, readonly) NSString *privateKeyBase64;
@property (copy, nonatomic, readonly) NSString *publicKeyBase64;
@property (copy, nonatomic, readonly) NSString *certificateBase64;
@property (copy, nonatomic, readonly) NSData *p12Data;
@property (copy, nonatomic, readonly) NSString *p12Password;
@end

@implementation JWTAlgorithmAsymmetricTestsHelperAssetAccessor (Getters)
- (NSString *)privateKeyBase64 {
    return [self stringFromFileWithName:@"private.pem"];
}
- (NSString *)publicKeyBase64 {
    return [self stringFromFileWithName:@"public.pem"];
}
- (NSString *)certificateBase64 {
    return [self stringFromFileWithName:@"certificate.cer"];
}
- (NSData *)p12Data {
    return [self dataFromFileWithName:@"private.p12"];
}
- (NSString *)p12Password {
    return [self stringFromFileWithName:@"p12_password.txt"];
}
@end

@implementation JWTAlgorithmAsymmetricTestsHelperAssetAccessor
- (instancetype)initWithFolder:(NSString *)folder {
    if (self = [super init]) {
        self.folder = folder;
        // check that data exists!
        if (!self.check) {
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithAlgorithmType:(NSString *)type shaSize:(NSNumber *)size {
    return [self initWithFolder:[type stringByAppendingPathComponent:size.description]];
}

+ (NSArray *)typeAndSizeFromAlgorithmName:(NSString *)name {
    if (name.length < 3) {
        return nil;
    }
    __auto_type type = [name substringToIndex:2];
    __auto_type size = [name substringFromIndex:2];
    if (type == nil || size == nil) {
        return nil;
    }
    return @[type, size];
}

- (instancetype)initWithAlgorithName:(NSString *)name {
    // split name into type and size.
    // just lowercase everything.
    return [self initWithFolder:name.lowercaseString];
}
@end

@implementation JWTAlgorithmAsymmetricTestsHelperAssetAccessor (Validation)
- (instancetype)checked {
    return self.check ? self : nil;
}
- (BOOL)check {
    return self.privateKeyBase64 != nil;
}
@end

@interface JWTAlgorithmAsymmetricTestsHelper : NSObject
@property (copy, nonatomic, readwrite) NSDictionary *payloadDictionary;
@property (copy, nonatomic, readwrite) NSDictionary *headersDictionary;
@property (copy, nonatomic, readwrite) NSDictionary *fullDictionary;
@property (copy, nonatomic, readwrite) NSDictionary *cryptoKeyBuilderParameters;

- (instancetype)configuredByName:(NSString *)name;
@property (copy, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic, readwrite) id <JWTAlgorithm> algorithm;

- (instancetype)configuredByToken:(NSString *)token;
@property (copy, nonatomic, readwrite) NSString *token;
@property (copy, nonatomic, readwrite) NSString *invalidToken;

- (instancetype)configuredByAssetAccessor:(JWTAlgorithmAsymmetricTestsHelperAssetAccessor *)accessor;
@property (strong, nonatomic, readwrite) JWTAlgorithmAsymmetricTestsHelperAssetAccessor *accessor;
@end

@interface JWTAlgorithmAsymmetricTestsHelper (Wrong)
+ (instancetype)wrong;
- (instancetype)wrong;
@end

@interface JWTAlgorithmAsymmetricTests__ExtractionKeys : NSObject
// Container Keys
@property (copy, nonatomic, readonly, class) NSString *Tokens;
@property (copy, nonatomic, readonly, class) NSString *Holders;

// Extraction Types
@property (copy, nonatomic, readonly, class) NSString *PrivateKeyFromP12;
@property (copy, nonatomic, readonly, class) NSString *PublicKeyFromCertificate;
@property (copy, nonatomic, readonly, class) NSString *PrivateKeyFromPem;
@property (copy, nonatomic, readonly, class) NSString *PublicKeyFromPem;

@end

@implementation JWTAlgorithmAsymmetricTests__ExtractionKeys

+ (NSString *)Holders { return NSStringFromSelector(_cmd); }
+ (NSString *)Tokens { return NSStringFromSelector(_cmd); }

+ (NSString *)PrivateKeyFromPem { return NSStringFromSelector(_cmd); }
+ (NSString *)PrivateKeyFromP12 { return NSStringFromSelector(_cmd); }
+ (NSString *)PublicKeyFromPem { return NSStringFromSelector(_cmd); }
+ (NSString *)PublicKeyFromCertificate { return NSStringFromSelector(_cmd); }

@end

@implementation JWTAlgorithmAsymmetricTestsHelper
- (NSDictionary <NSString *, void(^)(void)>*)configurations {
    __weak __auto_type weakSelf = self;
    return @{
             JWTAlgorithmNameRS256 : ^{
                 __auto_type accessor = [[JWTAlgorithmAsymmetricTestsHelperAssetAccessor alloc] initWithAlgorithName:self.name];
                 [weakSelf configuredByAssetAccessor:accessor];
             },
             JWTAlgorithmNameRS384 : ^{
                 __auto_type accessor = [[JWTAlgorithmAsymmetricTestsHelperAssetAccessor alloc] initWithAlgorithName:self.name];
                 [weakSelf configuredByAssetAccessor:accessor];
             },
             JWTAlgorithmNameRS512 : ^{
                 __auto_type accessor = [[JWTAlgorithmAsymmetricTestsHelperAssetAccessor alloc] initWithAlgorithName:self.name];
                 [weakSelf configuredByAssetAccessor:accessor];
             },
             JWTAlgorithmNameES256 : ^{
                 __auto_type accessor = [[JWTAlgorithmAsymmetricTestsHelperAssetAccessor alloc] initWithAlgorithName:self.name];
                 [weakSelf configuredByAssetAccessor:accessor];
                 weakSelf.cryptoKeyBuilderParameters = @{JWTCryptoKey.parametersKeyBuilder : JWTCryptoKeyBuilder.new.keyTypeEC };
             },
             JWTAlgorithmNameES384 : ^{
                 __auto_type accessor = [[JWTAlgorithmAsymmetricTestsHelperAssetAccessor alloc] initWithAlgorithName:self.name];
                 [weakSelf configuredByAssetAccessor:accessor];
                 weakSelf.cryptoKeyBuilderParameters = @{JWTCryptoKey.parametersKeyBuilder : JWTCryptoKeyBuilder.new.keyTypeEC };
             },
             JWTAlgorithmNameES512 : ^{
                 __auto_type accessor = [[JWTAlgorithmAsymmetricTestsHelperAssetAccessor alloc] initWithAlgorithName:self.name];
                 [weakSelf configuredByAssetAccessor:accessor];
                 weakSelf.cryptoKeyBuilderParameters = @{JWTCryptoKey.parametersKeyBuilder : JWTCryptoKeyBuilder.new.keyTypeEC };
             }
             };
}
- (void)generalConfigure {
    self.payloadDictionary = @{@"hello" : @"world"};
    self.headersDictionary = @{@"alg" : self.name, @"typ" : @"JWT"};
    self.fullDictionary = @{
                            JWTCodingResultComponents.headers : self.headersDictionary,
                            JWTCodingResultComponents.payload : self.payloadDictionary
                            };

//    self.payload = @"payload";
//    self.secret = @"secret";
//    self.wrongSecret = @"notTheSecret";
}
- (instancetype)configuredByName:(NSString *)name {
    __auto_type configured = [self configurations][name];
    if (configured) {
        self.name = name;
        [self generalConfigure];
        configured();
    }
    // choose configuration here?
    self.algorithm = [JWTAlgorithmFactory algorithmByName:name];
    return self;
}
- (instancetype)configuredByToken:(NSString *)token {
    if (token != nil) {
        self.token = token;
        self.invalidToken = [token stringByReplacingOccurrencesOfString:@"F" withString:@"D"];
    }
    return self;
}
- (instancetype)configuredByAssetAccessor:(JWTAlgorithmAsymmetricTestsHelperAssetAccessor *)accessor {
    if (accessor != nil) {
        self.accessor = accessor;
    }
    return self;
}
@end

@interface JWTAlgorithmAsymmetricTests : XCTestCase
@property (strong, nonatomic, readwrite) JWTAlgorithmAsymmetricTestsHelper *helper;
@end

@interface JWTAlgorithmAsymmetricTests (Check)
- (void)assertDecodedDictionary:(NSDictionary *)dictionary andHelper:(JWTAlgorithmAsymmetricTestsHelper *)helper;
- (void)assertToken:(NSString *)token andHelper:(JWTAlgorithmAsymmetricTestsHelper *)helper;
@end

@implementation JWTAlgorithmAsymmetricTests

- (void)showExternalRepresentation:(SecKeyRef)key name:(NSString *)name type:(NSString *)type {
    NSError *error = nil;
    __auto_type presentation = [JWTCryptoSecurity externalRepresentationForKey:key error:&error];
    __auto_type data = presentation;
    __auto_type string = [JWTBase64Coder base64UrlEncodedStringWithData:data];
    NSLog(@"name: %@ type: %@ presentation: %@", name, type, string);
}

- (NSDictionary *)extractedKeysIntoSecretWithHelper:(JWTAlgorithmAsymmetricTestsHelper *)helper {
    __auto_type tokens = [NSMutableDictionary dictionary];
    __auto_type holders = [NSMutableDictionary dictionary];

    {
        __auto_type key = JWTAlgorithmAsymmetricTests__ExtractionKeys.PrivateKeyFromP12;
                
        id<JWTAlgorithmDataHolderProtocol> holder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor privateKeyInP12].type).privateKeyCertificatePassphrase(helper.accessor.p12Password).algorithm(helper.algorithm).secretData(helper.accessor.p12Data);
        __auto_type builder = [JWTEncodingBuilder encodePayload:helper.payloadDictionary].addHolder(holder);

        __auto_type result = builder.result;
        if (result.successResult) {
            tokens[key] = result.successResult.encoded;
        }
    }

    {
        __auto_type key = JWTAlgorithmAsymmetricTests__ExtractionKeys.PublicKeyFromCertificate;
        __auto_type theKey = helper.accessor.certificateBase64;
        __auto_type secret = ((JWTCryptoSecurityComponent *)[[JWTCryptoSecurity componentsFromFileContent:theKey] componentsOfType:JWTCryptoSecurityComponents.Certificate].firstObject).content;
        id<JWTAlgorithmDataHolderProtocol> holder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor publicKeyWithCertificate].type).algorithm(helper.algorithm).secret(secret);
        if (holder) {
            holders[key] = holder;
        }
    }

    {
        // do we need certificate passphrase here?
        __auto_type key = JWTAlgorithmAsymmetricTests__ExtractionKeys.PrivateKeyFromPem;
        __auto_type theKey = helper.accessor.privateKeyBase64;
        __auto_type secret = ((JWTCryptoSecurityComponent *)[[JWTCryptoSecurity componentsFromFileContent:theKey] componentsOfType:JWTCryptoSecurityComponents.Key].firstObject).content;
        id<JWTAlgorithmDataHolderProtocol> holder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor privateKeyWithPEMBase64].type).algorithm(helper.algorithm).secret(secret);
        __auto_type builder = [JWTEncodingBuilder encodePayload:helper.payloadDictionary].addHolder(holder);
        __auto_type result = builder.result;
        if (result.successResult) {
            tokens[key] = result.successResult.encoded;
        }
    }

    {
        __auto_type key = JWTAlgorithmAsymmetricTests__ExtractionKeys.PublicKeyFromPem;
        __auto_type theKey = helper.accessor.publicKeyBase64;
        __auto_type secret = ((JWTCryptoSecurityComponent *)[[JWTCryptoSecurity componentsFromFileContent:theKey] componentsOfType:JWTCryptoSecurityComponents.Key].firstObject).content;
        id<JWTAlgorithmDataHolderProtocol> holder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor publicKeyWithPEMBase64].type).algorithm(helper.algorithm).secret(secret);
        if (holder) {
            holders[key] = holder;
        }
    }

    __auto_type result = @{
                           JWTAlgorithmAsymmetricTests__ExtractionKeys.Tokens : tokens,
                           JWTAlgorithmAsymmetricTests__ExtractionKeys.Holders : holders
               };

    return result;
}

- (NSDictionary *)extractedKeysIntoSignAndVerifyKeysWithHelper:(JWTAlgorithmAsymmetricTestsHelper *)helper {
    __auto_type tokens = [NSMutableDictionary dictionary];
    __auto_type holders = [NSMutableDictionary dictionary];

    // check name?
    __auto_type parameters = helper.cryptoKeyBuilderParameters;
    
    {
        __auto_type key = JWTAlgorithmAsymmetricTests__ExtractionKeys.PrivateKeyFromP12;

        __auto_type privateKey = ({
            NSError *error = nil;
            __auto_type result = [[JWTCryptoKeyPrivate alloc] initWithP12Data:helper.accessor.p12Data withPassphrase:helper.accessor.p12Password parameters:parameters error:&error];
            result;
        });
        [self showExternalRepresentation:privateKey.key name:helper.name type:key];
        
        id<JWTAlgorithmDataHolderProtocol> holder = [JWTAlgorithmRSFamilyDataHolder new].signKey(privateKey).algorithm(helper.algorithm);//.secretData([NSData data]);
        __auto_type builder = [JWTEncodingBuilder encodePayload:helper.payloadDictionary].addHolder(holder);
        
        __auto_type result = builder.result;
        if (result.successResult) {
            tokens[key] = result.successResult.encoded;
        }
    }
    
    {
        __auto_type key = JWTAlgorithmAsymmetricTests__ExtractionKeys.PublicKeyFromCertificate;
        __auto_type certificate = helper.accessor.certificateBase64;
        __auto_type secret = ((JWTCryptoSecurityComponent *)[[JWTCryptoSecurity componentsFromFileContent:certificate] componentsOfType:JWTCryptoSecurityComponents.Certificate].firstObject).content;
        __auto_type publicKey = ({
            NSError *error = nil;
            __auto_type result = [[JWTCryptoKeyPublic alloc] initWithCertificateBase64String:secret parameters:parameters error:&error];
            result;
        });
        [self showExternalRepresentation:publicKey.key name:helper.name type:key];

        id<JWTAlgorithmDataHolderProtocol> holder = [JWTAlgorithmRSFamilyDataHolder new].verifyKey(publicKey).algorithm(helper.algorithm).secretData([NSData data]);
        if (holder) {
            holders[key] = holder;
        }
    }
    
    {
        __auto_type key = JWTAlgorithmAsymmetricTests__ExtractionKeys.PrivateKeyFromPem;
        __auto_type theKey = helper.accessor.privateKeyBase64;
        __auto_type secret = ((JWTCryptoSecurityComponent *)[[JWTCryptoSecurity componentsFromFileContent:theKey] componentsOfType:JWTCryptoSecurityComponents.Key].firstObject).content;
        __auto_type privateKey = ({
            NSError *error = nil;
            __auto_type result = [[JWTCryptoKeyPrivate alloc] initWithBase64String:secret parameters:parameters error:&error];
            result;
        });
        id<JWTAlgorithmDataHolderProtocol> holder = [JWTAlgorithmRSFamilyDataHolder new].signKey(privateKey).algorithm(helper.algorithm).secretData([NSData data]);
        __auto_type builder = [JWTEncodingBuilder encodePayload:helper.payloadDictionary].addHolder(holder);
        __auto_type result = builder.result;
        if (result.successResult) {
            tokens[key] = result.successResult.encoded;
        }
    }

    {
        __auto_type key = JWTAlgorithmAsymmetricTests__ExtractionKeys.PublicKeyFromPem;
        __auto_type theKey = helper.accessor.publicKeyBase64;
        __auto_type secret = ((JWTCryptoSecurityComponent *)[[JWTCryptoSecurity componentsFromFileContent:theKey] componentsOfType:JWTCryptoSecurityComponents.Key].firstObject).content;
        __auto_type publicKey = ({
            NSError *error = nil;
            __auto_type result = [[JWTCryptoKeyPublic alloc] initWithBase64String:secret parameters:parameters error:&error];
            result;
        });
        id<JWTAlgorithmDataHolderProtocol> holder = [JWTAlgorithmRSFamilyDataHolder new].verifyKey(publicKey).algorithm(helper.algorithm).secretData([NSData data]);
        if (holder) {
            holders[key] = holder;
        }
    }
    
    
    __auto_type result = @{
                           JWTAlgorithmAsymmetricTests__ExtractionKeys.Tokens : tokens,
                           JWTAlgorithmAsymmetricTests__ExtractionKeys.Holders : holders
                           };
    return result;
}

/*API VERSION THREE*/
- (void)verifyKeysWithTokensAndHolders:(NSDictionary *)dictionary helper:(JWTAlgorithmAsymmetricTestsHelper *)helper {
    [self verifyKeysWithTokens:[dictionary objectForKey:JWTAlgorithmAsymmetricTests__ExtractionKeys.Tokens] holders:[dictionary objectForKey:JWTAlgorithmAsymmetricTests__ExtractionKeys.Holders] helper:helper];
}

- (void)verifyKeysWithTokens:(NSDictionary *)tokens holders:(NSDictionary *)holders helper:(JWTAlgorithmAsymmetricTestsHelper *)helper {
    for (NSString *holderKey in holders) {
        __auto_type holder = (id <JWTAlgorithmDataHolderProtocol>)[holders objectForKey:holderKey];
        for (NSString *tokenKey in tokens) {
            // we must
            __auto_type token = (NSString *)[tokens objectForKey:tokenKey];
            __auto_type builder = [JWTDecodingBuilder decodeMessage:token].addHolder(holder);
            __auto_type result = builder.result;
            if (result.successResult) {
                NSLog(@"Pair: <%@> decodeBy <%@> passed", tokenKey, holderKey);
                [self assertDecodedDictionary:result.successResult.headerAndPayloadDictionary andHelper:helper];
            }
            else {
                NSLog(@"Pair: <%@> decodeBy <%@> failed. Error: %@", tokenKey, holderKey, result.errorResult.error);
                [self assertDecodedDictionary:nil andHelper:helper];
            }
        }
    }
}

/*API VERSION THREE*/
- (void)testExtractingKeysFromDifferentContainers {
    [XCTContext runActivityNamed:@"Extracting keys into secret and secretData" block:^(id<XCTActivity>  _Nonnull activity) {
        __auto_type algorithmNames = @[
                                       JWTAlgorithmNameRS256,
                                       JWTAlgorithmNameRS384,
                                       JWTAlgorithmNameRS512,
                                       JWTAlgorithmNameES256,
                                       JWTAlgorithmNameES384,
                                       JWTAlgorithmNameES512
                                       ];
        for (NSString *name in algorithmNames) {
            __auto_type helper = [[JWTAlgorithmAsymmetricTestsHelper new] configuredByName:name];
            if (helper.algorithm == nil) {
                continue;
            }
            __auto_type dictionary = [self extractedKeysIntoSecretWithHelper:helper];
            [self verifyKeysWithTokensAndHolders:dictionary helper:helper];
        }
    }];
    
    [XCTContext runActivityNamed:@"Extracting keys into verify and sign keys" block:^(id<XCTActivity>  _Nonnull activity) {
        __auto_type algorithmsNames = @[
                                   JWTAlgorithmNameES256,
                                   JWTAlgorithmNameES384,
                                   JWTAlgorithmNameES512
                                   ];
        for (NSString *name in algorithmsNames) {
            __auto_type helper = [[JWTAlgorithmAsymmetricTestsHelper new] configuredByName:name];
            if (helper.algorithm == nil) {
                continue;
            }
            __auto_type dictionary = [self extractedKeysIntoSignAndVerifyKeysWithHelper:helper];
            [self verifyKeysWithTokensAndHolders:dictionary helper:helper];
        }
    }];
}

/*API VERSION TWO*/
// For RS part only.
- (void)testEncoding {

}

- (void)testDecoding {

}

@end

@implementation JWTAlgorithmAsymmetricTests (Check)
- (void)assertDecodedDictionary:(NSDictionary *)dictionary andHelper:(JWTAlgorithmAsymmetricTestsHelper *)helper {
    XCTAssertEqualObjects(dictionary, helper.fullDictionary);
}
- (void)assertToken:(NSString *)token andHelper:(JWTAlgorithmAsymmetricTestsHelper *)helper {
    // configure token?!
    XCTAssertEqualObjects(token, helper.token);
    // decode it?
    // or not?
    // later.. :3
}
@end
