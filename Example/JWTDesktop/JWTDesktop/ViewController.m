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
#import <JWT/JWTAlgorithmNone.h>
#import <Masonry/Masonry.h>
#import "JWTTokenTextTypeDescription.h"

#import "JWTDecriptedViewController.h"
typedef NS_ENUM(NSInteger, SignatureValidationType) {
    SignatureValidationTypeUnknown,
    SignatureValidationTypeValid,
    SignatureValidationTypeInvalid
};

@interface ViewController() <NSTextViewDelegate, NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource>
@property (weak) IBOutlet NSTextField *algorithmLabel;
@property (weak) IBOutlet NSPopUpButton *algorithmPopUpButton;
@property (weak) IBOutlet NSTextField *secretLabel;
@property (weak) IBOutlet NSTextField *secretTextField;
@property (weak) IBOutlet NSButton *secretIsBase64EncodedCheckButton;

@property (unsafe_unretained) IBOutlet NSTextView *encodedTextView;
@property (unsafe_unretained) IBOutlet NSTextView *decodedTextView;
@property (weak) IBOutlet NSTableView *decodedTableView;
@property (weak) IBOutlet NSView * decriptedView;
@property (strong, nonatomic, readwrite) JWTDecriptedViewController *decriptedViewController;
@property (weak) IBOutlet NSTextField *signatureStatusLabel;

// Data
@property (nonatomic, readwrite) NSDictionary *signatureDecorations;
@property (assign, nonatomic, readwrite) SignatureValidationType signatureValidation;

// Tests
@property (nonatomic, readwrite) JWTBuilder *builder;
@property (strong, nonatomic, readwrite) JWTTokenTextTypeDescription *tokenDescription;
@end


@implementation ViewController

#pragma mark - Refresh UI
- (void)refreshUI {
    
    NSTextStorage *textStorage = self.encodedTextView.textStorage;
    NSString *string = textStorage.string;
    NSAttributedString *attributedString = [self encodedTextViewAttributedTextStringForEncodingText:string];
    NSRange range = NSMakeRange(0, string.length);
    
//    [self.encodedTextView insertText:attributedString replacementRange:range];
    [self.encodedTextView.undoManager beginUndoGrouping];
    [textStorage replaceCharactersInRange:range withAttributedString:attributedString];
    [self.encodedTextView.undoManager endUndoGrouping];
    
    NSError *error = nil;
    NSDictionary *result = [self JWTFromToken:string skipSignatureVerification:YES error:&error];
    
    NSString *decodedTokenAsJSON = [self stringFromDecodedJWTToken:result];
    BOOL signatureVerified = [self JWTFromToken:string skipSignatureVerification:NO error:nil]!=nil;
    [self signatureReactOnVerifiedToken:signatureVerified];
    // will be udpated.
    JWTCodingResultType *resultType = error ? [[JWTCodingResultType alloc] initWithErrorResult:[[JWTCodingResultTypeError alloc] initWithError:error]] : [[JWTCodingResultType alloc] initWithSuccessResult:[[JWTCodingResultTypeSuccess alloc] initWithHeaders:result[JWTCodingResultHeaders] withPayload:result[JWTCodingResultPayload]]];
    self.decriptedViewController.resultType = resultType;
    // not used.
    [self.decodedTextView replaceCharactersInRange:range withString:decodedTokenAsJSON];
}

#pragma mark - Helpers
- (JWTTokenTextTypeDescription *)tokenDescription {
    if (!_tokenDescription) {
        _tokenDescription = [JWTTokenTextTypeDescription new];
    }
    return _tokenDescription;
}

#pragma mark - Supply JWT Methods
- (NSString *)chosenAlgorithmName {
    return [self.algorithmPopUpButton selectedItem].title;
}

- (NSData *)chosenSecretData {
    NSString *secret = [self chosenSecret];
    
    BOOL isBase64Encoded = [self isBase64EncodedSecret];
    NSData *result = nil;

    if (isBase64Encoded) {
        result = [[NSData alloc] initWithBase64EncodedString:secret options:0];
    }
    
    return result;
}

- (NSString *)chosenSecret {
    return self.secretTextField.stringValue;
}

- (BOOL)isBase64EncodedSecret {
    return self.secretIsBase64EncodedCheckButton.integerValue == 1;
}

