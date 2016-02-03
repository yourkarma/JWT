//
//  NSData+JWT.m
//  JWT
//
//  Created by Lobanov Dmitry on 07.10.15.
//  Copyright © 2015 Karma. All rights reserved.
//

#import <Base64/MF_Base64Additions.h>

#import "NSData+JWT.h"
#import "NSString+JWT.h"

@implementation NSData (JWT)

-(NSString *)base64UrlEncodedString {
    return [NSString base64UrlEncodedStringFromBase64String:[self base64String]];
}

@end
