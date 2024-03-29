//
//  JWTCoding+VersionThree.m
//  JWT
//
//  Created by Lobanov Dmitry on 27.11.16.
//  Copyright © 2016 JWTIO. All rights reserved.
//

#import "JWTCoding+VersionThree.h"
#import "JWTAlgorithmDataHolderChain.h"
#import "JWTRSAlgorithm.h"
#import "JWTCoding+ResultTypes.h"
#import "JWTAlgorithmFactory.h"
#import "JWTErrorDescription.h"
#import "JWTBase64Coder.h"
#import "JWTClaimsSetsProtocols.h"
#import "JWTClaimsSetDSLBase.h"

#import "JWTAlgorithmDataHolder+FluentStyle.h"
#import "JWTCodingBuilder+FluentStyle.h"

static inline void setError(NSError **error, NSError* value) {
    if (error) {
        *error = value;
    }
}

@implementation JWT (VersionThree)
+ (JWTEncodingBuilder *)encodeWithHolders:(NSArray *)holders {
    return [JWTEncodingBuilder createWithHolders:holders];
}
+ (JWTEncodingBuilder *)encodeWithChain:(JWTAlgorithmDataHolderChain *)chain {
    return [JWTEncodingBuilder createWithChain:chain];
}
+ (JWTDecodingBuilder *)decodeWithHolders:(NSArray *)holders {
    return [JWTDecodingBuilder createWithHolders:holders];
}
+ (JWTDecodingBuilder *)decodeWithChain:(JWTAlgorithmDataHolderChain *)chain {
    return [JWTDecodingBuilder createWithChain:chain];
}
@end

@interface JWTCodingBuilder ()
#pragma mark - Internal
@property (strong, nonatomic, readwrite) JWTAlgorithmDataHolderChain *internalChain;
@property (copy, nonatomic, readwrite) NSNumber *internalOptions;
@property (strong, nonatomic, readwrite) id <JWTStringCoderProtocol> internalTokenCoder;
@property (strong, nonatomic, readwrite) id <JWTStringCoderProtocol> internalHashCoder;

#pragma mark - Fluent
@property (copy, nonatomic, readwrite) JWTCodingBuilder *(^chain)(JWTAlgorithmDataHolderChain *chain);
@property (copy, nonatomic, readwrite) JWTCodingBuilder *(^constructChain)(JWTAlgorithmDataHolderChain *(^block)(void));
@property (copy, nonatomic, readwrite) JWTCodingBuilder *(^modifyChain)(JWTAlgorithmDataHolderChain *(^block)(JWTAlgorithmDataHolderChain * chain));
@property (copy, nonatomic, readwrite) JWTCodingBuilder *(^options)(NSNumber *options);
@property (copy, nonatomic, readwrite) JWTCodingBuilder *(^addHolder)(id<JWTAlgorithmDataHolderProtocol> holder);
@property (copy, nonatomic, readwrite) JWTCodingBuilder *(^constructHolder)(id<JWTAlgorithmDataHolderProtocol>(^block)(id<JWTAlgorithmDataHolderProtocol> holder));
@property (copy, nonatomic, readwrite) JWTCodingBuilder *(^tokenCoder)(id<JWTStringCoderProtocol> tokenCoder);

@end

@interface JWTCodingBuilder (Fluent_Setup)
- (void)setupFluent;
@end

