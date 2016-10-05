//
//  JWTBase64Coder.m
//  Pods
//
//  Created by Lobanov Dmitry on 05.10.16.
//
//

#import "JWTBase64Coder.h"

#import <Base64/MF_Base64Additions.h>

@implementation JWTBase64Coder
+ (NSString *)base64UrlEncodedStringWithData:(NSData *)data {
    return [data base64UrlEncodedString];
}

+ (NSData *)dataWithBase64UrlEncodedString:(NSString *)urlEncodedString {
    return [NSData dataWithBase64UrlEncodedString:urlEncodedString];
}

@end
