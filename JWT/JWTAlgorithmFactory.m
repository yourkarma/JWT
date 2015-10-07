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

@implementation JWTAlgorithmFactory

+ (id<JWTAlgorithm>)algorithmByName:(NSString *)name {
    id<JWTAlgorithm> algorithm = nil;
    
    NSString *algName = [name copy];
    
    if ([[[JWTAlgorithmHS256 new] name] isEqualToString:algName]) {
        algorithm = [JWTAlgorithmHS256 new];
    }
    
    if ([[[JWTAlgorithmHS512 new] name] isEqualToString:algName]) {
        algorithm = [JWTAlgorithmHS512 new];
    }
    
    return algorithm;
}

@end
