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
#import "JWTClaimsSetVerifier.h"
#import "JWTRSAlgorithm.h"

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
        case JWTEncodingSigningError: {
            resultString = @"It seems that signing output corrupted. Make sure signing worked (e.g. we may have issues extracting the key from the PKCS12 bundle if passphrase is incorrect).";
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
        case JWTUnspecifiedAlgorithmError: {
            resultString = @"Unspecified algorithm! You must explicitly choose an algorithm to decode with.";
            break;
        }
        case JWTDecodingHeaderError: {
            resultString = @"Error decoding the JWT Header segment.";
            break;
        }
        case JWTDecodingPayloadError: {
            resultString = @"Error decoding the JWT Payload segment.";
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
        NSError *generatedError = [self errorWithCode:JWTInvalidSegmentSerializationError];
        if (error) {
            *error = generatedError;
        }
        NSLog(@"%@ Could not encode segment: %@", self.class, generatedError.localizedDescription);
        return nil;
    }
    
    NSString *encodedSegment = nil;
    
    if (encodedSegmentData) {
        encodedSegment = [encodedSegmentData base64UrlEncodedString];
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

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withTrustedClaimsSet:(JWTClaimsSet *)theTrustedClaimsSet withError:(NSError *__autoreleasing *)theError withForcedAlgorithmByName:(NSString *)theAlgorithmName
{
    return [self decodeMessage:theMessage withSecret:theSecret withTrustedClaimsSet:theTrustedClaimsSet withError:theError withForcedAlgorithmByName:theAlgorithmName withForcedOption:NO];
}

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withTrustedClaimsSet:(JWTClaimsSet *)theTrustedClaimsSet withError:(NSError *__autoreleasing *)theError withForcedOption:(BOOL)theForcedOption
{
    return [self decodeMessage:theMessage withSecret:theSecret withTrustedClaimsSet:theTrustedClaimsSet withError:theError withForcedAlgorithmByName:[[JWTAlgorithmHS512 alloc] init].name withForcedOption:theForcedOption];
}

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withTrustedClaimsSet:(JWTClaimsSet *)theTrustedClaimsSet withError:(NSError *__autoreleasing *)theError withForcedAlgorithmByName:(NSString *)theAlgorithmName withForcedOption:(BOOL)theForcedOption
{
    return [self decodeMessage:theMessage withSecret:theSecret withTrustedClaimsSet:theTrustedClaimsSet withError:theError withForcedAlgorithmByName:theAlgorithmName withForcedOption:theForcedOption withAlgorithmWhiteList:nil];
}

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withTrustedClaimsSet:(JWTClaimsSet *)theTrustedClaimsSet withError:(NSError *__autoreleasing *)theError withForcedAlgorithmByName:(NSString *)theAlgorithmName withForcedOption:(BOOL)theForcedOption withAlgorithmWhiteList:(NSSet *)theWhitelist
{
    NSDictionary *dictionary = [self decodeMessage:theMessage withSecret:theSecret withError:theError withForcedAlgorithmByName:theAlgorithmName skipVerification:theForcedOption whitelist:theWhitelist];
    
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
    return [self decodeMessage:theMessage withSecret:theSecret withError:theError withForcedAlgorithmByName:[[JWTAlgorithmHS512 alloc] init].name skipVerification:theForcedOption];
}

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError *__autoreleasing *)theError withForcedAlgorithmByName:(NSString *)theAlgorithmName;
{
    return [self decodeMessage:theMessage withSecret:theSecret withError:theError withForcedAlgorithmByName:theAlgorithmName skipVerification:NO];
}

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError *__autoreleasing *)theError withForcedAlgorithmByName:(NSString *)theAlgorithmName skipVerification:(BOOL)skipVerification
{
    return [self decodeMessage:theMessage withSecret:theSecret withError:theError withForcedAlgorithmByName:theAlgorithmName skipVerification:skipVerification whitelist:nil];
}

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError *__autoreleasing *)theError withForcedAlgorithmByName:(NSString *)theAlgorithmName skipVerification:(BOOL)skipVerification whitelist:(NSSet *)theWhitelist
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
    NSError *jsonError = nil;
    NSData *headerData = [NSData dataWithBase64String:headerPart];
    id headerJSON = [NSJSONSerialization JSONObjectWithData:headerData
                                                    options:0
                                                      error:&jsonError];
    if (jsonError) {
        *theError = [self errorWithCode:JWTDecodingHeaderError];
        return nil;
    }
    NSDictionary *header = (NSDictionary *)headerJSON;
    if (!header) {
        *theError = [self errorWithCode:JWTNoHeaderError];
        return nil;
    }
    
    if (!skipVerification) {
        // find algorithm
        
        //It is insecure to trust the header's value for the algorithm, since
        //the signature hasn't been verified yet, so an algorithm must be provided
        if (!theAlgorithmName) {
            *theError = [self errorWithCode:JWTUnspecifiedAlgorithmError];
            return nil;
        }
        
        NSString *headerAlgorithmName = header[@"alg"];
        
        //If the algorithm in the header doesn't match what's expected, verification fails
        if (![theAlgorithmName isEqualToString:headerAlgorithmName]) {
            *theError = [self errorWithCode:JWTUnsupportedAlgorithmError];
            return nil;
        }
        
        //If a whitelist is passed in, ensure the chosen algorithm is allowed
        if (theWhitelist) {
            if (![theWhitelist containsObject:theAlgorithmName]) {
                *theError = [self errorWithCode:JWTUnsupportedAlgorithmError];
                return nil;
            }
        }
        
        id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:theAlgorithmName];
        
        if (!algorithm) {
            *theError = [self errorWithCode:JWTUnsupportedAlgorithmError];
            return nil;
            //    NSAssert(!algorithm, @"Can't decode segment!, %@", header);
        }
        
        // Verify the signed part
        NSString *signingInput = [@[headerPart, payloadPart] componentsJoinedByString:@"."];
        BOOL signatureValid = [algorithm verifySignedInput:signingInput withSignature:signedPart verificationKey:theSecret];
        
        if (!signatureValid) {
            *theError = [self errorWithCode:JWTInvalidSignatureError];
            return nil;
        }
    }
    
    // and decode payload
    jsonError = nil;
    NSData *payloadData = [NSData dataWithBase64String:payloadPart];
    id payloadJSON = [NSJSONSerialization JSONObjectWithData:payloadData
                                                    options:0
                                                      error:&jsonError];
    if (jsonError) {
        *theError = [self errorWithCode:JWTDecodingPayloadError];
        return nil;
    }
    NSDictionary *payload = (NSDictionary *)payloadJSON;
    
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
    return [self decodeMessage:theMessage withSecret:theSecret withError:theError withForcedAlgorithmByName:[[JWTAlgorithmHS512 alloc] init].name];
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
@property (copy, nonatomic, readwrite) NSData *jwtSecretData;
@property (copy, nonatomic, readwrite) NSString *jwtPrivateKeyCertificatePassphrase;
@property (copy, nonatomic, readwrite) NSError *jwtError;
@property (strong, nonatomic, readwrite) id<JWTAlgorithm> jwtAlgorithm;
@property (copy, nonatomic, readwrite) NSString *jwtAlgorithmName;
@property (copy, nonatomic, readwrite) NSNumber *jwtOptions;
@property (copy, nonatomic, readwrite) NSSet *algorithmWhitelist;

