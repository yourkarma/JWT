//
//  JWTClaimSerializerVariations.h
//  JWT
//
//  Created by Dmitry Lobanov on 30.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JWT/JWTClaimSerializerBase.h>
NS_ASSUME_NONNULL_BEGIN

@interface JWTClaimSerializerVariations : NSObject

/// Discussion
/// @return JWTClaimSerializerBaseConcreteDateAndTimestamp
///
+ (id<JWTClaimSerializerProtocol>)dateAndTimestampTransform;

/// Discussion
/// @return JWTClaimSerializerBase
///
+ (id<JWTClaimSerializerProtocol>)identityTransform;
@end

/// Discussion
/// This serializer converts NSDate to a json value via timeIntervalSince1970.
///
/// Conversion
///
/// JSON Timestamp
/// Claim NSDate
///
/// Encoding and Decoding
///     Decode JSON -> Claim `dateWithTimeIntervalSince1970`
///     Encode Claim -> JSON `timeIntervalSince1970`
///
/// Examples
///
/// JSON
/// {
/// ... "time": 12362387432,
/// }
///
/// Date
/// NSDate *date = [NSDate dateWithTimeIntervalSince1970:12362387432];
///
@interface JWTClaimSerializerBaseConcreteDateAndTimestamp : JWTClaimSerializerBase
@end

NS_ASSUME_NONNULL_END
