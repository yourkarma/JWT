//
//  Extends MF_Base64Additions <https://github.com/ekscrypto/Base64>
//
//  MF_Base64Additions+JWT.h
//  Base64 without padding
//  see https://tools.ietf.org/html/draft-ietf-jose-json-web-signature-31#appendix-C for more details
//
//  Created by Chris Ziogas on 09-10-2014.

#import <Foundation/Foundation.h>

@interface NSString (JWT)
-(NSString *)base64SafeString;
-(NSString *)stringFromBase64SafeString;
@end

@interface NSData (JWT)
-(NSString *)base64SafeString;
@end
