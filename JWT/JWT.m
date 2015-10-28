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
+ (NSString *)encodeSegment:(id)theSegment;
{
    NSError *error;
    NSString *encodedSegment = [[NSJSONSerialization dataWithJSONObject:theSegment options:0 error:&error] base64UrlEncodedString];
    
    NSAssert(!error, @"Could not encode segment: %@", error.localizedDescription);
    
    return encodedSegment;
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
    
    NSDictionary *header = @{@"typ": @"JWT", @"alg": theAlgorithm.name};
    NSMutableDictionary *allHeaders = [header mutableCopy];
    
    if (theHeaders.allKeys.count) {
        [allHeaders addEntriesFromDictionary:theHeaders];
    }
    
    NSString *headerSegment = [self encodeSegment:[allHeaders copy]];
    NSString *payloadSegment = [self encodeSegment:thePayload];
    
    NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
    NSString *signedOutput = [[theAlgorithm encodePayload:signingInput withSecret:theSecret] base64UrlEncodedString];
    
    return [@[headerSegment, payloadSegment, signedOutput] componentsJoinedByString:@"."];
}

#pragma mark - Decode
+ (NSDictionary *)decodeMessage:(NSString *)theMessage withSecret:(NSString *)theSecret withError:(NSError * __autoreleasing *)theError;
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
    
    if (!algorithm) {
        *theError = [self errorWithCode:JWTUnsupportedAlgorithmError];
        return nil;
        //    NSAssert(!algorithm, @"Can't decode segment!, %@", header);
    }
    
    // check signed part equality
    NSString *signingInput = [@[headerPart, payloadPart] componentsJoinedByString:@"."];
    
    NSString *validityPart = [[algorithm encodePayload:signingInput withSecret:theSecret] base64UrlEncodedString];
    
    BOOL signatureValid = [validityPart isEqualToString:signedPart];
    
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
