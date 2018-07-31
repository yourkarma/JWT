//
//  JWTCryptoSecurity+Extraction.m
//  JWT
//
//  Created by Dmitry on 7/31/18.
//  Copyright © 2018 JWTIO. All rights reserved.
//

#import "JWTCryptoSecurity+Extraction.h"

@implementation JWTCryptoSecurityComponent
- (instancetype)initWithContent:(NSString *)content type:(NSString *)type {
    if (self = [super init]) {
        self.content = content;
        self.type = type;
    }
    return self;
}
@end

@interface JWTCryptoSecurityComponents ()
@property (copy, nonatomic, readwrite) NSArray <JWTCryptoSecurityComponent *>*components;
@end

@interface JWTCryptoSecurityComponents (Extraction)
+ (NSString *)determineTypeByPemHeaderType:(NSString *)headerType;
+ (NSRegularExpression *)pemEntryRegularExpression;
+ (JWTCryptoSecurityComponent *)componentFromTextResult:(NSTextCheckingResult *)textResult inContent:(NSString *)content;
+ (NSArray *)parsedComponentsInContent:(NSString *)content;
@end

@implementation JWTCryptoSecurityComponents (Extraction)
+ (NSString *)determineTypeByPemHeaderType:(NSString *)headerType {
    if ([headerType rangeOfString:@"CERTIFICATE" options:NSCaseInsensitiveSearch]) {
        return self.Certificate;
    }
    if ([headerType rangeOfString:@"PUBLIC" options:NSCaseInsensitiveSearch]) {
        return self.PublicKey;
    }
    if ([headerType rangeOfString:@"PRIVATE" options:NSCaseInsensitiveSearch]) {
        return self.PrivateKey;
    }
}

+ (NSRegularExpression *)pemEntryRegularExpression {
    __auto_type expression = [[NSRegularExpression alloc] initWithPattern:@"-----BEGIN(?<Begin>[\\w\\s])+-----(?<Content>.+?)-----END(?<End>[\\w\\s])+-----" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
}
+ (JWTCryptoSecurityComponent *)componentFromTextResult:(NSTextCheckingResult *)textResult inContent:(NSString *)content {
    __auto_type beginRange = [textResult rangeWithName:@"Begin"];
    __auto_type contentRange = [textResult rangeWithName:@"Content"];
    // cleanup string.
    __auto_type beginString = [content substringWithRange:beginRange];
    __auto_type contentString = [content substringWithRange:contentRange];
    __auto_type resultType = [self determineTypeByPemHeaderType:beginString];
    __auto_type resultContent = [contentString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}
+ (NSArray *)parsedComponentsInContent:(NSString *)content {
    __auto_type expression = [self pemEntryRegularExpression];
    __auto_type results = [expression matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    __auto_type components = (NSArray <JWTCryptoSecurityComponent *>*)@[];
    for (NSTextCheckingResult *result in results) {
        components = [components arrayByAddingObjectsFromArray:[self componentFromTextResult:result inContent:content]];
    }
    return components;
}
@end

@implementation JWTCryptoSecurityComponents
+ (NSString *)Certificate { return NSStringFromSelector(_cmd); }
+ (NSString *)PrivateKey { return NSStringFromSelector(_cmd); }
+ (NSString *)PublicKey { return NSStringFromSelector(_cmd); }
+ (NSArray *)components:(NSArray *)components ofType:(NSString *)type {
    return [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", type]];
}
@end

@implementation JWTCryptoSecurity (Extraction)
+ (NSArray *)componentsFromFile:(NSURL *)url {
    NSError *error = nil;
    __auto_type content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    return [self componentsFromFileContent:content];
}
+ (NSArray *)componentsFromFileContent:(NSString *)content {
    [JWTCryptoSecurityComponents parsedComponentsInContent:content];
}
@end
