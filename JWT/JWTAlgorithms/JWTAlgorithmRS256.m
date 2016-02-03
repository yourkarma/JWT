//
//  JWTAlgorithmRS256.m
//  JWT
//
//  Created by Lobanov Dmitry on 17.11.15.
//  Copyright © 2015 Karma. All rights reserved.
//

#import "JWTAlgorithmRS256.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation JWTAlgorithmRS256

- (NSString *)name {
  return @"RS256";
}

- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret {
  return nil;
}

@end
