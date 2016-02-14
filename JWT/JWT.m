//
//  JWT.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright (c) 2013 Karma. All rights reserved.
//

#import <Base64/MF_Base64Additions.h>

#import "JWT.h"
#import "JWTAlgorithmHS512.h"
#import "JWTAlgorithmFactory.h"
#import "JWTClaimsSetSerializer.h"
#import "NSString+JWT.h"
#import "NSData+JWT.h"
#import "JWTClaimsSetVerifier.h"
static NSString *JWTErrorDomain = @"com.karma.jwt";

@implementation JWT

+ (NSString *)userDescriptionForErrorCode:(JWTError)code {
    NSString *resultString = nil;
    switch (code) {
        case JWTInvalidFormatError: {
            resultString = @"Invalid format! Try to check your encoding algorithm. Maybe you put too much dots as delimiters?";
            break;
        }
        case JWTUnsupportedAlgorithmError: {
            resultString = @"Unsupported algorithm! You could implement it by yourself";
            break;
        }
        case JWTInvalidSignatureError: {
            resultString = @"Invalid signature! It seems that signed part of jwt mismatch generated part by algorithm provided in header.";
            break;
        }
        case JWTNoPayloadError: {
            resultString = @"No payload! Hey, forget payload?";
            break;
        }
        case JWTNoHeaderError: {
            resultString = @"No header! Hmm";
            break;
        }
        case JWTEncodingHeaderError: {
            resultString = @"It seems that header encoding failed";
            break;
        }
        case JWTEncodingPayloadError: {
            resultString = @"It seems that payload encoding failed";
            break;
        }
        case JWTClaimsSetVerificationFailed: {
            resultString = @"It seems that claims verification failed";
            break;
        }
        case JWTInvalidSegmentSerializationError: {
            resultString = @"It seems that json serialization failed for segment";
            break;
        }
        default: {
            resultString = @"Unexpected error";
            break;
        }
    }
    
    return resultString;
}

+ (NSError *)errorWithCode:(JWTError)code {
    return [self errorWithCode:code withUserDescription:[self userDescriptionForErrorCode:code]];
}

+ (NSError *)errorWithCode:(NSInteger)code withUserDescription:(NSString *)string {
    return [NSError errorWithDomain:JWTErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: string}];
}

#pragma mark - Private Methods
+ (NSString *)encodeSegment:(id)theSegment withError:(NSError **)error
{
    NSData *encodedSegmentData = nil;
    
    if (theSegment) {
         encodedSegmentData = [NSJSONSerialization dataWithJSONObject:theSegment options:0 error:error];
    }
    else {
        // error!
        *error = [self errorWithCode:JWTInvalidSegmentSerializationError];
    }
    
    NSString *encodedSegment = nil;
    
    if (!(*error) && encodedSegmentData) {
        encodedSegment = [encodedSegmentData base64UrlEncodedString];
    }
    
    if ((*error)) {
        NSLog(@"%@ Could not encode segment: %@", self.class, (*error).localizedDescription);
    }
    
    return encodedSegment;
}

+ (NSString *)encodeSegment:(id)theSegment;
{
    NSError *error;
    return [self encodeSegment:theSegment withError:&error];
}

#pragma mark - Public Methods

+ (NSString *)encodeClaimsSet:(JWTClaimsSet *)theClaimsSet withSecret:(NSString *)theSecret;
{
    return [self encodeClaimsSet:theClaimsSet withSecret:theSecret algorithm:[[JWTAlgorithmHS512 alloc] init]];
}

