//
//  JWTAlgorithmDataHolder.m
//  JWT
//
//  Created by Lobanov Dmitry on 31.08.16.
//  Copyright © 2016 Karma. All rights reserved.
//

#import "JWTAlgorithmDataHolder.h"
#import "JWTAlgorithmFactory.h"
#import "JWTAlgorithmNone.h"
#import "JWTRSAlgorithm.h"
#import "JWTAlgorithmHSBase.h"
#import "JWTAlgorithmRSBase.h"
#import "JWTBase64Coder.h"

@interface JWTAlgorithmBaseDataHolder()
// not needed by algorithm adoption.
// @property (copy, nonatomic, readwrite) NSData *currentSecretData;
// @property (strong, nonatomic, readwrite) id <JWTAlgorithm> currentAlgorithm;

#pragma mark - Setters
/**
 Sets jwtSecret and returns the JWTAlgorithmBaseDataHolder to allow for method chaining
 */
@property (copy, nonatomic, readwrite) JWTAlgorithmBaseDataHolder *(^secret)(NSString *secret);

/**
 Sets jwtSecretData and returns the JWTAlgorithmBaseDataHolder to allow for method chaining
 */
@property (copy, nonatomic, readwrite) JWTAlgorithmBaseDataHolder *(^secretData)(NSData *secretData);

/**
 Sets jwtAlgorithm and returns the JWTAlgorithmBaseDataHolder to allow for method chaining
 */
@property (copy, nonatomic, readwrite) JWTAlgorithmBaseDataHolder *(^algorithm)(id<JWTAlgorithm>algorithm);

/**
 Sets jwtAlgorithmName and returns the JWTAlgorithmBaseDataHolder to allow for method chaining. See list of names in appropriate headers.
 */
@property (copy, nonatomic, readwrite) JWTAlgorithmBaseDataHolder *(^algorithmName)(NSString *algorithmName);

@end

@interface JWTAlgorithmBaseDataHolder (Convertions)

- (NSData *)dataFromString:(NSString *)string;
- (NSString *)stringFromData:(NSData *)data;

@end

@implementation JWTAlgorithmBaseDataHolder (Convertions)
#pragma mark - Convertions
- (NSData *)dataFromString:(NSString *)string {
    NSData *result = [JWTBase64Coder dataWithBase64UrlEncodedString:string];
    
    if (result == nil) {
        // tell about it?!
        NSLog(@"%@ %@ something went wrong. Data is not base64encoded", self.debugDescription, NSStringFromSelector(_cmd));
    }
    
    return result ?: [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)stringFromData:(NSData *)data {
    NSString *result = [JWTBase64Coder base64UrlEncodedStringWithData:data];
    
    if (result == nil) {
        NSLog(@"%@ %@ something went wrong. String is not base64encoded", self.debugDescription, NSStringFromSelector(_cmd));
    }
    return result ?: [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end

@interface JWTAlgorithmBaseDataHolder (Fluent)
- (void)setupFluent;
@end

@implementation JWTAlgorithmBaseDataHolder (Fluent)
#pragma mark - Fluent
- (instancetype)secretData:(NSData *)secretData {
    self.currentSecretData = secretData;
    return self;
}

- (instancetype)secret:(NSString *)secret {
    self.currentSecretData = [self dataFromString:secret];
    return self;
}

- (instancetype)algorithm:(id<JWTAlgorithm>)algorithm {
    self.currentAlgorithm = algorithm;
    return self;
}

- (instancetype)algorithmName:(NSString *)algorithmName {
    self.currentAlgorithm = [JWTAlgorithmFactory algorithmByName:algorithmName];
    return self;
}

- (void)setupFluent {
    __weak typeof(self) weakSelf = self;
    self.secret = ^(NSString *secret) {
        return [weakSelf secret:secret];
    };
    
    self.secretData = ^(NSData *secretData) {
        return [weakSelf secretData:secretData];
    };
    
    self.algorithm = ^(id<JWTAlgorithm> algorithm) {
        return [weakSelf algorithm:algorithm];
    };
    
    self.algorithmName = ^(NSString *algorithmName) {
        return [weakSelf algorithmName:algorithmName];
    };
}
@end

@implementation JWTAlgorithmBaseDataHolder
@synthesize currentAlgorithm;
@synthesize currentSecretData;

#pragma mark - Custom Getters
- (NSString *)currentAlgorithmName {
    return [self.algorithm name];
}

- (NSString *)currentSecret {
    return [self stringFromData:self.currentSecretData];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupFluent];
    }
    return self;
}

@end

@interface JWTAlgorithmBaseDataHolder(Create)
- (instancetype)initWithAlgorithmName:(NSString *)name;
@end

@implementation JWTAlgorithmBaseDataHolder(Create)
- (instancetype)initWithAlgorithmName:(NSString *)name {
    return [self init].algorithmName(name);
}
@end

@implementation JWTAlgorithmNoneDataHolder
- (instancetype)init {
    if (self = [super init]) {
        self.currentAlgorithm = [JWTAlgorithmFactory algorithmByName:JWTAlgorithmNameNone];
        self.currentSecretData = nil;
    }
    return self;
}
@end

@implementation JWTAlgorithmHSFamilyDataHolder
+ (instancetype)createWithAlgorithm256 {
    return [[self alloc] initWithAlgorithmName:JWTAlgorithmNameHS256];
}
+ (instancetype)createWithAlgorithm384 {
    return [[self alloc] initWithAlgorithmName:JWTAlgorithmNameHS384];
}
+ (instancetype)createWithAlgorithm512 {
    return [[self alloc] initWithAlgorithmName:JWTAlgorithmNameHS512];
}
@end

@interface JWTAlgorithmRSFamilyDataHolder()
#pragma mark - Getters
@property (copy, nonatomic, readwrite) NSString *currentPrivateKeyCertificatePassphrase;

#pragma mark - Setters
@property (copy, nonatomic, readwrite) JWTAlgorithmRSFamilyDataHolder *(^privateKeyCertificatePassphrase)(NSString *privateKeyCertificatePassphrase);
@end

@implementation JWTAlgorithmRSFamilyDataHolder

#pragma mark - Initialization
+ (instancetype)createWithAlgorithm256 {
    return [[self alloc] initWithAlgorithmName:JWTAlgorithmNameRS256];
}

+ (instancetype)createWithAlgorithm384 {
    return [[self alloc] initWithAlgorithmName:JWTAlgorithmNameRS384];
}

+ (instancetype)createWithAlgorithm512 {
    return [[self alloc] initWithAlgorithmName:JWTAlgorithmNameRS512];
}

#pragma mark - Getters
- (id<JWTAlgorithm>)currentAlgorithm {
    id <JWTAlgorithm> algorithm = [super currentAlgorithm];
    if ([algorithm conformsToProtocol:@protocol(JWTRSAlgorithm)]) {
        ((id <JWTRSAlgorithm>)algorithm).privateKeyCertificatePassphrase = self.currentPrivateKeyCertificatePassphrase;
    }
    return algorithm;
}

#pragma mark - Setters
- (instancetype)privateKeyCertificatePassphrase:(NSString *)passphrase {
    self.currentPrivateKeyCertificatePassphrase = passphrase;
    return self;
}
@end

@implementation JWTAlgorithmRSFamilyDataHolder (Fluent)
- (void)setupFluent {
    [super setupFluent];
    __weak typeof(self) weakSelf = self;
    self.privateKeyCertificatePassphrase = ^(NSString *privateKeyCertificatePassphrase) {
        return [weakSelf privateKeyCertificatePassphrase:privateKeyCertificatePassphrase];
    };
}
@end
