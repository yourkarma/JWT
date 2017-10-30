//
//  SignatureValidationDescription.h
//  JWTDesktop
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, SignatureValidationType) {
    SignatureValidationTypeUnknown,
    SignatureValidationTypeValid,
    SignatureValidationTypeInvalid
};

@interface SignatureValidationDescription : NSObject
@property (assign, nonatomic, readwrite) SignatureValidationType signatureValidation;
@property (assign, nonatomic, readonly) NSColor* currentColor;
@property (assign, nonatomic, readonly) NSString* currentTitle;
@end
