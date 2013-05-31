//
//  JWT.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright (c) 2013 Karma. All rights reserved.
//

#import "JWT.h"

#import "Base64.h"

#import "JWTAlgorithmHS512.h"

@implementation JWT

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret;
{
    return [self encodePayload:thePayload withSecret:theSecret algorithm:[[JWTAlgorithmHS512 alloc] init]];
}

+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret algorithm:(id<JWTAlgorithm>)theAlgorithm;
{
    NSDictionary *header = @{@"type": @"JWT", @"alg": theAlgorithm.name};
    NSString *segments = [self segmentsFromHeader:header payload:thePayload];
    return [[theAlgorithm encodePayload:segments withSecret:theSecret] base64EncodedString];
}

+ (NSString *)segmentsFromHeader:(NSDictionary *)theHeader payload:(NSDictionary *)thePayload;
{
    NSString *headerSegment = [self encodeSegment:theHeader];
    NSString *payloadSegment = [self encodeSegment:thePayload];
    return [@[headerSegment, payloadSegment] componentsJoinedByString:@"."];
}

+ (NSString *)encodeSegment:(id)theSegment;
{
    NSError *error;
    NSString *encodedSegment = [[NSJSONSerialization dataWithJSONObject:theSegment options:0 error:&error] base64EncodedString];
    
    NSAssert(!error, @"Could not encode segment: %@", [error localizedDescription]);
    
    return encodedSegment;
}

@end
