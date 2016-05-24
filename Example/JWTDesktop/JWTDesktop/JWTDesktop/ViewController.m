//
//  ViewController.m
//  JWTDesktop
//
//  Created by Lobanov Dmitry on 23.05.16.
//  Copyright © 2016 JWT. All rights reserved.
//

#import "ViewController.h"
#import <JWT/JWT.h>
#import <JWT/JWTAlgorithmFactory.h>
typedef NS_ENUM(NSInteger, SignatureValidationType) {
    SignatureValidationTypeUnknown,
    SignatureValidationTypeValid,
    SignatureValidationTypeInvalid
};

typedef NS_ENUM(NSInteger, TokenTextType) {
    TokenTextTypeDefault, // dot text color
    TokenTextTypeHeader,
    TokenTextTypePayload,
    TokenTextTypeSignature
};

@interface ViewController() <NSTextViewDelegate>
@property (weak) IBOutlet NSTextField *algorithmLabel;
@property (weak) IBOutlet NSPopUpButton *algorithmPopUpButton;
@property (unsafe_unretained) IBOutlet NSTextView *encodedTextView;
@property (unsafe_unretained) IBOutlet NSTextView *decodedTextView;

@property (weak) IBOutlet NSTextField *signatureStatusLabel;

// Data
@property (nonatomic, readwrite) NSDictionary *signatureDecorations;
@property (assign, nonatomic, readwrite) SignatureValidationType signatureValidation;
@property (nonatomic, readwrite) NSDictionary *textColors;
@end


@implementation ViewController

#pragma mark - Supply JWT Methods
- (NSString *)chosenAlgorithmName {
    return [self.algorithmPopUpButton selectedItem].title;
}

- (NSString *)chosenSecret {
    return @"secret";
}

- (NSDictionary *)JWTFromToken:(NSString *)token verifySignature:(BOOL)signature {
    NSLog(@"JWT ENCODED TOKEN: %@", token);
    NSString *algorithmName = [self chosenAlgorithmName];
    NSLog(@"JWT Algorithm NAME: %@", algorithmName);
    NSString *secret = [self chosenSecret];
    
    JWTBuilder *builder = [JWTBuilder decodeMessage:token].secret(secret).algorithmName(algorithmName).options(@(signature));
    NSDictionary *decoded = builder.decode;
    NSLog(@"JWT ERROR: %@", builder.jwtError);
    NSLog(@"JWT DICTIONARY: %@", decoded);
    return decoded;
}

#pragma mark - Data
- (NSArray *)availableAlgorithms {
    return [JWTAlgorithmFactory algorithms];
}

- (NSArray *)availableAlgorithmsNames {
    return [[self availableAlgorithms] valueForKey:@"name"];
}

- (NSDictionary *)signatureDecorations {
    if (!_signatureDecorations) {
        _signatureDecorations = @{
            @(SignatureValidationTypeUnknown) : @{@"stringValue" : @"Signature Unknown", @"textColor" : [NSColor darkGrayColor]},
            @(SignatureValidationTypeValid) : @{@"stringValue" : @"Signature Valid", @"textColor" : [NSColor cyanColor]},
            @(SignatureValidationTypeInvalid) : @{@"stringValue" : @"Signature Invalid", @"textColor" : [NSColor redColor]}
        };
    }
    return _signatureDecorations;
}

- (NSColor *)signatureColorForValidation:(SignatureValidationType)validation {
    NSDictionary *defaultValue = [self signatureDecorations][@(SignatureValidationTypeUnknown)];
    return [([self signatureDecorations][@(validation)] ?: defaultValue) valueForKey:@"textColor"];
}

- (NSString *)signatureTitleForValidation:(SignatureValidationType)validation {
    NSDictionary *defaultValue = [self signatureDecorations][@(SignatureValidationTypeUnknown)];
    return [([self signatureDecorations][@(validation)] ?: defaultValue) valueForKey:@"stringValue"];
}

- (NSDictionary *)tokenTextColors {
    if (!_textColors) {
        _textColors = @{
                        @(TokenTextTypeDefault) : [NSColor blackColor],
                        @(TokenTextTypeHeader) : [NSColor redColor],
                        @(TokenTextTypePayload) : [NSColor magentaColor],
                        @(TokenTextTypeSignature) : [NSColor cyanColor]
        };
    }
    return _textColors;
}

- (NSColor *)tokenTextColorForType:(TokenTextType)type {
    NSColor *defaultValue = [self tokenTextColors][@(TokenTextTypeDefault)];
    return [self tokenTextColors][@(type)] ?: defaultValue;
}

#pragma mark - Setup
- (void)setupTop {
    // top label.
    self.algorithmLabel.stringValue = @"Algorithm";
    
    // pop up button.
    [self.algorithmPopUpButton removeAllItems];
    [self.algorithmPopUpButton addItemsWithTitles:[self availableAlgorithmsNames]];
}

- (void)setupBottom {
    self.signatureStatusLabel.alignment       = NSTextAlignmentCenter;
    self.signatureStatusLabel.textColor       = [NSColor whiteColor];
    self.signatureStatusLabel.drawsBackground = YES;
    self.signatureValidation = SignatureValidationTypeUnknown;
}