@implementation JWTCodingBuilder (Fluent_Setup)
- (instancetype)chain:(JWTAlgorithmDataHolderChain *)chain {
    self.internalChain = chain;
    return self;
}
- (instancetype)options:(NSNumber *)options {
    self.internalOptions = options;
    return self;
}
- (instancetype)addHolder:(id<JWTAlgorithmDataHolderProtocol>)holder {
    self.internalChain = [self.internalChain chainByAppendingHolder:holder];
    return self;
}
- (instancetype)tokenCoder:(id<JWTStringCoderProtocol>)tokenCoder {
    self.internalTokenCoder = tokenCoder;
    return self;
}
- (void)setupFluent {
    __weak typeof(self) weakSelf = self;
    self.chain = ^(JWTAlgorithmDataHolderChain *chain) {
        return [weakSelf chain:chain];
    };
    
    self.constructChain = ^(JWTAlgorithmDataHolderChain *(^block)(void)) {
        if (block) {
            JWTAlgorithmDataHolderChain *chain = block();
            return [weakSelf chain:chain];
        }
        return weakSelf;
    };
    
    self.modifyChain = ^(JWTAlgorithmDataHolderChain *(^block)(JWTAlgorithmDataHolderChain *chain)) {
        if (block) {
            JWTAlgorithmDataHolderChain *chain = block(weakSelf.internalChain);
            return [weakSelf chain:chain];
        }
        return weakSelf;
    };


    self.options = ^(NSNumber *options) {
        return [weakSelf options:options];
    };
    
    self.addHolder = ^(id<JWTAlgorithmDataHolderProtocol> holder) {
        return [weakSelf addHolder:holder];
    };
    
    self.constructHolder = ^(id<JWTAlgorithmDataHolderProtocol> (^block)(id<JWTAlgorithmDataHolderProtocol> holder)) {
        if (block) {
            [weakSelf addHolder:block([JWTAlgorithmBaseDataHolder new])];
        }
        return weakSelf;
    };
    
    self.tokenCoder = ^(id<JWTStringCoderProtocol> tokenCoder) {
        return [weakSelf tokenCoder:tokenCoder];
    };
}
@end

