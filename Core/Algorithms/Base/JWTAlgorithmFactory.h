//
//  JWTAlgorithmFactory.h
//  JWT
//
//  Created by Lobanov Dmitry on 07.10.15.
//  Copyright © 2015 Karma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JWT/JWTAlgorithm.h>


@interface JWTAlgorithmHolder : NSObject <JWTAlgorithm>
@property (strong, nonatomic, readwrite) id <JWTAlgorithm> algorithm;
- (instancetype)initWithAlgorithm:(id<JWTAlgorithm>)algorithm;

// For backward compatibilty
- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret;
- (BOOL)verifySignedInput:(NSString *)input withSignature:(NSString *)signature verificationKey:(NSString *)verificationKey;
- (NSData *)encodePayloadData:(NSData *)theStringData withSecret:(NSData *)theSecretData;
- (BOOL)verifySignedInput:(NSString *)input withSignature:(NSString *)signature verificationKeyData:(NSData *)verificationKeyData;
@end

@interface JWTAlgorithmFactory : NSObject
@property (nonatomic, readonly) NSArray <id<JWTAlgorithm>> *algorithms;
+ (id<JWTAlgorithm>)algorithmByName:(NSString *)name;
@end
