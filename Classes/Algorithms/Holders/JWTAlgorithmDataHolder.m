//
//  JWTAlgorithmDataHolder.m
//  JWT
//
//  Created by Lobanov Dmitry on 31.08.16.
//  Copyright © 2016 Karma. All rights reserved.
//

#import "JWTAlgorithmDataHolder.h"
#import "JWTAlgorithmFactory.h"
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

@implementation JWTAlgorithmBaseDataHolder
#pragma mark - Convertions
- (NSData *)dataFromString:(NSString *)string {
    NSData *result = [[NSData alloc] initWithBase64EncodedString:string options:0];
    
    if (result == nil) {
       // tell about it?!
        NSLog(@"%@ %@ something went wrong. Data is not base64encoded", self.debugDescription, NSStringFromSelector(_cmd));
    }
    
    return result ?: [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)stringFromData:(NSData *)data {
    NSString *result = [data base64EncodedStringWithOptions:0];
    
    if (result == nil) {
        NSLog(@"%@ %@ something went wrong. String is not base64encoded", self.debugDescription, NSStringFromSelector(_cmd));
    }
    return result ?: [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

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
    return self;
}

@end

@interface JWTAlgorithmRSFamilyDataHolder()
#pragma mark - Getters
@property (copy, nonatomic, readwrite) NSString *currentPrivateKeyCertificatePassphrase;

#pragma mark - Setters
@property (copy, nonatomic, readwrite) JWTAlgorithmRSFamilyDataHolder *(^privateKeyCertificatePassphrase)(NSString *privateKeyCertificatePassphrase);
@end

@implementation JWTAlgorithmRSFamilyDataHolder
- (instancetype)privateKeyCertificatePassphrase:(NSString *)passphrase {
    self.currentPrivateKeyCertificatePassphrase = passphrase;
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        self.privateKeyCertificatePassphrase = ^(NSString *privateKeyCertificatePassphrase) {
            return [weakSelf privateKeyCertificatePassphrase:privateKeyCertificatePassphrase];
        };
    }
    return self;
}

@end

// Public
@protocol JWTResultTypeSuccessEncodedProtocol <NSObject>
@property (copy, nonatomic, readonly) NSString *encoded;
- (instancetype)initWithEncoded:(NSString *)encoded;
@end

// Protected?
@protocol JWTMutableResultTypeSuccessEncodedProtocol <JWTResultTypeSuccessEncodedProtocol>
@property (copy, nonatomic, readwrite) NSString *encoded;
@end

// Public
@protocol JWTResultTypeSuccessDecodedProtocol <NSObject>
@property (copy, nonatomic, readonly) NSDictionary *headers;
@property (copy, nonatomic, readonly) NSDictionary *payload;
- (instancetype)initWithHeaders:(NSDictionary *)headers withPayload:(NSDictionary *)payload;
@end

// Protected?
@protocol JWTMutableResultTypeSuccessDecodedProtocol <JWTResultTypeSuccessDecodedProtocol>
@property (copy, nonatomic, readwrite) NSDictionary *headers;
@property (copy, nonatomic, readwrite) NSDictionary *payload;
@end

// Public
@interface JWTResultTypeSuccess : NSObject @end
@interface JWTResultTypeSuccess(JWTResultTypeSuccessEncodedProtocol)<JWTResultTypeSuccessEncodedProtocol>
@end
@interface JWTResultTypeSuccess(JWTResultTypeSuccessDecodedProtocol)<JWTResultTypeSuccessDecodedProtocol>
@end

// Public
@protocol JWTResultTypeErrorProtocol <NSObject>
@property (copy, nonatomic, readonly) NSError *error;
- (instancetype)initWithError:(NSError *)error;
@end

// Protected?
@protocol JWTMutableResultTypeErrorProtocol <JWTResultTypeErrorProtocol>
@property (copy, nonatomic, readwrite) NSError *error;
@end

@interface JWTResultTypeError : NSObject @end
@interface JWTResultTypeError (JWTResultTypeErrorProtocol) <JWTResultTypeErrorProtocol> @end

@interface JWTResultType : NSObject
- (instancetype)initWithSuccess:(JWTResultTypeSuccess *)success withError:(NSError *)error;
@property (strong, nonatomic, readonly) JWTResultTypeSuccess *successType;
@property (strong, nonatomic, readonly) JWTResultTypeError *errorType;
@end

@implementation JWTResultTypeSuccess @end
@implementation JWTResultTypeSuccess(JWTResultTypeSuccessEncodedProtocol) @end
@implementation JWTResultTypeSuccess(JWTResultTypeSuccessDecodedProtocol) @end
@implementation JWTResultTypeError @end
@implementation JWTResultTypeError (JWTResultTypeErrorProtocol) @end
@implementation JWTResultType @end
/*
                ResultType
                   /\
                  /  \
                 /    \
             Success  Error
 
            Protocols: Mutable and Immutable
 

 @protocol JWTResultTypeSuccessEncodedProtocol <NSObject>
 @property (copy, nonatomic, readonly) NSString *encoded;
 - (instancetype)initWithEncoded:(NSString *)encoded;
 @end
 
 @protocol JWTResultTypeSuccessDecodedProtocol <NSObject>
 @property (copy, nonatomic, readonly) NSDictionary *headers;
 @property (copy, nonatomic, readonly) NSDictionary *payload;
 - (instancetype)initWithHeaders:(NSDictionary *)headers withPayload:(NSDictionary *)payload;
 @end
 
 @protocol JWTMutableResultTypeSuccessEncodedProtocol <JWTResultTypeSuccessEncodedProtocol>
 @property (copy, nonatomic, readwrite) NSString *encoded;
 @end
 
 @protocol JWTResultTypeSuccessDecodedProtocol <JWTResultTypeSuccessDecodedProtocol>
 @property (copy, nonatomic, readwrite) NSDictionary *headers;
 @property (copy, nonatomic, readwrite) NSDictionary *payload;
 @end

 
 
 @interface JWTResultTypeSuccess : <JWTMutableResultTypeSuccessEncodedProtocol, JWTMutableResultTypeSuccessDecodedProtocol> @end
 
 @protocol JWTResultTypeErrorProtocol <NSObject>
 @property (copy, nonatomic, readonly) NSError *error;
 - (instancetype)initWithError:(NSError *)error;
 @end
 
 @protocol JWTMutableResultTypeErrorProtocol <JWTResultTypeErrorProtocol>
 @property (copy, nonatomic, readwrite) NSError *error;
 @end
 
 @interface JWTResultTypeError <JWTMutableResultTypeError> @end

 @interface JWTResultType : NSObject
 - (instancetype)initWithSuccess:(JWTResultTypeSuccess *)success withError:(NSError *)error;
 @property (strong, nonatomic, readonly) id<JWTSuccessType> success;
 @property (strong, nonatomic, readonly) id<JWTErrorType> error;
 @end

@implementation JWTResultType
- (instancetype)initWithSuccess:(JWTSuccessType *)success withError:(NSError *)error {
    if (self = [super init]) {
        self.success = success;
        self.error = [[JWTErrorType alloc] initWithError:error];
    }
    return self;
}
- (void)example {
    JWTResultType *result = nil;
    if (result.error.error) {
        
    }
    else {
        if (result.success.encoded) {
            
        }
        else if (result.success.headers) {
            
        }
    }
}
@end
*/