@implementation JWTCodingBuilder
#pragma mark - Getters
// Chain always exists
- (JWTAlgorithmDataHolderChain *)internalChain {
    return _internalChain ?: (_internalChain = [JWTAlgorithmDataHolderChain new]);
}
#pragma mark - Create
- (instancetype)initWithChain:(JWTAlgorithmDataHolderChain *)chain {
    if (self = [super init]) {
        self.internalChain = chain;
        self.internalTokenCoder = [JWTBase64Coder withBase64String];
        self.internalHashCoder = [JWTStringCoderForEncoding utf8Encoding];
        [self setupFluent];
    }
    return self;
}
+ (instancetype)createWithHolders:(NSArray *)items {
    return [self createWithChain:[[JWTAlgorithmDataHolderChain alloc] initWithHolders:items]];
}
+ (instancetype)createWithChain:(JWTAlgorithmDataHolderChain *)chain {
    return [[self alloc] initWithChain:chain];
}
+ (instancetype)createWithEmptyChain {
    return [self createWithChain:nil];
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
@property (copy, nonatomic, readwrite) NSDictionary *internalPayload;
@property (copy, nonatomic, readwrite) NSDictionary *internalHeaders;
@property (strong, nonatomic, readwrite) id<JWTClaimsSetCoordinatorProtocol> internalClaimsSetCoordinator;
@property (copy, nonatomic, readwrite) NSDictionary *internalMixingClaimsPayload;

#pragma mark - Fluent
@property (copy, nonatomic, readwrite) JWTEncodingBuilder *(^payload)(NSDictionary *payload);
@property (copy, nonatomic, readwrite) JWTEncodingBuilder *(^headers)(NSDictionary *headers);
@property (copy, nonatomic, readwrite) JWTEncodingBuilder *(^claimsSetCoordinator)(id<JWTClaimsSetCoordinatorProtocol> claimsSetCoordinator);
@end

@implementation JWTEncodingBuilder (Setters)
- (instancetype)payload:(NSDictionary *)payload {
    self.internalPayload = payload;
    return self;
}
- (instancetype)headers:(NSDictionary *)headers {
    self.internalHeaders = headers;
    return self;
}
- (instancetype)claimsSetCoordinator:(id<JWTClaimsSetCoordinatorProtocol>)claimsSetCoordinator {
    self.internalClaimsSetCoordinator = claimsSetCoordinator;
    return self;
}
@end

@implementation JWTEncodingBuilder (Fluent_Setup)
- (void)setupFluent {
    [super setupFluent];
    __weak typeof(self) weakSelf = self;
    self.payload = ^(NSDictionary *payload) {
        return [weakSelf payload:payload];
    };
    self.headers = ^(NSDictionary *headers) {
        return [weakSelf headers:headers];
    };
    self.claimsSetCoordinator = ^(id<JWTClaimsSetCoordinatorProtocol> claimsSetCoordinator) {
        return [weakSelf claimsSetCoordinator:claimsSetCoordinator];
    };
}
@end

@implementation JWTEncodingBuilder
#pragma mark - Getters
- (NSDictionary *)internalMixingClaimsPayload {
    NSMutableDictionary *dictionary = [@{} mutableCopy];
    if (_internalPayload) {
        [dictionary addEntriesFromDictionary:_internalPayload];
    }
    
    if (_internalClaimsSetCoordinator) {
        __auto_type claimsDictionary = [_internalClaimsSetCoordinator.claimsSetSerializer dictionaryFromClaimsSet:_internalClaimsSetCoordinator.claimsSetStorage];
        [dictionary addEntriesFromDictionary:claimsDictionary];
    }
    
    return dictionary;
}

#pragma mark - Create
+ (instancetype)encodePayload:(NSDictionary *)payload {
    return ((JWTEncodingBuilder *)[self createWithEmptyChain]).payload(payload);
}
+ (instancetype)encodeClaimsSetWithCoordinator:(id<JWTClaimsSetCoordinatorProtocol>)coordinator {
    return ((JWTEncodingBuilder *)[self createWithEmptyChain]).claimsSetCoordinator(coordinator);
}
@end

@implementation JWTEncodingBuilder (Coding)
- (JWTCodingResultType *)encode {
    
    NSDictionary *headers = self.internalHeaders;
    NSDictionary *payload = self.internalMixingClaimsPayload;
    
    NSString *encodedMessage = nil;
    NSError *error = nil;
    
    NSArray *holders = self.internalChain.holders;
    // ERROR: HOLDERS ARE EMPTY.
    if (holders.count == 0) {
        error = [JWTErrorDescription errorWithCode:JWTDecodingHoldersChainEmptyError];
    }
    
    for (id <JWTAlgorithmDataHolderProtocol>holder in holders) {
        id <JWTAlgorithm>algorithm = holder.internalAlgorithm;
        NSData *secretData = holder.internalSecretData;
        
        // BUG:
        // Read about it in
//        if ([holder isKindOfClass:JWTAlgorithmRSFamilyDataHolder.class]) {
//            JWTAlgorithmRSFamilyDataHolder *theHolder = (JWTAlgorithmRSFamilyDataHolder *)holder;
//            BOOL bugExists = (theHolder.internalSignKey != nil || theHolder.internalVerifyKey != nil ) && secretData == nil;
//            if (bugExists) {
//                return [[JWTCodingResultType alloc] initWithErrorResult:[[JWTCodingResultTypeError alloc] initWithError:[JWTErrorDescription errorWithCode:JWTHolderSecretDataNotSetError]]];
//                return nil;
//            }
//        }
        
        encodedMessage = [self encodeWithAlgorithm:algorithm withHeaders:headers withPayload:payload withSecretData:secretData withError:&error];
        if (encodedMessage && (error == nil)) {
            break;
        }
    }
    
    JWTCodingResultType *result = nil;
    
    if (error) {
        result = [[JWTCodingResultType alloc] initWithErrorResult:[[JWTCodingResultTypeError alloc] initWithError:error]];
    }
    else if (encodedMessage) {
        result = [[JWTCodingResultType alloc] initWithSuccessResult:[[JWTCodingResultTypeSuccess alloc] initWithEncoded:encodedMessage]];
    }
    else {
        NSLog(@"%@ something went wrong! result is nil!", self.debugDescription);
    }
    
    return result;
}
- (NSString *)encodeWithAlgorithm:(id<JWTAlgorithm>)theAlgorithm withHeaders:(NSDictionary *)theHeaders withPayload:(NSDictionary *)thePayload withSecretData:(NSData *)theSecretData withError:(NSError *__autoreleasing *)theError {
    // do it!
    
    if (!theAlgorithm) {
        setError(theError, [JWTErrorDescription errorWithCode:JWTUnspecifiedAlgorithmError]);
        return nil;
    }

    NSString *theAlgorithmName = [theAlgorithm name];
    
    if (!theAlgorithmName) {
        setError(theError, [JWTErrorDescription errorWithCode:JWTUnsupportedAlgorithmError]);
        return nil;
    }
    
    NSDictionary *header = @{
                             @"alg": theAlgorithmName,
                             @"typ": @"JWT"
                             };
    NSMutableDictionary *allHeaders = [header mutableCopy];

    if (theHeaders.allKeys.count > 0) {
        [allHeaders addEntriesFromDictionary:theHeaders];
    }
    
    NSString *headerSegment = [self.internalTokenCoder stringWithData:[self encodeSegment:[allHeaders copy] withError:nil]];
    
    if (!headerSegment) {
        // encode header segment error
        setError(theError, [JWTErrorDescription errorWithCode:JWTEncodingHeaderError]);
        return nil;
    }
    
    NSString *payloadSegment = [self.internalTokenCoder stringWithData:[self encodeSegment:thePayload withError:nil]];
    
    if (!payloadSegment) {
        // encode payment segment error
        setError(theError, [JWTErrorDescription errorWithCode:JWTEncodingPayloadError]);
        return nil;
    }

    NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];

    NSString *signedOutput = nil;

    // this happens somewhere outside.

    NSError *algorithmError = nil;
    if ([theAlgorithm conformsToProtocol:@protocol(JWTRSAlgorithm)]) {
        theSecretData = theSecretData ?: [NSData data];
    }
    if (theSecretData && [theAlgorithm respondsToSelector:@selector(signHash:key:error:)]) {
        __auto_type hash = [self.internalHashCoder dataWithString:signingInput];
        __auto_type signedOutputData = [theAlgorithm signHash:hash key:theSecretData error:&algorithmError];
        signedOutput = [self.internalTokenCoder stringWithData:signedOutputData];
    }

    if (algorithmError) {
        // algorithmError
        setError(theError, algorithmError);
        return nil;
    }
    if (!signedOutput) {
        // Make sure signing worked (e.g. we may have issues extracting the key from the PKCS12 bundle if passphrase is incorrect)
        setError(theError, [JWTErrorDescription errorWithCode:JWTEncodingSigningError]);
        return nil;
    }
    
    return [@[headerSegment, payloadSegment, signedOutput] componentsJoinedByString:@"."];
}

