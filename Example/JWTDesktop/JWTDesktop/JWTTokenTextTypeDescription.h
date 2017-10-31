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
    JWTTokenTextTypeSignature
};

@interface JWTTokenTextTypeDescription: NSObject
- (NSColor *)tokenTextColorForType:(JWTTokenTextType)type;
- (NSDictionary *)encodedTextAttributesForType:(JWTTokenTextType)type;
@end

@interface JWTTokenTextTypeSerialization: NSObject
- (NSString *)textPartFromTexts:(NSArray *)texts type:(JWTTokenTextType)type;
- (NSString *)stringFromDecodedToken:(NSDictionary *)token;
@end

@interface JWTTokenTextTypeAppearance: NSObject
- (NSAttributedString *)encodedAttributedTextForText:(NSString *)text serialization:(JWTTokenTextTypeSerialization *)serialization tokenDescription:(JWTTokenTextTypeDescription *)tokenDescription;
@end
