//
//  JWTBase64Coder.h
//  Pods
//
//  Created by Lobanov Dmitry on 05.10.16.
//
//

#import <Foundation/Foundation.h>

@protocol JWTStringCoderProtocol <NSObject>
- (NSString *)stringWithData:(NSData *)data;
- (NSData *)dataWithString:(NSString *)string;
@end

@interface JWTBase64Coder : NSObject
+ (instancetype)withBase64String;
+ (instancetype)withPlainString;
+ (NSString *)base64UrlEncodedStringWithData:(NSData *)data;
+ (NSData *)dataWithBase64UrlEncodedString:(NSString *)urlEncodedString;
@end

@interface JWTBase64Coder (JWTStringCoderProtocol) <JWTStringCoderProtocol> @end


@interface JWTStringCoderForEncoding : NSObject
@property (assign, nonatomic, readwrite) NSStringEncoding stringEncoding;
+ (instancetype)utf8Encoding;
@end
@interface JWTStringCoderForEncoding (JWTStringCoderProtocol) <JWTStringCoderProtocol> @end
