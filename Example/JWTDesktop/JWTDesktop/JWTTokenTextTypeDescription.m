//
//  JWTTokenTextTypeDescription.m
//  JWTDesktop
//
//  Created by Lobanov Dmitry on 25.09.16.
//  Copyright © 2016 JWT. All rights reserved.
//

#import "JWTTokenTextTypeDescription.h"

@interface JWTTokenTextTypeAppearanceAttributes ()
@property (copy, nonatomic, readwrite) NSString *part;
@end

@implementation JWTTokenTextTypeAppearanceAttributes
- (instancetype)initWithColor:(NSColor *)color font:(NSFont *)font {
    if (self = [super init]) {
        self.color = color;
        self.font = font;
    }
    return self;
}
@end

@interface JWTTokenTextTypeDescription ()
@property (strong, nonatomic, readwrite) NSDictionary *textColors;
@end
@implementation JWTTokenTextTypeDescription

- (NSColor *)colorForType:(JWTTokenTextType)type {
    switch (type) {
        case JWTTokenTextTypeDefault: return [NSColor blackColor];
        case JWTTokenTextTypeHeader: return [NSColor redColor];
        case JWTTokenTextTypePayload: return [NSColor magentaColor];
        case JWTTokenTextTypeSignature: return [NSColor colorWithRed:0 green:185/255.0f blue:241/255.0f alpha:1.0f];
        case JWTTokenTextTypeDot: return [NSColor blackColor];
        default: return nil;
    }
}

- (NSFont *)font {
    return [NSFont boldSystemFontOfSize:22];
}

+ (NSArray <NSNumber *>*)typicalSchemeComponents {
    return @[
             @(JWTTokenTextTypeHeader),
             @(JWTTokenTextTypeDot),
             @(JWTTokenTextTypePayload),
             @(JWTTokenTextTypeDot),
             @(JWTTokenTextTypeSignature)
             ];
}
@end

@implementation JWTTokenTextTypeSerialization

- (NSString *)textPartFromTexts:(NSArray *)texts type:(JWTTokenTextType)type {
    NSString *result = nil;
    switch (type) {
        case JWTTokenTextTypeHeader: {
            return [NSArrayExtension extendedArray:texts objectAtIndex:0];
        }
        case JWTTokenTextTypePayload: {
            return [NSArrayExtension extendedArray:texts objectAtIndex:1];
        }
        case JWTTokenTextTypeSignature: {
            if (texts.count > 2) {
                return [[texts subarrayWithRange:NSMakeRange(2, texts.count - 2)] componentsJoinedByString:@"."];
            }
            return nil;
        }            
        case JWTTokenTextTypeDot: return @".";
        
        default: return nil;
    }
    return result;
}
@end

@interface JWTTokenTextTypeAppearance ()
@property (strong, nonatomic, readwrite) JWTTokenTextTypeSerialization *serialization;
@property (strong, nonatomic, readwrite) JWTTokenTextTypeDescription *tokenTypeDescription;
@end

@implementation JWTTokenTextTypeAppearance

- (instancetype)init {
    if (self = [super init]) {
        self.serialization = [JWTTokenTextTypeSerialization new];
        self.tokenTypeDescription = [JWTTokenTextTypeDescription new];
    }
    return self;
}

- (NSArray<JWTTokenTextTypeAppearanceAttributes *> *)attributesForText:(NSString *)text {
    __auto_type texts = [text componentsSeparatedByString:@"."];
    
    __auto_type result = [NSMutableArray array];
    
    for (NSNumber *component in JWTTokenTextTypeDescription.typicalSchemeComponents) {
        __auto_type type = (JWTTokenTextType)component.integerValue;

        __auto_type object = [self.serialization textPartFromTexts:texts type:type];
        if (object) {
            __auto_type color = [self.tokenTypeDescription colorForType:type];
            __auto_type font = self.tokenTypeDescription.font;

            __auto_type component = [[JWTTokenTextTypeAppearanceAttributes alloc] initWithColor:color font:font];
            component.part = object;

            [result addObject:component];
        }
    }
    
    return [result copy];
}

- (NSAttributedString *)attributedStringForText:(NSString *)text {
    __auto_type string = [NSMutableAttributedString new];
    __auto_type attributes = [self attributesForText:text];
    
    for (JWTTokenTextTypeAppearanceAttributes *attribute in attributes) {
        __auto_type attributes = @{
                                   NSForegroundColorAttributeName : attribute.color,
                                   NSFontAttributeName : attribute.font
                                   };

        __auto_type component = [[NSAttributedString alloc] initWithString:attribute.part attributes:attributes];
        [string appendAttributedString:component];
    }
    return [string copy];
}
@end
