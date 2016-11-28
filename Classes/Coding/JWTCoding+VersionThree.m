//
//  JWTCoding+VersionThree.m
//  JWT
//
//  Created by Lobanov Dmitry on 27.11.16.
//  Copyright © 2016 JWTIO. All rights reserved.
//

#import "JWTCoding+VersionThree.h"
#import "JWTAlgorithmDataHolderChain.h"

@implementation JWT (VersionThree)
+ (JWTEncodingBuilder *)encodeWithAlgorithmsAndData:(NSArray *)items {
    return [JWTEncodingBuilder createWithAlgorithmsAndData:items];
}
+ (JWTEncodingBuilder *)encodeWithAlgorithmsAndDataChain:(JWTAlgorithmDataHolderChain *)chain {
    return [JWTEncodingBuilder createWithAlgorithmsAndDataChain:chain];
}
+ (JWTDecodingBuilder *)decodeWithAlgorithmsAndData:(NSArray *)items {
    return [JWTDecodingBuilder createWithAlgorithmsAndData:items];
}
+ (JWTDecodingBuilder *)decodeWithAlgorithmsAndDataChain:(JWTAlgorithmDataHolderChain *)chain {
    return [JWTDecodingBuilder createWithAlgorithmsAndDataChain:chain];
}
@end

@interface JWTCodingBuilder ()
#pragma mark - Internal
@property (strong, nonatomic, readwrite) JWTAlgorithmDataHolderChain *internalAlgorithmsAndDataChain;
@property (copy, nonatomic, readwrite) NSNumber *internalOptions;

#pragma mark - Fluent
@property (copy, nonatomic, readwrite) JWTCodingBuilder *(^constructChain)(JWTAlgorithmDataHolderChain *(^block)());
@property (copy, nonatomic, readwrite) JWTCodingBuilder *(^chain)(JWTAlgorithmDataHolderChain *chain);
@property (copy, nonatomic, readwrite) JWTCodingBuilder *(^options)(NSNumber *options);
@end
@interface JWTCodingBuilder (Fluent_Setup)
- (instancetype)algorithmsAndDataChain:(JWTAlgorithmDataHolderChain *)chain;
- (instancetype)options:(NSNumber *)options;
- (void)setupFluent;
@end

@implementation JWTCodingBuilder (Fluent_Setup)
- (instancetype)algorithmsAndDataChain:(JWTAlgorithmDataHolderChain *)chain {
    self.internalAlgorithmsAndDataChain = chain;
    return self;
}
- (instancetype)options:(NSNumber *)options {
    self.internalOptions = options;
    return self;
}
- (void)setupFluent {
    __weak typeof(self) weakSelf = self;
    self.chain = ^(JWTAlgorithmDataHolderChain *chain) {
        return [weakSelf algorithmsAndDataChain:chain];
    };
    
    self.constructChain = ^(JWTAlgorithmDataHolderChain *(^block)()) {
        if (block) {
            JWTAlgorithmDataHolderChain *chain = block();
            return [weakSelf algorithmsAndDataChain:chain];
        }
        return weakSelf;
    };
    self.options = ^(NSNumber *options) {
        return [weakSelf options:options];
    };
}
@end

@implementation JWTCodingBuilder
#pragma mark - Create
- (instancetype)initWithAlgorithmsAndDataChain:(JWTAlgorithmDataHolderChain *)chain {
    if (self = [super init]) {
        self.internalAlgorithmsAndDataChain = chain;
        [self setupFluent];
    }
    return self;
}
+ (instancetype)createWithAlgorithmsAndData:(NSArray *)items {
    return [self createWithAlgorithmsAndDataChain:[[JWTAlgorithmDataHolderChain alloc] initWithHolders:items]];
}
+ (instancetype)createWithAlgorithmsAndDataChain:(JWTAlgorithmDataHolderChain *)chain {
    return [[self alloc] initWithAlgorithmsAndDataChain:chain];
}
@end

@implementation JWTCodingBuilder (Sugar)
- (instancetype)and {
    return self;
}
- (instancetype)with {
    return self;
}
@end

@interface JWTEncodingBuilder ()
#pragma mark - Internal
@property (strong, nonatomic, readwrite) NSDictionary *internalPayload;
@property (strong, nonatomic, readwrite) NSDictionary *internalHeaders;
@property (strong, nonatomic, readwrite) JWTClaimsSet *internalClaimsSet;

