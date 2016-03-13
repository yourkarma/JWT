//
//  JWTAlgorithm.h
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright (c) 2013 Karma. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JWTAlgorithm <NSObject>

@required

@property (nonatomic, readonly, copy) NSString *name;

/**
 Encodes and encrypts the provided payload using the provided secret key
 @param theString The string to encode
 @param theSecret The secret to use for encryption
 @return An NSData object containing the encrypted payload, or nil if something went wrong.
 */
- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret;

/**
 Verifies the provided signature using the signed input and verification key
 @param input The header and payload encoded string
 @param signature The JWT provided signature
 @param verificationKey The key to use for verifying the signature
 @return YES if the provided signature is valid, NO otherwise
 */
- (BOOL)verifySignedInput:(NSString *)input withSignature:(NSString *)signature verificationKey:(NSString *)verificationKey;

@optional

/**
 Encodes and encrypts the provided payload using the provided secret key
 @param theStringData The data to encode
 @param theSecretData The secret data to use for encryption
 @return An NSData object containing the encrypted payload, or nil if something went wrong.
 */
- (NSData *)encodePayloadData:(NSData *)theStringData withSecret:(NSData *)theSecretData;

/**
 Verifies the provided signature using the signed input and verification key (as data)
 @param input The header and payload encoded string
 @param signature The JWT provided signature
 @param verificationKeyData The key data to use for verifying the signature
 @return YES if the provided signature is valid, NO otherwise
 */
- (BOOL)verifySignedInput:(NSString *)input withSignature:(NSString *)signature verificationKeyData:(NSData *)verificationKeyData;

@end
