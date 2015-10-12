//
//  NSData+JWT.m
//  JWT
//
//  Created by Lobanov Dmitry on 07.10.15.
//  Copyright © 2015 Karma. All rights reserved.
//

#import "NSData+JWT.h"
#import "NSString+JWT.h"
#import <MF_Base64Additions.h>

@implementation NSData (JWT)

-(NSString *)base64UrlEncodedString {
    return [NSString base64UrlEncodedStringFromBase64String:[self base64String]];
}

@end
