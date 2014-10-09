//
//  Extends MF_Base64Additions <https://github.com/ekscrypto/Base64>
//
//  MF_Base64Additions+JWT.h
//  Base64 without padding
//  see https://tools.ietf.org/html/draft-ietf-jose-json-web-signature-31#appendix-C for more details
//
//  Created by Chris Ziogas on 09-10-2014.

#import "MF_Base64Additions.h"

@implementation NSString (JWT)
-(NSString *)base64SafeString
{
    NSString *base64String = [self base64String];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"=" withString:@""];

    base64String = [base64String stringByReplacingOccurrencesOfString:@"+" withString:@"-"];  // 62nd char of encoding
    base64String = [base64String stringByReplacingOccurrencesOfString:@"/" withString:@"_"];  // 63rd char of encoding
    
    return base64String;
}
@end

@implementation NSData (JWT)
-(NSString *)base64SafeString
{
    NSString *base64String = [self base64String];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"=" withString:@""];
    
    base64String = [base64String stringByReplacingOccurrencesOfString:@"+" withString:@"-"];  // 62nd char of encoding
    base64String = [base64String stringByReplacingOccurrencesOfString:@"/" withString:@"_"];  // 63rd char of encoding
    
    return base64String;
}
@end