- (NSData *)encodeSegment:(id)theSegment withError:(NSError *__autoreleasing*)error {
    NSData *encodedSegmentData = nil;
    
    if (theSegment) {
        encodedSegmentData = [NSJSONSerialization dataWithJSONObject:theSegment options:0 error:error];
    }
    else {
        // error!
        NSError *generatedError = [JWTErrorDescription errorWithCode:JWTInvalidSegmentSerializationError];
        if (error) {
            *error = generatedError;
        }
        NSLog(@"%@ Could not encode segment: %@", self.class, generatedError.localizedDescription);
        return nil;
    }
        
    return encodedSegmentData;
}

- (JWTCodingResultType *)result {
    return self.encode;
}
@end

@interface JWTDecodingBuilder ()
#pragma mark - Internal
@property (copy, nonatomic, readwrite) NSString *internalMessage;
@property (strong, nonatomic, readwrite) id<JWTClaimsSetCoordinatorProtocol> internalClaimsSetCoordinator;

#pragma mark - Fluent
@property (copy, nonatomic, readwrite) JWTDecodingBuilder *(^message)(NSString *message);
@property (copy, nonatomic, readwrite) JWTDecodingBuilder *(^claimsSetCoordinator)(id<JWTClaimsSetCoordinatorProtocol> claimsSetCoordinator);

@end

@implementation JWTDecodingBuilder (Setters)
- (instancetype)message:(NSString *)message {
    self.internalMessage = message;
    return self;
}
- (instancetype)claimsSetCoordinator:(id<JWTClaimsSetCoordinatorProtocol>)claimsSetCoordinator {
    self.internalClaimsSetCoordinator = claimsSetCoordinator;
    return self;
}
@end

@implementation JWTDecodingBuilder (Fluent_Setup)
- (void)setupFluent {
    [super setupFluent];
    __weak typeof(self) weakSelf = self;
    self.message = ^(NSString *message) {
        return [weakSelf message:message];
    };
    self.claimsSetCoordinator = ^(id<JWTClaimsSetCoordinatorProtocol> claimsSetCoordinator) {
        return [weakSelf claimsSetCoordinator:claimsSetCoordinator];
    };
}
@end

