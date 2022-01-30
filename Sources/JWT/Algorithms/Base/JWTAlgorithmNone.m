//
//  JWTAlgorithmNone.m
//  JWT
//
//  Created by Lobanov Dmitry on 16.10.15.
//  Copyright © 2015 Karma. All rights reserved.
//

#import "JWTAlgorithmNone.h"
NSString *const JWTAlgorithmNameNone = @"none";

@implementation JWTAlgorithmNone

- (NSString *)name {
    return JWTAlgorithmNameNone;
}

- (NSData *)signHash:(NSData *)hash key:(NSData *)key error:(NSError *__autoreleasing *)error {
    return [NSData data];
}

- (BOOL)verifyHash:(NSData *)hash signature:(NSData *)signature key:(NSData *)key error:(NSError *__autoreleasing *)error {
    //if a secret is provided, this isn't the None algorithm
    if (key && key.length > 0) {
        return NO;
    }
    
    //If the signature isn't blank, this isn't the None algorithm
    if (signature && signature.length > 0) {
        return NO;
    }
    
    return YES;
}

@end
