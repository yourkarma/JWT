//
//  JWTTokenTextTypeDescription.m
//  JWTDesktop
//
//  Created by Lobanov Dmitry on 25.09.16.
//  Copyright © 2016 JWT. All rights reserved.
//

#import "JWTTokenTextTypeDescription.h"

@interface JWTTokenTextTypeDescription ()
@property (strong, nonatomic, readwrite) NSDictionary *textColors;
@end
@implementation JWTTokenTextTypeDescription

- (NSDictionary *)tokenTextColors {
    if (!_textColors) {
        _textColors = @{
                        @(JWTTokenTextTypeDefault) : [NSColor blackColor],
                        @(JWTTokenTextTypeHeader) : [NSColor redColor],
                        @(JWTTokenTextTypePayload) : [NSColor magentaColor],
                        @(JWTTokenTextTypeSignature) : [NSColor colorWithRed:0 green:185/255.0f blue:241/255.0f alpha:1.0f]
                        };
    }
    return _textColors;
}

- (NSColor *)tokenTextColorForType:(JWTTokenTextType)type {
    NSColor *defaultValue = [self tokenTextColors][@(JWTTokenTextTypeDefault)];
    return [self tokenTextColors][@(type)] ?: defaultValue;
}

- (NSDictionary *)encodedTextDefaultAttributes {
    return @{
             NSFontAttributeName : [NSFont boldSystemFontOfSize:22],
             };
}

- (NSDictionary *)encodedTextAttributesForType:(JWTTokenTextType)type {
    NSMutableDictionary *attributes = [[self encodedTextDefaultAttributes] mutableCopy];
    attributes[NSForegroundColorAttributeName] = [self tokenTextColorForType:type];
    return [attributes copy];
}
@end

@implementation JWTTokenTextTypeSerialization

- (NSString *)textPartFromTexts:(NSArray *)texts type:(JWTTokenTextType)type {
    NSString *result = nil;
    switch (type) {
        case JWTTokenTextTypeHeader: {
            result = (NSString *)[NSArrayExtension extendedArray:texts objectAtIndex:0];
            break;
        }
        case JWTTokenTextTypePayload: {
            result = (NSString *)[NSArrayExtension extendedArray:texts objectAtIndex:1];
            break;
        }
        case JWTTokenTextTypeSignature: {
            if (texts.count > 2) {
                result = (NSString *)[[texts subarrayWithRange:NSMakeRange(2, texts.count - 2)] componentsJoinedByString:@"."];
                break;
            }
            break;
        }
        default: break;
    }
    return result;
}

- (NSString *)stringFromDecodedToken:(NSDictionary *)token {
    NSError *error = nil;
    NSData *data = nil;
    NSString *resultString = nil;
    
    if (token) {
        data = [NSJSONSerialization dataWithJSONObject:token options:NSJSONWritingPrettyPrinted error:&error];
    }
    
    if (data && !error) {
        resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return resultString ?: @"";
}
@end

@implementation JWTTokenTextTypeAppearance
- (NSAttributedString *)array:(NSArray *)parts componentsJoinedByAttributedString:(NSAttributedString *)string {
    
    NSMutableAttributedString *result = [[NSArrayExtension extendedArray:parts objectAtIndex:0] mutableCopy];
    
    for (NSInteger index = 1; index < parts.count; ++index) {
        NSAttributedString *part = parts[index];
        [result appendAttributedString:string];
        [result appendAttributedString:part];
    }
    
    return result;
}

- (NSAttributedString *)encodedAttributedTextForText:(NSString *)text serialization:(JWTTokenTextTypeSerialization *)serialization tokenDescription:(JWTTokenTextTypeDescription *)tokenDescription {
    NSArray *texts = [text componentsSeparatedByString:@"."];
    // next step, determine text color!
    // add missing dots.
    // restore them like this:
    // color text if you can
    
    NSArray *parts = @[];
    for (JWTTokenTextType part = JWTTokenTextTypeHeader; part <= JWTTokenTextTypeSignature; ++part) {
        id currentPart = [serialization textPartFromTexts:texts type:part];
        if (currentPart) {
            // colorize
            NSDictionary *options = [tokenDescription encodedTextAttributesForType:part];
            NSAttributedString *currentPartAttributedString = [[NSAttributedString alloc] initWithString:currentPart attributes:options];
            parts = [parts arrayByAddingObject:currentPartAttributedString];
        }
    }
    
    NSDictionary *options = [tokenDescription encodedTextAttributesForType:JWTTokenTextTypeDefault];
    
    NSAttributedString *dot = [[NSAttributedString alloc] initWithString:@"." attributes:options];
    NSAttributedString *result = [self array:parts componentsJoinedByAttributedString:dot];
    return result;
}
@end
