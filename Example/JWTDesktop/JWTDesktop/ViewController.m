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
#import "SignatureValidationDescription.h"
#import "JWTDecriptedViewController.h"
#import "ViewController+Model.h"

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

@property (strong, nonatomic, readwrite) ViewController__Model *model;
@end

// it catches all data from view controller

@interface ViewController (JWTTokenDecoderNecessaryDataObject__Protocol) <JWTTokenDecoderNecessaryDataObject__Protocol>
@end

@implementation ViewController (JWTTokenDecoderNecessaryDataObject__Protocol)
- (NSString *)chosenAlgorithmName {
    return [self.algorithmPopUpButton selectedItem].title;
}

- (NSData *)chosenSecretData {
    NSString *secret = [self chosenSecret];
    
    BOOL isBase64Encoded = [self isBase64EncodedSecret];
    NSData *result = nil;
    
    if (isBase64Encoded) {
        result = [[NSData alloc] initWithBase64EncodedString:secret options:0];
        if (!result) {
            self.secretIsBase64EncodedCheckButton.integerValue = 0;
        }
    }
    
    return result;
}

- (NSString *)chosenSecret {
    return self.secretTextField.stringValue;
}

- (BOOL)isBase64EncodedSecret {
    return self.secretIsBase64EncodedCheckButton.integerValue == 1;
}
@end


@implementation ViewController

#pragma mark - Refresh UI
- (void)refreshUI {
    
    NSTextStorage *textStorage = self.encodedTextView.textStorage;
    NSString *string = textStorage.string;
    NSAttributedString *attributedString = [self.model.tokenAppearance encodedAttributedTextForText:string serialization:self.model.tokenSerialization tokenDescription:self.model.tokenDescription];
    NSRange range = NSMakeRange(0, string.length);
    
//    [self.encodedTextView insertText:attributedString replacementRange:range];
    [self.encodedTextView.undoManager beginUndoGrouping];
    [textStorage replaceCharactersInRange:range withAttributedString:attributedString];
    [self.encodedTextView.undoManager endUndoGrouping];
    
    NSError *error = nil;
    NSDictionary *result = [self.model.decoder decodeToken:string skipSignatureVerification:YES error:&error necessaryDataObject:self];
    
    NSString *decodedTokenAsJSON = [self.model.tokenSerialization stringFromDecodedToken:result];
    BOOL signatureVerified = [self.model.decoder decodeToken:string skipSignatureVerification:NO error:&error necessaryDataObject:self]!=nil;
    [self signatureReactOnVerifiedToken:signatureVerified];
    
    // will be udpated.
    JWTCodingResultType *resultType = error ? [[JWTCodingResultType alloc] initWithErrorResult:[[JWTCodingResultTypeError alloc] initWithError:error]] : [[JWTCodingResultType alloc] initWithSuccessResult:[[JWTCodingResultTypeSuccess alloc] initWithHeaders:result[JWTCodingResultHeaders] withPayload:result[JWTCodingResultPayload]]];
    self.decriptedViewController.resultType = resultType;
    // not used.
    [self.decodedTextView replaceCharactersInRange:range withString:decodedTokenAsJSON];
}

#pragma mark - Signature Customization
- (void)signatureReactOnVerifiedToken:(BOOL)verified {
    SignatureValidationType type = verified ? SignatureValidationTypeValid : SignatureValidationTypeInvalid;
    self.model.signatureValidationDescription.signatureValidation = type;
    self.signatureStatusLabel.textColor = self.model.signatureValidationDescription.currentColor;
    self.signatureStatusLabel.stringValue = self.model.signatureValidationDescription.currentTitle;
}

#pragma mark - Setup
- (void)setupModel {
    self.model = [ViewController__Model new];
}

- (void)setupTop {
    // top label.
    self.algorithmLabel.stringValue = @"Algorithm";
    
    // pop up button.
    [self.algorithmPopUpButton removeAllItems];
    [self.algorithmPopUpButton addItemsWithTitles:self.model.availableAlgorithmsNames];
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
    
    self.model.signatureValidationDescription.signatureValidation = SignatureValidationTypeUnknown;
    self.signatureStatusLabel.textColor = self.model.signatureValidationDescription.currentColor;
    self.signatureStatusLabel.stringValue = self.model.signatureValidationDescription.currentTitle;
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
    [self setupModel];
    [self setupDecorations];
    [self setupEncodingDecodingViews];
    [self setupDecriptedViews];
    [self defaultDataSetup];
    [self refreshUI];
    // Do any additional setup after loading the view.
}
- (void)defaultDataSetup {
    ViewController__DataSeed *dataSeed = [ViewController__DataSeed RS256];
    [self defaultDataSetupWithToken:dataSeed.token secret:dataSeed.secret algorithmName:dataSeed.algorithmName];
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
    NSInteger index = [self.model.availableAlgorithmsNames indexOfObject:algorithmName];
    [self.algorithmPopUpButton selectItemAtIndex:index];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    NSView *view = self.decriptedView;
    [self.decriptedViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
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

#pragma mark - EncodedTextView / <NSTextViewDelegate>

- (void)textDidChange:(NSNotification *)notification {
    [self refreshUI];
}

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