+ (NSString *)encodeClaimsSet:(JWTClaimsSet *)theClaimsSet withSecret:(NSString *)theSecret algorithm:(id<JWTAlgorithm>)theAlgorithm;
{
    NSDictionary *payload = [JWTClaimsSetSerializer dictionaryWithClaimsSet:theClaimsSet];
    return [self encodePayload:payload withSecret:theSecret algorithm:theAlgorithm];
}

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret;
{
    return [self encodePayload:thePayload withSecret:theSecret algorithm:[[JWTAlgorithmHS512 alloc] init]];
}

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret algorithm:(id<JWTAlgorithm>)theAlgorithm;
{
    return [self encodePayload:thePayload withSecret:theSecret withHeaders:nil algorithm:theAlgorithm];
}

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret withHeaders:(NSDictionary *)theHeaders algorithm:(id<JWTAlgorithm>)theAlgorithm;
{
    
    NSError *error = nil;
    NSString *encodedString = [self encodePayload:thePayload withSecret:theSecret withHeaders:theHeaders algorithm:theAlgorithm withError:&error];
    
    if (error) {
        // do something
    }
    
    return encodedString;
}

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret withHeaders:(NSDictionary *)theHeaders algorithm:(id<JWTAlgorithm>)theAlgorithm withError:(NSError * __autoreleasing *)theError;
{
    
    NSDictionary *header = @{@"typ": @"JWT", @"alg": theAlgorithm.name};
    NSMutableDictionary *allHeaders = [header mutableCopy];
    
    if (theHeaders.allKeys.count) {
        [allHeaders addEntriesFromDictionary:theHeaders];
    }
    
    NSString *headerSegment = [self encodeSegment:[allHeaders copy] withError:theError];
    
    if (!headerSegment) {
        // encode header segment error
        *theError = [self errorWithCode:JWTEncodingHeaderError];
        return nil;
    }
    
    NSString *payloadSegment = [self encodeSegment:thePayload withError:theError];
    
    if (!payloadSegment) {
        // encode payment segment error
        *theError = [self errorWithCode:JWTEncodingPayloadError];
        return nil;
    }
    
    if (!theAlgorithm) {
        // error
        *theError = [self errorWithCode:JWTUnsupportedAlgorithmError];
        return nil;
    }
    
    NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
    NSString *signedOutput = [[theAlgorithm encodePayload:signingInput withSecret:theSecret] base64UrlEncodedString];
    
    return [@[headerSegment, payloadSegment, signedOutput] componentsJoinedByString:@"."];
}

