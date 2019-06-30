//
//  JWTTokenTextTypeDescription.h
//  JWTDesktop
//
//  Created by Lobanov Dmitry on 25.09.16.
//  Copyright © 2016 JWT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "NSArrayExtension.h"

typedef NS_ENUM(NSInteger, JWTTokenTextType) {
    JWTTokenTextTypeDefault, // dot text color
    JWTTokenTextTypeHeader,
    JWTTokenTextTypePayload,
    JWTTokenTextTypeSignature,
    JWTTokenTextTypeDot
};

@interface JWTTokenTextTypeAppearanceAttributes : NSObject
@property (copy, nonatomic, readwrite) NSColor *color;
@property (copy, nonatomic, readwrite) NSFont *font;
@end

@interface JWTTokenTextTypeDescription: NSObject
- (NSColor *)colorForType:(JWTTokenTextType)type;
- (NSFont *)font;
- (NSDictionary *)encodedTextAttributesForType:(JWTTokenTextType)type;
+ (NSArray <NSNumber *>*)typicalSchemeComponents;
@end

@interface JWTTokenTextTypeSerialization: NSObject
- (NSString *)textPartFromTexts:(NSArray *)texts type:(JWTTokenTextType)type;
@end

@interface JWTTokenTextTypeAppearance: NSObject
- (NSArray <JWTTokenTextTypeAppearanceAttributes *>*)attributesForText:(NSString *)text;
- (NSAttributedString *)attributedStringForText:(NSString *)text;
@end
