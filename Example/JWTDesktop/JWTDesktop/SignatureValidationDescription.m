//
//  SignatureValidationDescription.m
//  JWTDesktop
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWT. All rights reserved.
//

#import "SignatureValidationDescription.h"
#import <Cocoa/Cocoa.h>

@interface SignatureValidationDescription ()
- (NSColor *)colorForSignatureValidation:(SignatureValidationType)signatureValidation;
- (NSString *)titleForSignatureValidation:(SignatureValidationType)signatureValidation;
@end

@implementation SignatureValidationDescription
- (NSColor *)colorForSignatureValidation:(SignatureValidationType)signatureValidation {
    id result = nil;
    switch (signatureValidation) {
        case SignatureValidationTypeUnknown: {
            result = [NSColor darkGrayColor];
            break;
        }
        case SignatureValidationTypeInvalid: {
            result = [NSColor redColor];
            break;
        }
        case SignatureValidationTypeValid: {
            result = [NSColor colorWithRed:0 green:185/255.0f blue:241/255.0f alpha:1.0f];
            break;
        }
            
        default:
            break;
    }
    return result;
}
- (NSString *)titleForSignatureValidation:(SignatureValidationType)signatureValidation {
    id result = nil;
    switch (signatureValidation) {
        case SignatureValidationTypeUnknown: {
            result = @"Signature Unknown";
            break;
        }
        case SignatureValidationTypeInvalid: {
            result = @"Signature Invalid";
            break;
        }
        case SignatureValidationTypeValid: {
            result = @"Signature Valid";
            break;
        }
        default:
            break;
    }
    return result ?: @"Signature Unknown";
}
- (NSColor *)currentColor {
    return [self colorForSignatureValidation:self.signatureValidation];
}
- (NSString *)currentTitle {
    return [self titleForSignatureValidation:self.signatureValidation];
}
@end

