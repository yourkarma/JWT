//
//  JWT.h
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright (c) 2013 Karma. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JWTAlgorithm.h"
#import "JWTAlgorithmEd25519.h"
#import "JWTClaimsSet.h"

@interface JWT : NSObject

//@property (nonatomic, readwrite, copy) NSMutableDictionary *header;
//@property (nonatomic, readwrite, copy) NSDictionary *payload;

+ (NSString *)encodeClaimsSet:(JWTClaimsSet *)theClaimsSet withSecret:(NSString *)theSecret;
+ (NSString *)encodeClaimsSet:(JWTClaimsSet *)theClaimsSet withSecret:(NSString *)theSecret withAlgorithm:(id<JWTAlgorithm>)theAlgorithm;
+ (NSString *)encodeClaimsSet:(JWTClaimsSet *)theClaimsSet withSecret:(NSString *)theSecret withAlgorithm:(id<JWTAlgorithm>)theAlgorithm withExtraHeader:(NSDictionary *)theExtraHeader;


+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret;
+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret withAlgorithm:(id<JWTAlgorithm>)theAlgorithm;
+ (NSString *)encodePayload:(NSDictionary *)thePayload withSecret:(NSString *)theSecret withAlgorithm:(id<JWTAlgorithm>)theAlgorithm withExtraHeader:(NSDictionary *)theExtraHeader;

@end