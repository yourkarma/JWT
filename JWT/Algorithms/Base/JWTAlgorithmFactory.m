//
//  JWTAlgorithmFactory.m
//  JWT
//
//  Created by Lobanov Dmitry on 07.10.15.
//  Copyright © 2015 Karma. All rights reserved.
//

#import "JWTAlgorithmFactory.h"
#import "JWTAlgorithmHS256.h"
#import "JWTAlgorithmHS384.h"
#import "JWTAlgorithmHS512.h"
#import <TargetConditionals.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import "JWTAlgorithmRS256.h"
#endif

#import "JWTAlgorithmNone.h"

@implementation JWTAlgorithmFactory

+ (NSArray *)algorithms {
    return @[
            [JWTAlgorithmNone new],
            [JWTAlgorithmHS256 new],
            [JWTAlgorithmHS384 new],
            [JWTAlgorithmHS512 new],
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
            [JWTAlgorithmRS256 new]
#endif
            ];

}

+ (id<JWTAlgorithm>)algorithmByName:(NSString *)name {
    id<JWTAlgorithm> algorithm = nil;
    
    NSString *algName = [name copy];
    
    NSUInteger index = [[self algorithms] indexOfObjectPassingTest:^BOOL(id<JWTAlgorithm> obj, NSUInteger idx, BOOL *stop) {
        // lowercase comparison
        return [obj.name.lowercaseString isEqualToString:algName.lowercaseString];
    }];
    
    if (index != NSNotFound) {
        algorithm = [self algorithms][index];
    }
    
    return algorithm;
}

@end