//
//  JWT.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright (c) 2013 Karma. All rights reserved.
//

#import "JWT.h"

#import "MF_Base64Additions+JWT.h"

#import "JWTAlgorithmHS512.h"
#import "JWTClaimsSetSerializer.h"

@implementation JWT

+ (NSString *)encodeClaimsSet:(JWTClaimsSet *)theClaimsSet withSecret:(NSString *)theSecret;
{
    return [self encodeClaimsSet:theClaimsSet withSecret:theSecret withAlgorithm:[[JWTAlgorithmHS512 alloc] init]];
}

+ (NSString *)encodeClaimsSet:(JWTClaimsSet *)theClaimsSet withSecret:(NSString *)theSecret withAlgorithm:(id<JWTAlgorithm>)theAlgorithm;
{
    NSDictionary *payload = [JWTClaimsSetSerializer dictionaryWithClaimsSet:theClaimsSet];
    return [self encodePayload:payload withSecret:theSecret withAlgorithm:theAlgorithm];
}

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret;
{
    return [self encodePayload:thePayload withSecret:theSecret withAlgorithm:[[JWTAlgorithmHS512 alloc] init]];
}

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret withAlgorithm:(id<JWTAlgorithm>)theAlgorithm;
{
    NSMutableDictionary *header = [NSMutableDictionary
                                   dictionaryWithObjects:@[@"JWT",theAlgorithm.name]
                                   forKeys:@[@"type",@"alg"]];

    NSMutableDictionary *algorithmExtraHeaders = [[theAlgorithm initWithSecret:theSecret] headers];
    if (algorithmExtraHeaders) {
        [header addEntriesFromDictionary:algorithmExtraHeaders];
    }

    NSString *headerSegment = [self encodeSegment:header];
    NSString *payloadSegment = [self encodeSegment:thePayload];
    
    NSString *signingInput = [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
    NSString *signedOutput = [[theAlgorithm encodePayload:signingInput withSecret:theSecret] base64SafeString];
    return [@[headerSegment, payloadSegment, signedOutput] componentsJoinedByString:@"."];
}

+ (NSString *)encodeSegment:(id)theSegment;
{
    NSError *error;
    NSString *encodedSegment = [[NSJSONSerialization dataWithJSONObject:theSegment options:0 error:&error] base64SafeString];
    
    NSAssert(!error, @"Could not encode segment: %@", [error localizedDescription]);
    
    return encodedSegment;
}

@end