#pragma mark - Decode
+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withTrustedClaimsSet:(JWTClaimsSet *)theTrustedClaimsSet withError:(NSError *__autoreleasing *)theError withForcedOption:(BOOL)theForcedOption
{
    NSDictionary *dictionary = [self decodeMessage:theMessage withSecret:theSecret withError:theError withForcedOption:theForcedOption];
    if (*theError) {
        // do something
        return dictionary;
    }
    
    if (theTrustedClaimsSet) {
        BOOL claimVerified = [JWTClaimsSetVerifier verifyClaimsSet:[JWTClaimsSetSerializer claimsSetWithDictionary:dictionary[@"payload"]] withTrustedClaimsSet:theTrustedClaimsSet];
        if (claimVerified) {
            return dictionary;
        }
        else {
            *theError = [JWT errorWithCode:JWTClaimsSetVerificationFailed];
            return nil;
        }
    }
    
    return dictionary;
}

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError *__autoreleasing *)theError withForcedOption:(BOOL)theForcedOption;
{
    NSString *forcedAlgorithName = theForcedOption ? @"none" : nil;
    return [self decodeMessage:theMessage withSecret:theSecret withError:theError withForcedAlgorithmByName:forcedAlgorithName];
}

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError *__autoreleasing *)theError withForcedAlgorithmByName:(NSString *)theAlgorithmName;
{
    NSArray *parts = [theMessage componentsSeparatedByString:@"."];
    
    if (parts.count < 3) {
        // generate error?
        *theError = [self errorWithCode:JWTInvalidFormatError];
        return nil;
    }
    
    NSString *headerPart = parts[0];
    NSString *payloadPart = parts[1];
    NSString *signedPart = parts[2];
    
    // decode headerPart
    NSDictionary *header = (NSDictionary *)headerPart.jsonObjectFromBase64String;
    if (!header) {
        *theError = [self errorWithCode:JWTNoHeaderError];
        return nil;
    }
    
    // find algorithm
    id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:header[@"alg"]];
    id<JWTAlgorithm> alternativeAlgorithm = [JWTAlgorithmFactory algorithmByName:theAlgorithmName];
    algorithm = alternativeAlgorithm ? alternativeAlgorithm : algorithm;
    
    if (!algorithm) {
        *theError = [self errorWithCode:JWTUnsupportedAlgorithmError];
        return nil;
        //    NSAssert(!algorithm, @"Can't decode segment!, %@", header);
    }
    
    // check signed part equality
    NSString *signingInput = [@[headerPart, payloadPart] componentsJoinedByString:@"."];
    
    NSString *validityPart = [[algorithm encodePayload:signingInput withSecret:theSecret] base64UrlEncodedString];
    
    BOOL signatureValid = ([algorithm respondsToSelector:@selector(verifySignedInput:withSignature:)] && [algorithm verifySignedInput:signingInput withSignature:validityPart]) || [validityPart isEqualToString:signedPart];
    
    if (!signatureValid) {
        *theError = [self errorWithCode:JWTInvalidSignatureError];
        return nil;
    }
    
    // and decode payload
    NSDictionary *payload = (NSDictionary *)payloadPart.jsonObjectFromBase64String;
    
    if (!payload) {
        *theError = [self errorWithCode:JWTNoPayloadError];
        return nil;
    }
    
    NSDictionary *result = @{
                             @"header" : header,
                             @"payload" : payload
                             };
    
    return result;
}

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError * __autoreleasing *)theError;
{
    return [self decodeMessage:theMessage withSecret:theSecret withError:theError withForcedAlgorithmByName:nil];
}

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret;
{
    NSError *error = nil;
    NSDictionary *dictionary = [self decodeMessage:theMessage withSecret:theSecret withError:&error];
    if (error) {
        // do something
    }
    return dictionary;
}

#pragma mark - Builder

+ (JWTBuilder *)encodePayload:(NSDictionary *)payload {
    return [JWTBuilder encodePayload:payload];
}

+ (JWTBuilder *)encodeClaimsSet:(JWTClaimsSet *)claimsSet {
    return [JWTBuilder encodeClaimsSet:claimsSet];
}

+ (JWTBuilder *)decodeMessage:(NSString *)message {
    return [JWTBuilder decodeMessage:message];
}

@end


@interface JWTBuilder()

@property (copy, nonatomic, readwrite) NSString *jwtMessage;
@property (copy, nonatomic, readwrite) NSDictionary *jwtPayload;
@property (copy, nonatomic, readwrite) NSDictionary *jwtHeaders;
@property (copy, nonatomic, readwrite) JWTClaimsSet *jwtClaimsSet;
@property (copy, nonatomic, readwrite) NSString *jwtSecret;
@property (copy, nonatomic, readwrite) NSError *jwtError;
@property (strong, nonatomic, readwrite) id<JWTAlgorithm> jwtAlgorithm;
@property (copy, nonatomic, readwrite) NSString *jwtAlgorithmName;
@property (copy, nonatomic, readwrite) NSNumber *jwtOptions;

@property (copy, nonatomic, readwrite) JWTBuilder *(^message)(NSString *message);
@property (copy, nonatomic, readwrite) JWTBuilder *(^payload)(NSDictionary *payload);
@property (copy, nonatomic, readwrite) JWTBuilder *(^headers)(NSDictionary *headers);
@property (copy, nonatomic, readwrite) JWTBuilder *(^claimsSet)(JWTClaimsSet *claimsSet);
@property (copy, nonatomic, readwrite) JWTBuilder *(^secret)(NSString *secret);
@property (copy, nonatomic, readwrite) JWTBuilder *(^algorithm)(id<JWTAlgorithm>algorithm);
@property (copy, nonatomic, readwrite) JWTBuilder *(^algorithmName)(NSString *algorithmName);
@property (copy, nonatomic, readwrite) JWTBuilder *(^options)(NSNumber *options);

