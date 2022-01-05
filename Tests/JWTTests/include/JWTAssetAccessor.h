//
//  JWTAssetAccessor.h
//  Tests
//
//  Created by Dmitry Lobanov on 05.01.2022.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWTAssetAccessor : NSObject
@property (copy, nonatomic, readwrite) NSString *folder;
- (instancetype)initWithFolder:(NSString *)folder;
- (instancetype)initWithAlgorithmType:(NSString *)type shaSize:(NSNumber *)size;
- (instancetype)initWithAlgorithName:(NSString *)name;
@end

@interface JWTAssetAccessor (Validation)
- (instancetype)checked;
- (BOOL)check;
@end

@interface JWTAssetAccessor (FolderAccess)
- (NSString *)stringFromFileWithName:(NSString *)name;
- (NSData *)dataFromFileWithName:(NSString *)name;
@end

@interface JWTAssetAccessor (Getters)
@property (copy, nonatomic, readonly) NSString *privateKeyBase64;
@property (copy, nonatomic, readonly) NSString *publicKeyBase64;
@property (copy, nonatomic, readonly) NSString *certificateBase64;
@property (copy, nonatomic, readonly) NSData *p12Data;
@property (copy, nonatomic, readonly) NSString *p12Password;
@end

NS_ASSUME_NONNULL_END