@property (copy, nonatomic, readwrite) JWTBuilder *(^message)(NSString *message);
@property (copy, nonatomic, readwrite) JWTBuilder *(^payload)(NSDictionary *payload);
@property (copy, nonatomic, readwrite) JWTBuilder *(^headers)(NSDictionary *headers);
@property (copy, nonatomic, readwrite) JWTBuilder *(^claimsSet)(JWTClaimsSet *claimsSet);
@property (copy, nonatomic, readwrite) JWTBuilder *(^secret)(NSString *secret);
@property (copy, nonatomic, readwrite) JWTBuilder *(^secretData)(NSData *secretData);
@property (copy, nonatomic, readwrite) JWTBuilder *(^privateKeyCertificatePassphrase)(NSString *privateKeyCertificatePassphrase);
@property (copy, nonatomic, readwrite) JWTBuilder *(^algorithm)(id<JWTAlgorithm>algorithm);
@property (copy, nonatomic, readwrite) JWTBuilder *(^algorithmName)(NSString *algorithmName);
@property (copy, nonatomic, readwrite) JWTBuilder *(^options)(NSNumber *options);
@property (copy, nonatomic, readwrite) JWTBuilder *(^whitelist)(NSArray *whitelist);

@end

@implementation JWTBuilder

#pragma mark - Getters
- (id<JWTAlgorithm>)jwtAlgorithm {
    if (!_jwtAlgorithm) {
        _jwtAlgorithm = [JWTAlgorithmFactory algorithmByName:_jwtAlgorithmName];
    }
    return _jwtAlgorithm;
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

- (instancetype)secretData:(NSData *)secretData {
    self.jwtSecretData = secretData;
    return self;
}

- (instancetype)privateKeyCertificatePassphrase:(NSString *)privateKeyCertificatePassphrase {
    self.jwtPrivateKeyCertificatePassphrase = privateKeyCertificatePassphrase;
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

- (instancetype)whitelist:(NSArray *)whitelist {
    if (whitelist) {
        self.algorithmWhitelist = [NSSet setWithArray:whitelist];
    } else {
        self.algorithmWhitelist = nil;
    }
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
        
        self.secretData = ^(NSData *secretData) {
            return [weakSelf secretData:secretData];
        };

        self.privateKeyCertificatePassphrase = ^(NSString *privateKeyCertificatePassphrase) {
            return [weakSelf privateKeyCertificatePassphrase:privateKeyCertificatePassphrase];
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
        
        self.whitelist = ^(NSArray *whitelist) {
            return [weakSelf whitelist:whitelist];
        };
    }

    return self;
}

#pragma mark - Encoding/Decoding

- (NSString *)encode {
    NSString *result = nil;
    self.jwtError = nil;
    result = [self encodeHelper];
    return result;
}

- (NSDictionary *)decode {
    NSDictionary *result = nil;
    self.jwtError = nil;
    result = [self decodeHelper];
    
    return result;
}

#pragma mark - Private

#pragma mark - Encode Helpers

- (NSString *)encodeHelper
{
    if (!self.jwtAlgorithm) {
        self.jwtError = [JWT errorWithCode:JWTUnspecifiedAlgorithmError];
        return nil;
    }
    
    NSDictionary *header = @{@"typ": @"JWT", @"alg": self.jwtAlgorithm.name};
    NSMutableDictionary *allHeaders = [header mutableCopy];
    
    if (self.jwtHeaders.allKeys.count > 0) {
        [allHeaders addEntriesFromDictionary:self.jwtHeaders];
    }
    
    NSString *headerSegment = [self encodeSegment:[allHeaders copy] withError:nil];
    
    if (!headerSegment) {
        // encode header segment error
        self.jwtError = [JWT errorWithCode:JWTEncodingHeaderError];
        return nil;
    }
    
    NSString *payloadSegment = [self encodeSegment:self.jwtPayload withError:nil];
    
    if (!payloadSegment) {
        // encode payment segment error
        self.jwtError = [JWT errorWithCode:JWTEncodingPayloadError];
        return nil;
    }
    
    NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
    
    NSString *signedOutput;

    if ([self.jwtAlgorithm conformsToProtocol:@protocol(JWTRSAlgorithm)]) {
        id<JWTRSAlgorithm> jwtRsAlgorithm = (id <JWTRSAlgorithm>) self.jwtAlgorithm;
        jwtRsAlgorithm.privateKeyCertificatePassphrase = self.jwtPrivateKeyCertificatePassphrase;
    }
    if (self.jwtSecretData && [self.jwtAlgorithm respondsToSelector:@selector(encodePayloadData:withSecret:)]) {
        signedOutput = [[self.jwtAlgorithm encodePayloadData:[signingInput dataUsingEncoding:NSUTF8StringEncoding] withSecret:self.jwtSecretData] base64UrlEncodedString];
    } else {
        signedOutput = [[self.jwtAlgorithm encodePayload:signingInput withSecret:self.jwtSecret] base64UrlEncodedString];
    }

    if (signedOutput) { // Make sure signing worked (e.g. we may have issues extracting the key from the PKCS12 bundle if passphrase is incorrect)
        return [@[headerSegment, payloadSegment, signedOutput] componentsJoinedByString:@"."];
    } else {
        self.jwtError = [JWT errorWithCode:JWTEncodingSigningError];
        return nil;
    }
}

- (NSString *)encodeSegment:(id)theSegment withError:(NSError **)error
{
    NSData *encodedSegmentData = nil;
    
    if (theSegment) {
        encodedSegmentData = [NSJSONSerialization dataWithJSONObject:theSegment options:0 error:error];
    }
    else {
        // error!
        NSError *generatedError = [JWT errorWithCode:JWTInvalidSegmentSerializationError];
        if (error) {
            *error = generatedError;
        }
        NSLog(@"%@ Could not encode segment: %@", self.class, generatedError.localizedDescription);
        return nil;
    }
    
    NSString *encodedSegment = nil;
    
    if (encodedSegmentData) {
        encodedSegment = [encodedSegmentData base64UrlEncodedString];
    }
    
    return encodedSegment;
}

#pragma mark - Decode Helpers

- (NSDictionary *)decodeHelper
{
    NSError *error = nil;
    NSDictionary *dictionary = [self decodeMessage:self.jwtMessage withSecret:self.jwtSecret withSecretData:self.jwtSecretData withError:&error withForcedAlgorithmByName:self.jwtAlgorithmName skipVerification:[self.jwtOptions boolValue] whitelist:self.algorithmWhitelist];
    
    if (error) {
        self.jwtError = error;
        return nil;
    }
    
    if (self.jwtClaimsSet) {
        BOOL claimVerified = [JWTClaimsSetVerifier verifyClaimsSet:[JWTClaimsSetSerializer claimsSetWithDictionary:dictionary[@"payload"]] withTrustedClaimsSet:self.jwtClaimsSet];
        if (claimVerified) {
            return dictionary;
        }
        else {
            self.jwtError = [JWT errorWithCode:JWTClaimsSetVerificationFailed];
            return nil;
        }
    }
    
    return dictionary;
}

- (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withSecretData:(NSData *)secretData withError:(NSError *__autoreleasing *)theError withForcedAlgorithmByName:(NSString *)theAlgorithmName skipVerification:(BOOL)skipVerification whitelist:(NSSet *)theWhitelist
{
    NSArray *parts = [theMessage componentsSeparatedByString:@"."];
    
    if (parts.count < 3) {
        // generate error?
        *theError = [JWT errorWithCode:JWTInvalidFormatError];
        return nil;
    }
    
    NSString *headerPart = parts[0];
    NSString *payloadPart = parts[1];
    NSString *signedPart = parts[2];
    
    // decode headerPart
    NSError *jsonError = nil;
    NSData *headerData = [NSData dataWithBase64String:headerPart];
    id headerJSON = [NSJSONSerialization JSONObjectWithData:headerData
                                                    options:0
                                                      error:&jsonError];
    if (jsonError) {
        *theError = [JWT errorWithCode:JWTDecodingHeaderError];
        return nil;
    }
    NSDictionary *header = (NSDictionary *)headerJSON;
    if (!header) {
        *theError = [JWT errorWithCode:JWTNoHeaderError];
        return nil;
    }
    
    if (!skipVerification) {
        // find algorithm
        
        //It is insecure to trust the header's value for the algorithm, since
        //the signature hasn't been verified yet, so an algorithm must be provided
        if (!theAlgorithmName) {
            *theError = [JWT errorWithCode:JWTUnspecifiedAlgorithmError];
            return nil;
        }
        
        NSString *headerAlgorithmName = header[@"alg"];
        
        //If the algorithm in the header doesn't match what's expected, verification fails
        if (![theAlgorithmName isEqualToString:headerAlgorithmName]) {
            *theError = [JWT errorWithCode:JWTUnsupportedAlgorithmError];
            return nil;
        }
        
        //If a whitelist is passed in, ensure the chosen algorithm is allowed
        if (theWhitelist) {
            if (![theWhitelist containsObject:theAlgorithmName]) {
                *theError = [JWT errorWithCode:JWTUnsupportedAlgorithmError];
                return nil;
            }
        }
        
        id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:theAlgorithmName];
        
        if (!algorithm) {
            *theError = [JWT errorWithCode:JWTUnsupportedAlgorithmError];
            return nil;
            //    NSAssert(!algorithm, @"Can't decode segment!, %@", header);
        }
        
        // Verify the signed part
        NSString *signingInput = [@[headerPart, payloadPart] componentsJoinedByString:@"."];
        BOOL signatureValid = NO;
        
        
        if (secretData && [self.jwtAlgorithm respondsToSelector:@selector(verifySignedInput:withSignature:verificationKeyData:)]) {
            signatureValid = [self.jwtAlgorithm verifySignedInput:signingInput withSignature:signedPart verificationKeyData:secretData];
        } else {
            signatureValid = [algorithm verifySignedInput:signingInput withSignature:signedPart verificationKey:theSecret];
        }
        
        if (!signatureValid) {
            *theError = [JWT errorWithCode:JWTInvalidSignatureError];
            return nil;
        }
    }
    
    // and decode payload
    jsonError = nil;
    NSData *payloadData = [NSData dataWithBase64String:payloadPart];
    id payloadJSON = [NSJSONSerialization JSONObjectWithData:payloadData
                                                     options:0
                                                       error:&jsonError];
    if (jsonError) {
        *theError = [JWT errorWithCode:JWTDecodingPayloadError];
        return nil;
    }
    NSDictionary *payload = (NSDictionary *)payloadJSON;
    
    if (!payload) {
        *theError = [JWT errorWithCode:JWTNoPayloadError];
        return nil;
    }
    
    NSDictionary *result = @{
                             @"header" : header,
                             @"payload" : payload
                             };
    
    return result;
}

@end