@end

@implementation JWTBuilder

#pragma mark - Getters
- (id<JWTAlgorithm>)jwtAlgorithm {
    return _jwtAlgorithm ? _jwtAlgorithm : [JWTAlgorithmFactory algorithmByName:_jwtAlgorithmName];
}

- (NSDictionary *)jwtPayload {
    return _jwtClaimsSet ? [JWTClaimsSetSerializer dictionaryWithClaimsSet:_jwtClaimsSet] : _jwtPayload;
}

#pragma mark - Fluent
- (instancetype)message:(NSString *)message {
    self.jwtMessage = message;
    return self;
}

- (instancetype)payload:(NSDictionary *)payload {
    self.jwtPayload = payload;
    return self;
}

- (instancetype)headers:(NSDictionary *)headers {
    self.jwtHeaders = headers;
    return self;
}

- (instancetype)claimSet:(JWTClaimsSet *)claimSet {
    self.jwtClaimsSet = claimSet;
    return self;
}

- (instancetype)secret:(NSString *)secret {
    self.jwtSecret = secret;
    return self;
}

- (instancetype)algorithm:(id<JWTAlgorithm>)algorithm {
    self.jwtAlgorithm = algorithm;
    return self;
}

- (instancetype)algorithmName:(NSString *)algorithmName {
    self.jwtAlgorithmName = algorithmName;
    return self;
}

- (instancetype)options:(NSNumber *)options {
    self.jwtOptions = options;
    return self;
}

#pragma mark - Initialization
+ (JWTBuilder *)encodePayload:(NSDictionary *)payload {
    return [[JWTBuilder alloc] init].payload(payload);
}

+ (JWTBuilder *)encodeClaimsSet:(JWTClaimsSet *)claimsSet {
    return [[JWTBuilder alloc] init].claimsSet(claimsSet);
}

+ (JWTBuilder *)decodeMessage:(NSString *)message {
    return [[JWTBuilder alloc] init].message(message);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        self.message = ^(NSString *message) {
            return [weakSelf message:message];
        };
        
        self.payload = ^(NSDictionary *payload) {
            return [weakSelf payload:payload];
        };
        
        self.headers = ^(NSDictionary *headers) {
            return [weakSelf headers:headers];
        };

        self.claimsSet = ^(JWTClaimsSet *claimSet) {
            return [weakSelf claimSet:claimSet];
        };

        self.secret = ^(NSString *secret) {
            return [weakSelf secret:secret];
        };

        self.algorithm = ^(id<JWTAlgorithm> algorithm) {
            return [weakSelf algorithm:algorithm];
        };

        self.algorithmName = ^(NSString *algorithmName) {
            return [weakSelf algorithmName:algorithmName];
        };
        
        self.options = ^(NSNumber *options) {
            return [weakSelf options:options];
        };
    }

    return self;
}

#pragma mark - Encoding/Decoding
- (NSString *)encode {
    NSString *result = nil;
    NSError *error = nil;
    result = [JWT encodePayload:self.jwtPayload withSecret:self.jwtSecret withHeaders:self.jwtHeaders algorithm:self.jwtAlgorithm withError:&error];
    self.jwtError = error;
    return result;
}

- (NSDictionary *)decode {
    NSDictionary *result = nil;
    NSError *error = nil;
    result = [JWT decodeMessage:self.jwtMessage withSecret:self.jwtSecret withTrustedClaimsSet:self.jwtClaimsSet withError:&error withForcedOption:self.jwtOptions.boolValue];
    self.jwtError = error;
    
    return result;
}

@end