- (void)setupEncodingDecodingViews {
    self.encodedTextView.delegate = self;
    self.decodedTextView.delegate = self;
}

- (void)setupDecorations {
    [self setupTop];
    [self setupBottom];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDecorations];
    [self setupEncodingDecodingViews];
    // Do any additional setup after loading the view.
}

//- (void)setRepresentedObject:(id)representedObject {
//    [super setRepresentedObject:representedObject];
//
//    // Update the view, if already loaded.
//}

#pragma mark - General Helpers
- (id)extendedArray:(NSArray *)array objectAtIndex:(NSInteger)index {
    if (array.count) {
        return index >= array.count ? nil : [array objectAtIndex:index];
    }
    return nil;
}

- (NSAttributedString *)array:(NSArray *)parts componentsJoinedByAttributedString:(NSAttributedString *)string{
    
    NSMutableAttributedString *result = [[self extendedArray:parts objectAtIndex:0] mutableCopy];
    
    for (NSInteger index = 1; index < parts.count; ++index) {
        NSAttributedString *part = parts[index];
        [result appendAttributedString:string];
        [result appendAttributedString:part];
    }
    
    return result;
}

#pragma mark - Signature Customization
- (void)setSignatureValidation:(SignatureValidationType)signatureValidation {
    self.signatureStatusLabel.backgroundColor = [self signatureColorForValidation:signatureValidation];
    self.signatureStatusLabel.stringValue     = [self signatureTitleForValidation:signatureValidation];
    _signatureValidation = signatureValidation;
}

- (void)signatureReactOnVerifiedToken:(BOOL)verified {
    SignatureValidationType type = verified ? SignatureValidationTypeValid : SignatureValidationTypeInvalid;
    self.signatureValidation = type;
}

#pragma mark - Encoding Customization
- (NSString *)textPartFromTexts:(NSArray *)texts withType:(TokenTextType)type {
    NSString *result = nil;
    switch (type) {
        case TokenTextTypeHeader: {
            result = (NSString *)[self extendedArray:texts objectAtIndex:0];
            break;
        }
        case TokenTextTypePayload: {
            result = (NSString *)[self extendedArray:texts objectAtIndex:1];
            break;
        }
        case TokenTextTypeSignature: {
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

- (NSDictionary *)encodedTextViewAttributesForTokenTextType:(TokenTextType)type {
    NSMutableDictionary *attributes = [[self encodedTextViewDefaultTextAttributes] mutableCopy];
    attributes[NSForegroundColorAttributeName] = [self tokenTextColorForType:type];
    return [attributes copy];
}

- (NSDictionary *)encodedTextViewDefaultTextAttributes {
    return @{
             NSFontAttributeName : [NSFont boldSystemFontOfSize:22],
             };
}

- (NSAttributedString *)encodedTextViewAttributedTextStringForEncodingText:(NSString *)text {
    NSArray *texts = [text componentsSeparatedByString:@"."];
    // next step, determine text color!
    // add missing dots.
    // restore them like this:
    // color text if you can
    
    NSArray *parts = @[];
    for (TokenTextType part = TokenTextTypeHeader; part <= TokenTextTypeSignature; ++part) {
        id currentPart = [self textPartFromTexts:texts withType:part];
        if (currentPart) {
            // colorize
            NSDictionary *options = [self encodedTextViewAttributesForTokenTextType:part];
            NSAttributedString *currentPartAttributedString = [[NSAttributedString alloc] initWithString:currentPart attributes:options];
            parts = [parts arrayByAddingObject:currentPartAttributedString];
        }
    }
    
    NSDictionary *options = [self encodedTextViewAttributesForTokenTextType:TokenTextTypeDefault];
    
    NSAttributedString *dot = [[NSAttributedString alloc] initWithString:@"." attributes:options];
    NSAttributedString *result = [self array:parts componentsJoinedByAttributedString:dot];
    return result;
}

#pragma mark - Decoding Customization
- (NSString *)stringFromDecodedJWTToken:(NSDictionary *)jwt {
    NSError *error = nil;
    NSData *data = nil;
    NSString *resultString = nil;
    
    if (jwt) {
        data = [NSJSONSerialization dataWithJSONObject:jwt options:NSJSONWritingPrettyPrinted error:&error];
    }
    
    if (data && !error) {
        resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return resultString ?: @"";
}

#pragma mark - EncodedTextView / <NSTextViewDelegate>

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    
    if (textView == self.encodedTextView) {
        NSTextStorage * textStore = [textView textStorage];
        [textStore replaceCharactersInRange:affectedCharRange withString:replacementString];
        [textStore replaceCharactersInRange:NSMakeRange(0, textStore.string.length) withAttributedString:[self encodedTextViewAttributedTextStringForEncodingText:textView.string]];
    // react on changes.
    // recompute jwt of this token.
    // draw jwt
        NSRange range = NSMakeRange(0, self.decodedTextView.string.length);
        NSString *string = [self stringFromDecodedJWTToken:[self JWTFromToken:textStore.string verifySignature:NO]];
        [self signatureReactOnVerifiedToken:[self JWTFromToken:textStore.string verifySignature:YES]!=nil];
        [self.decodedTextView replaceCharactersInRange:range withString:string];
        return NO;
    }
    return NO;
}

@end