@implementation JWTDecodingBuilder
#pragma mark - Create
+ (instancetype)decodeMessage:(NSString *)message {
    return ((JWTDecodingBuilder *)[self createWithEmptyChain]).message(message);
}
@end

@implementation JWTDecodingBuilder (Coding)
- (JWTCodingResultType *)decode {
    // do!
    // iterate over items in chain!
    // and return if everything ok!
    // or return error!
    __auto_type error = (NSError *)nil;
    __auto_type decodedDictionary = (NSDictionary *)nil;
    __auto_type message = self.internalMessage;
    __auto_type options = self.internalOptions;
    __auto_type holders = self.internalChain.holders;
    __auto_type claimsSetCoordinator = self.internalClaimsSetCoordinator;
    
    // ERROR: HOLDERS ARE EMPTY.
    if (holders.count == 0) {
        error = [JWTErrorDescription errorWithCode:JWTDecodingHoldersChainEmptyError];
    }
    
    for (id <JWTAlgorithmDataHolderProtocol>holder in self.internalChain.holders) {
        // try decode!
        id <JWTAlgorithm> algorithm = holder.internalAlgorithm;
        NSData *secretData = holder.internalSecretData;
        // try to retrieve passphrase.
        decodedDictionary = [self decodeMessage:message secretData:secretData algorithm:algorithm options:options error:&error];
        if (decodedDictionary && (error == nil)) {
            break;
        }
    }
    
    // TODO: claimsSet could be removed.
    // The claimsSet verification should be computed from payload dictionary.
    // claimsSet verification.
    JWTCodingResultType *result = nil;
    if (error) {
        return [[JWTCodingResultType alloc] initWithErrorResult:[[JWTCodingResultTypeError alloc] initWithError:error]];
    }
    
    if (claimsSetCoordinator) {
        __auto_type untrustedClaimsSet = [claimsSetCoordinator.claimsSetSerializer claimsSetFromDictionary:decodedDictionary[JWTCodingResultComponents.payload]];
        __auto_type trustedClaimsSet = claimsSetCoordinator.claimsSetStorage;
        __auto_type claimsVerified = [claimsSetCoordinator.claimsSetVerifier verifyClaimsSet:untrustedClaimsSet withTrustedClaimsSet:trustedClaimsSet];
        if (!claimsVerified) {
            error = [JWTErrorDescription errorWithCode:JWTClaimsSetVerificationFailed];
            return [[JWTCodingResultType alloc] initWithErrorResult:[[JWTCodingResultTypeError alloc] initWithError:error]];
        }
    }
    
    if (decodedDictionary) {
        NSDictionary *headers = decodedDictionary[JWTCodingResultComponents.headers];
        NSDictionary *payload = decodedDictionary[JWTCodingResultComponents.payload];
        id<JWTClaimsSetProtocol> claimsSetStorage = nil;
        
        // extract claims from payload.
        BOOL shouldExtractClaimsSetCoordinator = YES; // add option later.
        BOOL extractClaimsSetCoordinator = claimsSetCoordinator != nil || shouldExtractClaimsSetCoordinator;
        if (extractClaimsSetCoordinator) {
            claimsSetStorage = [self.internalClaimsSetCoordinator.claimsSetSerializer claimsSetFromDictionary:payload];
        }
        result = [[JWTCodingResultType alloc] initWithSuccessResult:[[[JWTCodingResultTypeSuccess alloc] initWithHeaders:headers withPayload:payload] initWithClaimsSetStorage:claimsSetStorage]];
    }
    else {
        NSLog(@"%@ something went wrong! result is nil!", self.debugDescription);
    }
    
    return result;
}

