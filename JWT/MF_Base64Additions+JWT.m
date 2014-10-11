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

-(NSString *)stringFromBase64SafeString
{
    NSString *base64SafeString = self;

    base64SafeString = [base64SafeString stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    base64SafeString = [base64SafeString stringByReplacingOccurrencesOfString:@"_" withString:@"/"];

    switch (base64SafeString.length % 4) {     // Pad with trailing '='s
        case 0: break; // No pad chars in this case
        case 2: base64SafeString = [base64SafeString stringByAppendingString:@"=="]; break; // Two pad chars
        case 3: base64SafeString = [base64SafeString stringByAppendingString:@"="]; break; // One pad char
        default: NSLog(@"Illegal base64url string!");
    }
    
    NSData *utf8encoding = [MF_Base64Codec dataFromBase64String:base64SafeString];
    return [[NSString alloc] initWithData:utf8encoding encoding:NSUTF8StringEncoding];
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