//
//  JWTClaimSerializerBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 30.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import "JWTClaimSerializerBase.h"

@implementation JWTClaimSerializerBase

- (nonnull NSObject *)deserializedClaimValue:(nonnull NSObject *)value forName:(nonnull NSString *)name {
    return value;
}

- (nonnull NSObject *)serializedClaimValue:(nonnull id<JWTClaimProtocol>)claim {
    return claim.value;
}

@end