// Maybe later add algorithmName
- (NSDictionary *)decodeMessage:(NSString *)theMessage secretData:(NSData *)theSecretData algorithm:(id<JWTAlgorithm>)theAlgorithm options:(NSNumber *)theOptions error:(NSError *__autoreleasing *)theError {
    
    BOOL skipVerification = [theOptions boolValue];
    NSString *theAlgorithmName = [theAlgorithm name];
    
    NSArray *parts = [theMessage componentsSeparatedByString:@"."];
    
    if (parts.count < 3) {
        // generate error?
        setError(theError, [JWTErrorDescription errorWithCode:JWTInvalidFormatError]);
        return nil;
    }
    
    NSString *headerPart = parts[0];
    NSString *payloadPart = parts[1];
    NSString *signaturePart = parts[2];
    
    // decode headerPart
    NSError *jsonError = nil;
    NSData *headerData = [self.internalTokenCoder dataWithString:headerPart];
    id headerJSON = [NSJSONSerialization JSONObjectWithData:headerData
                                                    options:0
                                                      error:&jsonError];
    if (jsonError) {
        setError(theError, [JWTErrorDescription errorWithCode:JWTDecodingHeaderError]);
        return nil;
    }
    NSDictionary *header = (NSDictionary *)headerJSON;
    if (!header) {
        setError(theError, [JWTErrorDescription errorWithCode:JWTNoHeaderError]);
        return nil;
    }
    
    if (!skipVerification) {
        // find algorithm
        
        //It is insecure to trust the header's value for the algorithm, since
        //the signature hasn't been verified yet, so an algorithm must be provided
        if (!theAlgorithmName) {
            setError(theError, [JWTErrorDescription errorWithCode:JWTUnspecifiedAlgorithmError]);
            return nil;
        }
        
        NSString *headerAlgorithmName = header[@"alg"];
        
        //If the algorithm in the header doesn't match what's expected, verification fails
        if (![theAlgorithmName isEqualToString:headerAlgorithmName]) {
            setError(theError, [JWTErrorDescription errorWithCode:JWTAlgorithmNameMismatchError]);
            return nil;
        }
        
        // A shit logic, but...
        // You should copy algorithm if this algorithm conforms to RSAlgorithm (NSCopying).
        // Now RS Algorithm holds too much. ( All data about keys :/ )
        // Need further investigation.
        id<JWTAlgorithm> algorithm = nil;
        if ([theAlgorithm conformsToProtocol:@protocol(JWTRSAlgorithm)]) {
            algorithm = [(id<JWTRSAlgorithm>)theAlgorithm copyWithZone:nil];
            theSecretData = theSecretData ?: [NSData data];
        }
        else {
            algorithm = [JWTAlgorithmFactory algorithmByName:theAlgorithmName];
        }
        
        if (!algorithm) {
            setError(theError, [JWTErrorDescription errorWithCode:JWTUnsupportedAlgorithmError]);
            return nil;
        }
        
        // Verify the signed part
        NSString *signingInput = [@[headerPart, payloadPart] componentsJoinedByString:@"."];
        BOOL signatureValid = NO;

        NSError *algorithmError = nil;
        if (theSecretData && [algorithm respondsToSelector:@selector(verifyHash:signature:key:error:)]) {
            __auto_type hash = [self.internalHashCoder dataWithString:signingInput];
            __auto_type signedInputData = [self.internalTokenCoder dataWithString:signaturePart];
            signatureValid = [algorithm verifyHash:hash signature:signedInputData key:theSecretData error:&algorithmError];
        }
        
        if (algorithmError) {
            setError(theError, algorithmError);
            return nil;
        }
        if (!signatureValid) {
            setError(theError, [JWTErrorDescription errorWithCode:JWTInvalidSignatureError]);
            return nil;
        }
    }
    
    // and decode payload
    jsonError = nil;
    NSData *payloadData = [self.internalTokenCoder dataWithString:payloadPart];
    id payloadJSON = [NSJSONSerialization JSONObjectWithData:payloadData
                                                     options:0
                                                       error:&jsonError];
    if (jsonError) {
        setError(theError, [JWTErrorDescription errorWithCode:JWTDecodingPayloadError]);
        return nil;
    }
    
    NSDictionary *payload = (NSDictionary *)payloadJSON;
    
    if (!payload) {
        setError(theError, [JWTErrorDescription errorWithCode:JWTNoPayloadError]);
        return nil;
    }
    
    NSDictionary *result = @{
                             JWTCodingResultComponents.headers : header,
                             JWTCodingResultComponents.payload : payload
                             };
    
    setError(theError, nil);
    
    return result;
}

- (JWTCodingResultType *)result {
    return self.decode;
}
@end
