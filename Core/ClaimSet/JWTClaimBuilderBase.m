//
//  JWTClaimBuilderBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimBuilderBase.h"
#import "JWTClaimBase.h"

@implementation JWTClaimBuilderBase

- (nonnull id<JWTClaimProtocol>)claimWithName:(nonnull NSString *)name value:(nonnull NSObject *)value {
    __auto_type claim = [self.accessor claimByName:name];
    return [claim copyWithValue:value];
}

@end
