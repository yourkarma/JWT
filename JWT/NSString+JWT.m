//
//  NSString+JWT.m
//  JWT
//
//  Created by Lobanov Dmitry on 07.10.15.
//  Copyright © 2015 Karma. All rights reserved.
//

#import "NSString+JWT.h"
#import <MF_Base64Additions.h>
@implementation NSString (JWT)

- (NSString *)base64UrlEncodedString {
    
    NSString *string = [self copy];
    NSString *base64String = [string base64String];
    
    return [self.class base64UrlEncodedStringFromBase64String:base64String];
}

+ (NSString *)base64UrlEncodedStringFromBase64String:(NSString *)base64String {
    
    NSString *encodedSegment = [base64String copy];
    encodedSegment = [encodedSegment stringByReplacingOccurrencesOfString:@"=" withString:@""];
    encodedSegment = [encodedSegment stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    encodedSegment = [encodedSegment stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    return encodedSegment;
}

@end