- (NSDictionary *)v3__JWTFromToken:(NSString *)token skipSignatureVerification:(BOOL)skipVerification error:(NSError *__autoreleasing*)error {
    NSLog(@"JWT ENCODED TOKEN: %@", token);
    NSString *algorithmName = [self chosenAlgorithmName];
    NSLog(@"JWT Algorithm NAME: %@", algorithmName);
    NSData *secretData = [self chosenSecretData];
    NSString *secret = [self chosenSecret];
    BOOL isBase64EncodedSecret = [self isBase64EncodedSecret];
    // unchek button if needed
    if (!(isBase64EncodedSecret && secretData)) {
        self.secretIsBase64EncodedCheckButton.state = 0;
    }
    
    NSError *theError = nil;
    id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:algorithmName];
    if (!algorithm) {
        return nil;
    }
    id<JWTAlgorithmDataHolderProtocol> holder = nil;
    if ([algorithm isKindOfClass:[JWTAlgorithmRSBase class]]) {
        NSError *keyError = nil;
        id<JWTCryptoKeyProtocol>key = [[JWTCryptoKeyPublic alloc] initWithPemEncoded:secret parameters:nil error:&keyError];
        theError = keyError;
        if (!theError) {
            holder = [JWTAlgorithmRSFamilyDataHolder new].verifyKey(key).algorithmName(algorithmName).secretData([NSData new]);
        }
    }
    else if ([algorithm isKindOfClass:[JWTAlgorithmHSBase class]]){
        JWTAlgorithmHSFamilyDataHolder *aHolder = [JWTAlgorithmHSFamilyDataHolder new];
        if (isBase64EncodedSecret && secretData) {
            aHolder.secretData(secretData);
        }
        else {
            aHolder.secret(secret);
        }
        holder = aHolder.algorithmName(algorithmName);
    }
    else if ([algorithm isKindOfClass:[JWTAlgorithmNone class]]) {
        holder = [JWTAlgorithmNoneDataHolder new];
    }
    
    if (theError) {
        NSLog(@"JWT internalError: %@", theError);
        if (error) {
            *error = theError;
        }
        return nil;
    }
    
    JWTCodingBuilder *builder = [JWTDecodingBuilder decodeMessage:token].addHolder(holder).options(@(skipVerification));
    JWTCodingResultType *result = builder.result;
    // TODO: Fix
    // signature is not verified well even for JWT.IO example.
    // it happens in case of base64 data corruption. (url encoded vs not url uncoded)
    NSLog(@"JWT ERROR: %@ -> %@", result.errorResult, result.errorResult.error);
    NSLog(@"JWT RESULT: %@ -> %@", result.successResult, result.successResult.headerAndPayloadDictionary);
    return result.successResult.headerAndPayloadDictionary;
}

- (NSDictionary *)v2__JWTFromToken:(NSString *)token skipSignatureVerification:(BOOL)skipVerification error:(NSError *__autoreleasing*)error {
    NSLog(@"JWT ENCODED TOKEN: %@", token);
    NSString *algorithmName = [self chosenAlgorithmName];
    NSLog(@"JWT Algorithm NAME: %@", algorithmName);

    JWTBuilder *builder = [JWTBuilder decodeMessage:token].algorithmName(algorithmName).options(@(skipVerification));
    
    NSData *secretData = [self chosenSecretData];
    NSString *secret = [self chosenSecret];
    BOOL isBase64EncodedSecret = [self isBase64EncodedSecret];
    
    if (![algorithmName isEqualToString:JWTAlgorithmNameNone]) {
        if (isBase64EncodedSecret && secretData) {
            builder.secretData(secretData);
        }
        else {
            self.secretIsBase64EncodedCheckButton.state = 0;
            builder.secret(secret);
        }
    }
    
    NSDictionary *decoded = builder.decode;
    NSLog(@"JWT ERROR: %@", builder.jwtError);
    NSLog(@"JWT DICTIONARY: %@", decoded);
    self.builder = builder;
    return decoded;
}

