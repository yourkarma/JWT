//
//  JWTCoding+VersionOne.m
//  JWT
//
//  Created by Lobanov Dmitry on 27.11.16.
//  Copyright © 2016 JWTIO. All rights reserved.
//

#import <JWT/JWTCoding+VersionOne.h>
#import <JWT/JWTBase64Coder.h>

#import <JWT/JWTRSAlgorithm.h>

#import <JWT/JWTAlgorithmFactory.h>
#import <JWT/JWTAlgorithmHSBase.h>

#import <JWT/JWTAlgorithmDataHolder.h>

#import <JWT/JWTClaimsSetSerializer.h>
#import <JWT/JWTClaimsSetVerifier.h>

#import <JWT/JWTErrorDescription.h>

static inline void setError(NSError **error, NSError* value) {
    if (error) {
        *error = value;
    }
}

@implementation JWT (VersionOne)
#pragma mark - Private Methods
+ (NSString *)encodeSegment:(id)theSegment withError:(NSError **)error
{
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
    
    NSString *encodedSegment = nil;
    
    if (encodedSegmentData) {
        encodedSegment = [JWTBase64Coder base64UrlEncodedStringWithData:encodedSegmentData];//[encodedSegmentData base64UrlEncodedString];
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
    return [self encodeClaimsSet:theClaimsSet withSecret:theSecret algorithm:[JWTAlgorithmFactory algorithmByName:JWTAlgorithmNameHS512]];
}

+ (NSString *)encodeClaimsSet:(JWTClaimsSet *)theClaimsSet withSecret:(NSString *)theSecret algorithm:(id<JWTAlgorithm>)theAlgorithm;
{
    NSDictionary *payload = [JWTClaimsSetSerializer dictionaryWithClaimsSet:theClaimsSet];
    return [self encodePayload:payload withSecret:theSecret algorithm:theAlgorithm];
}

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret;
{
    return [self encodePayload:thePayload withSecret:theSecret algorithm:[JWTAlgorithmFactory algorithmByName:JWTAlgorithmNameHS512]];
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
        setError(theError, [JWTErrorDescription errorWithCode:JWTEncodingHeaderError]);
        return nil;
    }
    
    NSString *payloadSegment = [self encodeSegment:thePayload withError:theError];
    
    if (!payloadSegment) {
        // encode payment segment error
        setError(theError, [JWTErrorDescription errorWithCode:JWTEncodingPayloadError]);
        return nil;
    }
    
    if (!theAlgorithm) {
        // error
        setError(theError, [JWTErrorDescription errorWithCode:JWTUnsupportedAlgorithmError]);
        return nil;
    }
    
    NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
    __auto_type theAlgorithmHolder = [[JWTAlgorithmHolder alloc] initWithAlgorithm:theAlgorithm];
    NSData *signedOutputData = [theAlgorithmHolder encodePayload:signingInput withSecret:theSecret];
    NSString *signedOutput = [JWTBase64Coder base64UrlEncodedStringWithData:signedOutputData];
    
    return [@[headerSegment, payloadSegment, signedOutput] componentsJoinedByString:@"."];
}

#pragma mark - Decode

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withTrustedClaimsSet:(JWTClaimsSet *)theTrustedClaimsSet withError:(NSError *__autoreleasing *)theError withForcedAlgorithmByName:(NSString *)theAlgorithmName
{
    return [self decodeMessage:theMessage withSecret:theSecret withTrustedClaimsSet:theTrustedClaimsSet withError:theError withForcedAlgorithmByName:theAlgorithmName withForcedOption:NO];
}

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withTrustedClaimsSet:(JWTClaimsSet *)theTrustedClaimsSet withError:(NSError *__autoreleasing *)theError withForcedOption:(BOOL)theForcedOption
{
    return [self decodeMessage:theMessage withSecret:theSecret withTrustedClaimsSet:theTrustedClaimsSet withError:theError withForcedAlgorithmByName:JWTAlgorithmNameHS512 withForcedOption:theForcedOption];
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
            setError(theError, [JWTErrorDescription errorWithCode:JWTClaimsSetVerificationFailed]);
            return nil;
        }
    }
    
    return dictionary;
}

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError *__autoreleasing *)theError withForcedOption:(BOOL)theForcedOption;
{
    return [self decodeMessage:theMessage withSecret:theSecret withError:theError withForcedAlgorithmByName:JWTAlgorithmNameHS512 skipVerification:theForcedOption];
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
        setError(theError, [JWTErrorDescription errorWithCode:JWTInvalidFormatError]);
        return nil;
    }
    
    NSString *headerPart = parts[0];
    NSString *payloadPart = parts[1];
    NSString *signedPart = parts[2];
    
    // decode headerPart
    NSError *jsonError = nil;
    NSData *headerData = [JWTBase64Coder dataWithBase64UrlEncodedString:headerPart];
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
            setError(theError, [JWTErrorDescription errorWithCode:JWTUnsupportedAlgorithmError]);
            return nil;
        }
        
        //If a whitelist is passed in, ensure the chosen algorithm is allowed
        if (theWhitelist) {
            if (![theWhitelist containsObject:theAlgorithmName]) {
                setError(theError, [JWTErrorDescription errorWithCode:JWTUnsupportedAlgorithmError]);
                return nil;
            }
        }
        
        id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:theAlgorithmName];
        
        if (!algorithm) {
            setError(theError, [JWTErrorDescription errorWithCode:JWTUnsupportedAlgorithmError]);
            return nil;
        }
        
        // Verify the signed part
        NSString *signingInput = [@[headerPart, payloadPart] componentsJoinedByString:@"."];
        __auto_type theAlgorithmHolder = [[JWTAlgorithmHolder alloc] initWithAlgorithm:algorithm];
        BOOL signatureValid = [theAlgorithmHolder verifySignedInput:signingInput withSignature:signedPart verificationKey:theSecret];
        
        if (!signatureValid) {
            setError(theError, [JWTErrorDescription errorWithCode:JWTInvalidSignatureError]);
            return nil;
        }
    }
    
    // and decode payload
    jsonError = nil;
    NSData *payloadData = [JWTBase64Coder dataWithBase64UrlEncodedString:payloadPart];
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
                             @"header" : header,
                             @"payload" : payload
                             };
    
    return result;
}

+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError * __autoreleasing *)theError;
{
    return [self decodeMessage:theMessage withSecret:theSecret withError:theError withForcedAlgorithmByName:JWTAlgorithmNameHS512];
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

@end
