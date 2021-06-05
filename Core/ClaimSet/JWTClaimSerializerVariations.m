//
//  JWTClaimSerializerVariations.m
//  JWT
//
//  Created by Dmitry Lobanov on 30.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import "JWTClaimSerializerVariations.h"

@implementation JWTClaimSerializerVariations
+ (id<JWTClaimSerializerProtocol>)dateAndTimestampTransform {
    return [JWTClaimSerializerBaseConcreteDateAndTimestamp new];
}
+ (id<JWTClaimSerializerProtocol>)identityTransform {
    return [JWTClaimSerializerBase new];
}
@end

@implementation JWTClaimSerializerBaseConcreteDateAndTimestamp
- (NSObject *)deserializedClaimValue:(NSObject *)value forName:(NSString *)name {
    if ([value isKindOfClass:NSNumber.class]) {
        return [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)value doubleValue]];
    }
    return value;
}
- (NSObject *)serializedClaimValue:(id<JWTClaimProtocol>)claim {
    __auto_type value = claim.value;
    if ([value isKindOfClass:NSDate.class]) {
        return @([(NSDate *)value timeIntervalSince1970]);
    }
    return value;
}
@end
