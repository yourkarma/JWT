//
//  JWTAlgorithmNone.m
//  JWT
//
//  Created by Lobanov Dmitry on 16.10.15.
//  Copyright © 2015 Karma. All rights reserved.
//

#import "JWTAlgorithmNone.h"

@implementation JWTAlgorithmNone

- (NSString *)name {
    return @"none";
}

- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret {
    return [NSData data];
}

@end
