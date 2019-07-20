//
//  JWTDecriptedViewController.m
//  JWTDesktop
//
//  Created by Lobanov Dmitry on 25.09.16.
//  Copyright © 2016 JWT. All rights reserved.
//

#import "JWTDecriptedViewController.h"
#import "JWTDecriptedCollectionViewItem.h"
#import "JWTTokenTextTypeDescription.h"
@interface JWTDecriptedViewController ()
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (copy, nonatomic, readwrite) NSString *collectionViewItemIdentifier;
@property (strong, nonatomic, readwrite) NSArray *cachedResultArray;
@property (strong, nonatomic, readwrite) NSDictionary *cachedErrorDictionary;
@property (assign, nonatomic, readwrite) NSInteger countOfRows;

@property (strong, nonatomic, readwrite) JWTTokenTextTypeDescription *tokenDescription;
@end

@interface JWTDecriptedViewController (NSCollectionViewDelegateFlowLayout)<NSCollectionViewDelegateFlowLayout>
@end

@interface JWTDecriptedViewController (NSCollectionViewDataSource)<NSCollectionViewDataSource>
@end

@implementation JWTDecriptedViewController

- (void)setupUIElements {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.minItemSize = NSZeroSize;
    self.collectionView.maxItemSize = NSZeroSize;
    [self.collectionView registerClass:[JWTDecriptedCollectionViewItem class] forItemWithIdentifier:self.collectionViewItemIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUIElements];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:NSWindowDidResizeNotification object:nil];
}
- (void)reload {
    [self reloadCollectionView];
}
- (void)reloadCollectionView {
    [self.collectionView reloadData];
}

- (NSString *)jsonStringWithObject:(NSDictionary *)object {
    if (object == nil) {
        return @"";
    }
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if (error != nil) {
        return @"";
    }
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string ?: @"";
}

- (void)reloadData {
    self.cachedResultArray = nil;
    self.cachedErrorDictionary = nil;
    if (self.resultType) {
        if (self.resultType.successResult) {
            NSDictionary *result = self.resultType.successResult.headerAndPayloadDictionary;
            NSDictionary *claims = [JWTClaimsSetSerializer dictionaryWithClaimsSet:self.resultType.successResult.claimsSet];
            self.cachedResultArray = @[
                                       @{@"header" : result[JWTCodingResultComponents.Headers] ?: @""},
                                       @{@"payload" : result[JWTCodingResultComponents.Payload] ?: @""},
                                       @{@"claimsSet" : claims ?: @""}
                                       ];
        }
        else {
            NSString *errorDescription = self.resultType.errorResult.error ? self.resultType.errorResult.error.localizedDescription : @"UnknownError! Report about it!";
            self.cachedErrorDictionary = @{
                                           @"error" : errorDescription
                                           };
        }
    }
    else {
        NSDictionary *result = self.builder.decode;
        if (self.builder.jwtError != nil) {
            self.cachedErrorDictionary = @{
                                           @"error" : self.builder.jwtError.localizedDescription
                                           };
        }
        else if (result != nil) {
            self.cachedResultArray =  @[
                                        @{@"header" : result[@"header"] ?: @""},
                                        @{@"payload" : result[@"payload"] ?: @""}
                                        ];
        }
    }
}

- (NSInteger)countOfRows {
    if (self.cachedErrorDictionary) {
        return 1;
    }
    else if (self.cachedResultArray) {
        return self.cachedResultArray.count;
    }
    else {
        return 0;
    }
}

- (NSString *)collectionViewItemIdentifier {
    if (_collectionViewItemIdentifier == nil) {
        _collectionViewItemIdentifier = NSStringFromClass([JWTDecriptedCollectionViewItem class]);
    }
    return _collectionViewItemIdentifier;
}

- (void)setBuilder:(JWTBuilder *)builder {
    if (_builder != builder) {
        _builder = builder;
        [self reloadData];
        [self reloadCollectionView];
    }
}

- (void)setResultType:(JWTCodingResultType *)resultType {
    if (_resultType != resultType) {
        _resultType = resultType;
        [self reloadData];
        [self reloadCollectionView];
    }
}

- (JWTTokenTextTypeDescription *)tokenDescription {
    if (!_tokenDescription) {
        _tokenDescription = [JWTTokenTextTypeDescription new];
    }
    return _tokenDescription;
}

#pragma mark - Collection Helpers.

- (NSString *)textForItemAtIndexPath:(NSIndexPath *)path {
    NSDictionary *itemResult = nil;
    if (self.cachedErrorDictionary != nil) {
        itemResult = self.cachedErrorDictionary;
    }
    else if(self.cachedResultArray != nil) {
        itemResult = self.cachedResultArray[path.item];
    }
    NSString *text = [self jsonStringWithObject:itemResult];
    return text;
}

- (NSColor *)colorWithIndexPath:(NSIndexPath *)path {
    NSColor *color = nil;
    if (self.cachedErrorDictionary) {
        color = [self.tokenDescription colorForType:JWTTokenTextTypeHeader];
    }
    else if (self.cachedResultArray) {
        JWTTokenTextType type = MAX(JWTTokenTextTypeDefault, MIN(path.item + 1, JWTTokenTextTypeSignature));
        color = [self.tokenDescription colorForType:type];
    }
    return color;
}


@end

@implementation JWTDecriptedViewController (NSCollectionViewDelegateFlowLayout)

- (NSSize)sizeWithText:(NSString *)text withWidth:(NSInteger)width {
    return NSZeroSize;
}

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *stringToDisplay = [self textForItemAtIndexPath:indexPath];
    CGFloat width = collectionView.frame.size.width;//[[collectionView enclosingScrollView] bounds].size.width;
    
    NSRect estimatedSize = [stringToDisplay boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{/*NSForegroundColorAttributeName : nil,*/ NSFontAttributeName : JWTDecriptedCollectionViewItem.defaultFont }];
    
    NSInteger height = estimatedSize.size.height;
    
    NSSize size = NSMakeSize(width, height);
    return size;
}

@end

@implementation JWTDecriptedViewController (NSCollectionViewDataSource)
- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = self.countOfRows;
    return count;
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSCollectionViewItem *item = [collectionView makeItemWithIdentifier:self.collectionViewItemIdentifier forIndexPath:indexPath];
    
    NSString *text = [self textForItemAtIndexPath:indexPath];
    JWTDecriptedCollectionViewItem *decriptedItem = (JWTDecriptedCollectionViewItem *)item;
    
    [decriptedItem updateWithText:text];
    [decriptedItem updateWithTextColor:[self colorWithIndexPath:indexPath]];
    return item;
}

@end
