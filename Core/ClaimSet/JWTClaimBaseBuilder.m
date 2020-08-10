//
//  JWTClaimBaseBuilder.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimBaseBuilder.h"
#import "JWTClaimBase.h"

@implementation JWTClaimBaseBuilder

- (nonnull id<JWTClaimProtocol>)claimWithName:(nonnull NSString *)name value:(nonnull NSObject *)value {
    __auto_type claim = [self.accessor claimByName:name];
    if ([(NSObject *)claim isKindOfClass:JWTClaimBase.class]) {
        return [(JWTClaimBase *)claim configuredWithValue:value];
    }
    return nil;
}

@end
