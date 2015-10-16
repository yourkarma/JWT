//
//  JWTAlgorithmFactory.m
//  JWT
//
//  Created by Lobanov Dmitry on 07.10.15.
//  Copyright © 2015 Karma. All rights reserved.
//

#import "JWTAlgorithmFactory.h"
#import "JWTAlgorithmHS256.h"
#import "JWTAlgorithmHS512.h"
#import "JWTAlgorithmNone.h"

@implementation JWTAlgorithmFactory

+ (NSArray *)algorithms {
    return @[
            [JWTAlgorithmNone new],
            [JWTAlgorithmHS256 new],
            [JWTAlgorithmHS512 new]
            ];
}

+ (id<JWTAlgorithm>)algorithmByName:(NSString *)name {
    id<JWTAlgorithm> algorithm = nil;
    
    NSString *algName = [name copy];
    
    NSUInteger index = [[self algorithms] indexOfObjectPassingTest:^BOOL(id<JWTAlgorithm>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // lowercase comparison
        return [obj.name.lowercaseString isEqualToString:algName.lowercaseString];
    }];
    
    if (index != NSNotFound) {
        algorithm = [self algorithms][index];
    }
    
    return algorithm;
}

@end