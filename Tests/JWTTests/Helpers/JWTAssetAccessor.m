//
//  JWTAssetAccessor.m
//  Tests
//
//  Created by Dmitry Lobanov on 05.01.2022.
//

#import "JWTAssetAccessor.h"

@implementation JWTAssetAccessor (FolderAccess)
- (NSString *)stringFromFileWithName:(NSString *)name {
    __auto_type data = [self dataFromFileWithName:name];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSData *)dataFromFileWithName:(NSString *)name {
    __auto_type path = [self.folder stringByAppendingPathComponent:name];
    __auto_type asset = [[NSDataAsset alloc] initWithName:path bundle:[NSBundle bundleForClass:self.class]];
    __auto_type data = asset.data;
    return data;
}
@end

@implementation JWTAssetAccessor (Getters)
- (NSString *)privateKeyBase64 {
    return [self stringFromFileWithName:@"private.pem"];
}
- (NSString *)publicKeyBase64 {
    return [self stringFromFileWithName:@"public.pem"];
}
- (NSString *)certificateBase64 {
    return [self stringFromFileWithName:@"certificate.cer"];
}
- (NSData *)p12Data {
    return [self dataFromFileWithName:@"private.p12"];
}
- (NSString *)p12Password {
    return [self stringFromFileWithName:@"p12_password.txt"];
}
@end

@implementation JWTAssetAccessor
- (instancetype)initWithFolder:(NSString *)folder {
    if (self = [super init]) {
        self.folder = folder;
        // check that data exists!
        if (!self.check) {
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithAlgorithmType:(NSString *)type shaSize:(NSNumber *)size {
    return [self initWithFolder:[type stringByAppendingPathComponent:size.description]];
}

+ (NSArray *)typeAndSizeFromAlgorithmName:(NSString *)name {
    if (name.length < 3) {
        return nil;
    }
    __auto_type type = [name substringToIndex:2];
    __auto_type size = [name substringFromIndex:2];
    if (type == nil || size == nil) {
        return nil;
    }
    return @[type, size];
}

- (instancetype)initWithAlgorithName:(NSString *)name {
    // split name into type and size.
    // just lowercase everything.
    return [self initWithFolder:name.lowercaseString];
}
@end

@implementation JWTAssetAccessor (Validation)
- (instancetype)checked {
    return self.check ? self : nil;
}
- (BOOL)check {
    return self.privateKeyBase64 != nil;
}
@end