#pragma mark - Fluent
@property (copy, nonatomic, readwrite) JWTEncodingBuilder *(^payload)(NSDictionary *payload);
@property (copy, nonatomic, readwrite) JWTEncodingBuilder *(^headers)(NSDictionary *headers);
@property (copy, nonatomic, readwrite) JWTEncodingBuilder *(^claimsSet)(JWTClaimsSet *claimsSet);
@end

@interface JWTEncodingBuilder (Fluent_Setup)
- (instancetype)payload:(NSDictionary *)payload;
- (instancetype)headers:(NSDictionary *)headers;
- (instancetype)claimsSet:(JWTClaimsSet *)claimsSet;
@end

@implementation JWTEncodingBuilder (Fluent_Setup)

- (instancetype)payload:(NSDictionary *)payload {
    self.internalPayload = payload;
    return self;
}
- (instancetype)headers:(NSDictionary *)headers {
    self.internalHeaders = headers;
    return self;
}

- (instancetype)claimsSet:(JWTClaimsSet *)claimsSet {
    self.internalClaimsSet = claimsSet;
    return self;
}

- (void)setupFluent {
    [super setupFluent];
    __weak typeof(self) weakSelf = self;
    self.payload = ^(NSDictionary *payload) {
        return [weakSelf payload:payload];
    };
    self.headers = ^(NSDictionary *headers) {
        return [weakSelf headers:headers];
    };
    self.claimsSet = ^(JWTClaimsSet *claimsSet) {
        return [weakSelf claimsSet:claimsSet];
    };
}

@end

@implementation JWTEncodingBuilder
+ (instancetype)encodePayload:(NSDictionary *)payload {
    return ((JWTEncodingBuilder *)[self createWithAlgorithmsAndDataChain:nil]).payload(payload);
}
+ (instancetype)encodeClaimsSet:(JWTClaimsSet *)claimsSet {
    return ((JWTEncodingBuilder *)[self createWithAlgorithmsAndDataChain:nil]).claimsSet(claimsSet);
}
@end

@implementation JWTEncodingBuilder (Coding)
- (JWTCodingResultType *)encode {
    // do it!
    return nil;
}
- (JWTCodingResultType *)result {
    return self.encode;
}
@end

@interface JWTDecodingBuilder ()
#pragma mark - Internal
@property (copy, nonatomic, readwrite) NSString *internalMessage;

#pragma mark - Fluent
@property (copy, nonatomic, readwrite) JWTDecodingBuilder *(^message)(NSString *message);
@end

@interface JWTDecodingBuilder (Fluent_Setup)
- (instancetype)message:(NSString *)message;
@end
@implementation JWTDecodingBuilder (Fluent_Setup)
- (instancetype)message:(NSString *)message {
    self.internalMessage = message;
    return self;
}
- (void)setupFluent {
    [super setupFluent];
    __weak typeof(self) weakSelf = self;
    self.message = ^(NSString *message) {
        return [weakSelf message:message];
    };
}
@end

@implementation JWTDecodingBuilder
#pragma mark - Create
+ (instancetype)decodeMessage:(NSString *)message {
    return ((JWTDecodingBuilder *)[self createWithAlgorithmsAndDataChain:nil]).message(message);
}
@end

@implementation JWTDecodingBuilder (Coding)
- (JWTCodingResultType *)decode {
    // do!
    // iterate over items in chain!
    // and return if everything ok!
    // or return error!
    return nil;
}

- (JWTCodingResultType *)result {
    return self.decode;
}
@end

@implementation JWT (VersionThreeExamples)
+ (void)example {
    NSString *message = nil;
    JWTCodingResultType *result = [JWTDecodingBuilder decodeMessage:message].chain(
[JWTAlgorithmDataHolderChain chainWithHolders:@[[JWTAlgorithmBaseDataHolder new].algorithm(nil).secretData(nil),[JWTAlgorithmBaseDataHolder new].algorithm(nil).secretData(nil)]]).and.result;
    
    if (result.successType) {
        NSDictionary *payload = result.successType.payload;
    }
    else if (result.errorType) {
        NSError *error = result.errorType.error;
    }
}
@end