- (NSDictionary *)JWTFromToken:(NSString *)token skipSignatureVerification:(BOOL)skipVerification error:(NSError *__autoreleasing*)error {
    return [self v3__JWTFromToken:token skipSignatureVerification:skipVerification error:error];
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
            @(SignatureValidationTypeValid) : @{@"stringValue" : @"Signature Valid", @"textColor" : [NSColor colorWithRed:0 green:185/255.0f blue:241/255.0f alpha:1.0f]},
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

#pragma mark - Setup
- (void)setupTop {
    // top label.
    self.algorithmLabel.stringValue = @"Algorithm";
    
    // pop up button.
    [self.algorithmPopUpButton removeAllItems];
    [self.algorithmPopUpButton addItemsWithTitles:[self availableAlgorithmsNames]];
    [self.algorithmPopUpButton setAction:@selector(popUpButtonValueChanged:)];
    [self.algorithmPopUpButton setTarget:self];
    
    // secretLabel
    self.secretLabel.stringValue = @"Secret";
    
    // secretTextField
    self.secretTextField.placeholderString = @"Secret";
    self.secretTextField.delegate = self;
    
    // check button
    self.secretIsBase64EncodedCheckButton.title = @"is Base64Encoded Secret";
    self.secretIsBase64EncodedCheckButton.integerValue = NO;
    [self.secretIsBase64EncodedCheckButton setTarget:self];
    [self.secretIsBase64EncodedCheckButton setAction:@selector(checkBoxState:)];
}

- (void)setupBottom {
    self.signatureStatusLabel.alignment       = NSTextAlignmentCenter;
    self.signatureStatusLabel.textColor       = [NSColor whiteColor];
    self.signatureStatusLabel.drawsBackground = YES;
    self.signatureValidation = SignatureValidationTypeUnknown;
}

- (void)setupEncodingDecodingViews {
    self.encodedTextView.delegate = self;
//    self.decodedTextView.delegate = self;
    self.decodedTableView.delegate = self;
    self.decodedTableView.dataSource = self;
    
    //thanks!
    //http://stackoverflow.com/questions/7545490/how-can-i-have-the-only-column-of-my-nstableview-take-all-the-width-of-the-table
    NSTableView *tableView = self.decodedTableView;
    [tableView  setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    [tableView.tableColumns.firstObject setResizingMask:NSTableColumnAutoresizingMask];
    //AND
    [tableView sizeLastColumnToFit];
}

- (void)setupDecorations {
    [self setupTop];
    [self setupBottom];
}

- (void)setupDecriptedViews {
    NSView *view = self.decriptedView;
    self.decriptedViewController = [JWTDecriptedViewController new];
    [view addSubview:self.decriptedViewController.view];
    // maybe add contstraints.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDecorations];
    [self setupEncodingDecodingViews];
    [self setupDecriptedViews];
    [self defaultDataSetup];
    [self refreshUI];
    // Do any additional setup after loading the view.
}
- (void)defaultDataSetup {
    [self defaultDataSetup__RS256];
}

- (void)defaultDataSetupWithToken:(NSString *)token secret:(NSString *)secret algorithmName:(NSString *)algorithmName {
    if (token == nil || secret == nil || algorithmName == nil) {
        NSLog(@"%@ failed! one of them is nil: token:(%@) secret(%@) algorithmName:(%@)algorithm", NSStringFromSelector(_cmd), token, secret, algorithmName);
        return;
    }
    // token
    [self.encodedTextView insertText:token replacementRange:NSMakeRange(0, token.length)];
    
    // secret
    self.secretTextField.stringValue = secret;
    
    // algorithm
    NSInteger index = [[self availableAlgorithmsNames] indexOfObject:algorithmName];
    [self.algorithmPopUpButton selectItemAtIndex:index];
}

- (void)defaultDataSetup__HS256 {
    NSString *token = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
    NSString *secret = @"secret";
    NSString *algorithmName = JWTAlgorithmNameHS256;
    [self defaultDataSetupWithToken:token secret:secret algorithmName:algorithmName];
}

- (void)defaultDataSetup__RS256 {
    NSString *token = @"eyJraWQiOiJqd3RfdWF0X2tleXMiLCJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI1MDAxIiwiaXNzIjoiQ0xNIiwiZXhwIjoxNTA4MjQ5NTU3LCJqdGkiOiI2MjcyM2E4Yi0zOTZmLTQxYmYtOTljMi02NWRkMzk2MDNiNjQifQ.Cej8RJ6e2HEU27rh_TyHZBoMI1jErmhOfSFY4SRzRoijSP628hM82XxjDX24HsKqIsK1xeeGI1yg1bed4RPhnmDGt4jAY73nqguZ1oqZ2DTcfZ5olxCXyLLaytl2XH7-62M_mFUcGj7I2mwts1DQkHWnFky2i4uJXlksHFkUg2xZoGEjVHo0bxCxgQ5yQiOpxC5VodN5rAPM3A5yMG6EijOp-dvUThjoJ4RFTGKozw_x_Qg6RLGDusNcmLIMbHasTsyZAZle6RFkwO0Sij1k6z6_xssbOl-Q57m7CeYgVHMORdzy4Smkmh-0gzeiLsGbCL4fhgdHydpIFajW-eOXMw";
    NSString *secret = @"-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoPryo3IisfK3a028bwgso/CW5kB84mk6Y7rO76FxJRTWnOAla0Uf0OpIID7go4Qck66yT4/uPpiOQIR0oW0plTekkDP75EG3d/2mtzhiCtELV4F1r9b/InCN5dYYK8USNkKXgjbeVyatdUvCtokz10/ibNZ9qikgKf58qXnn2anGvpE6ded5FOUEukOjr7KSAfD0KDNYWgZcG7HZBxn/3N7ND9D0ATu2vxlJsNGOkH6WL1EmObo/QygBXzuZm5o0N0W15EXpWVbl4Ye7xqPnvc1i2DTKxNUcyhXfDbLw1ee2d9T/WU5895Ko2bQ/O/zPwUSobM3m+fPMW8kp5914kwIDAQAB-----END PUBLIC KEY-----";
    NSString *algorithmName = JWTAlgorithmNameRS256;
    [self defaultDataSetupWithToken:token secret:secret algorithmName:algorithmName];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    NSView *view = self.decriptedView;
    [self.decriptedViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
}

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


#pragma mark - Actions
- (void)popUpButtonValueChanged:(id)sender {
    [self refreshUI];
}

-(IBAction)checkBoxState:(id)sender {
    // Under construction
    [self refreshUI];
}


#pragma marrk - Delegates / <NSTextFieldDelegate>

- (void)controlTextDidChange:(NSNotification *)obj {
    if ([obj.name isEqualToString:NSControlTextDidChangeNotification]) {
        NSTextField *textField = (NSTextField *)obj.object;
        if (textField == self.secretTextField) {
            // refresh UI
            [self refreshUI];
        }
    }
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
- (NSString *)textPartFromTexts:(NSArray *)texts withType:(JWTTokenTextType)type {
    NSString *result = nil;
    switch (type) {
        case JWTTokenTextTypeHeader: {
            result = (NSString *)[self extendedArray:texts objectAtIndex:0];
            break;
        }
        case JWTTokenTextTypePayload: {
            result = (NSString *)[self extendedArray:texts objectAtIndex:1];
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

- (NSDictionary *)encodedTextViewAttributesForTokenTextType:(JWTTokenTextType)type {
    NSMutableDictionary *attributes = [[self encodedTextViewDefaultTextAttributes] mutableCopy];
    attributes[NSForegroundColorAttributeName] = [self.tokenDescription tokenTextColorForType:type];
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
    for (JWTTokenTextType part = JWTTokenTextTypeHeader; part <= JWTTokenTextTypeSignature; ++part) {
        id currentPart = [self textPartFromTexts:texts withType:part];
        if (currentPart) {
            // colorize
            NSDictionary *options = [self encodedTextViewAttributesForTokenTextType:part];
            NSAttributedString *currentPartAttributedString = [[NSAttributedString alloc] initWithString:currentPart attributes:options];
            parts = [parts arrayByAddingObject:currentPartAttributedString];
        }
    }
    
    NSDictionary *options = [self encodedTextViewAttributesForTokenTextType:JWTTokenTextTypeDefault];
    
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

- (void)textDidChange:(NSNotification *)notification {
    [self refreshUI];
}
//- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
//    
//    if (textView == self.encodedTextView) {
////        NSTextStorage *textStore = [textView textStorage];
////        [textStore replaceCharactersInRange:affectedCharRange withString:replacementString];
//        // react on changes.
//        // recompute jwt of this token.
//        [self refreshUI];
//        return YES;
//    }
//    return NO;
//}

#pragma mark - DecodedTableView / <NSTableViewDataSource>

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 4;
}

#pragma mark - DecodedTableView / <NSTableViewDelegate>
- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    return row % 2 == 0;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // choose by row is section or not
    if (row % 2) {
        // section
        NSView *cell = [tableView makeViewWithIdentifier:@"Cell" owner:self];
        ((NSTableCellView *)cell).textField.stringValue = @"AH";
        return cell;
    }
    else {
        NSView *cell = [tableView makeViewWithIdentifier:@"Cell" owner:self];
        ((NSTableCellView *)cell).textField.stringValue = @"OH";
        //    return nil;
        return cell;
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    // calculate height of row.
//    NSView * view = [tableView viewAtColumn:0 row:row makeIfNecessary:NO];
    return 40;
}

@end
