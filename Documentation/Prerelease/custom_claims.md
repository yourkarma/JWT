# Custom Claims.

## Intro.

Consider the following problem.
You have an integer interval and you would like to know if untrusted and trusted intervals intersection is empty or not.

If they have intersection and it is not empty, then, we would like to say "yes" to untrusted value.
Otherwise we treat it as malicious and discard it.

In simple example, we may have

```
trustedValue
// 1...5 
untrustedValue
// 2...6
```

They have non-empty intersection which equals to `2...4`.

## Example Data.

We may encode this special claim as two numbers that are separated by comma.
Also let's define a special claim name for our purpose.

Let's name it intersection.

```
{
intersection: "1,5"
}
```

## Exapmle.

We have to define three components for our case.

Define a claim.
Define a serializer.
Define a verifier.

## Define a claim.

```objective-c
/// Define a name of a claim.
@interface JWTClaimsNames (Custom)
@property (copy, nonatomic, readonly, class) NSString *intersectionOfIntervals;
@end

@implementation JWTClaimsNames (Custom)
+ (NSString *)intersectionOfIntervals { return @"intersectionOfIntervals"; }
@end

/// Define a claim.

/// Define a claim
@interface JWTClaimCustomIntersectionOfIntervals : JWTClaimBase
@end

@implementation JWTClaimCustomIntersectionOfIntervals
+ (NSString *)name { return JWTClaimsNames.intersectionOfIntervals; }
@end
```

## Define a serializer.

```objective-c
/// Define a serializer
@interface JWTClaimSerializerForInterval : JWTClaimSerializerBase
@end

@implementation JWTClaimSerializerForInterval

- (NSObject *)deserializedClaimValue:(NSObject *)value forName:(NSString *)name {
    if ([value isKindOfClass:NSString.class]) {
        __auto_type array = [(NSString *)value componentsSeparatedByString:@","];
        __auto_type result = [NSMutableArray array];
        for (NSString *item in array) {
            [result addObject:@(item.integerValue)];
        }
        __auto_type descriptor = [[NSSortDescriptor alloc] initWithKey:@"integerValue" ascending:YES];

        return [result sortedArrayUsingDescriptors:@[descriptor]];
    }
    return value;
}

- (NSObject *)serializedClaimValue:(id<JWTClaimProtocol>)claim {
    __auto_type value = claim.value;
    if ([value isKindOfClass:NSArray.class]) {
        __auto_type descriptor = [[NSSortDescriptor alloc] initWithKey:@"integerValue" ascending:YES];
        __auto_type sortedArray = [(NSArray *)claim.value sortedArrayUsingDescriptors:@[descriptor]];
        return [sortedArray componentsJoinedByString:@","];
    }
    return value;
}

@end
```

## Define a verifier.

```objective-c
/// Define a verifier.
@interface JWTClaimVerifierForIntersection : JWTClaimVerifierBase
@end

@implementation JWTClaimVerifierForIntersection
- (BOOL)verifyValue:(NSObject *)value withTrustedValue:(NSObject *)trustedValue {
    if ([value isKindOfClass:NSArray.class] && [trustedValue isKindOfClass:NSArray.class]) {
        __auto_type lhs = (NSArray *)value;
        __auto_type rhs = (NSArray *)trustedValue;
        
        if (rhs.count != 2) {
            return NO;
        }
        
        if (lhs.count > 2 || lhs.count == 0) {
            return NO;
        }
        
        __auto_type lowerBorder = ((NSNumber *)rhs.firstObject).integerValue;
        __auto_type upperBorder = ((NSNumber *)rhs.lastObject).integerValue;
        
        if (lhs.count == 1) {
            __auto_type checkValue = ((NSNumber *)lhs.firstObject).integerValue;
            return lowerBorder <= checkValue && upperBorder >= checkValue;
        }
        
        if (lhs.count == 2) {
            __auto_type untrustedLowerBorder = ((NSNumber *)lhs.firstObject).integerValue;
            __auto_type untrustedUpperBorder = ((NSNumber *)lhs.lastObject).integerValue;
            return (untrustedLowerBorder >= lowerBorder && untrustedLowerBorder <= upperBorder) || (untrustedUpperBorder >= lowerBorder && untrustedUpperBorder <= upperBorder);
        }
    }
    return NO;
}
@end
```

## Add DSL if needed.

```objective-c
@interface JWTClaimsSetDSLBase (CustomDSL)
@property (copy, nonatomic, readwrite) NSArray *intersection;
@end

@implementation JWTClaimsSetDSLBase (CustomDSL)
- (NSArray *)intersection {
    return (NSArray *)[self dslValueForName:JWTClaimsNames.intersectionOfIntervals];
}
- (void)setIntersection:(NSArray *)intersection {
    [self dslSetValue:intersection forName:JWTClaimsNames.intersectionOfIntervals];
}
@end

@interface JWTClaimVariations (CustomDSL)
+ (id<JWTClaimProtocol>)intersectionOfIntervals;
@end

@implementation JWTClaimVariations (CustomDSL)
+ (id<JWTClaimProtocol>)intersectionOfIntervals {
    return [JWTClaimCustomIntersectionOfArrays new];
}
@end

@interface JWTClaimSerializerVariations (CustomDSL)
+ (id<JWTClaimSerializerProtocol>)interval;
@end

@implementation JWTClaimSerializerVariations (CustomDSL)
+ (id<JWTClaimSerializerProtocol>)interval {
    return [JWTClaimSerializerForArray new];
}
@end

@interface JWTClaimVerifierVariations (CustomDSL)
+ (id<JWTClaimVerifierProtocol>)intersection;
@end

@implementation JWTClaimVerifierVariations (CustomDSL)
+ (id<JWTClaimVerifierProtocol>)intersection {
    return [JWTClaimVerifierForIntersection new];
}
@end
```

## Put everything together.
```objective-c
- (void)test {
    /// Setup ClaimsSetCoordinator
    __auto_type claim = JWTClaimVariations.intersectionOfIntervals;
    __auto_type claimSerializer = JWTClaimSerializerVariations.interval;
    __auto_type claimVerifier = JWTClaimVerifierVariations.intersection;

    id<JWTClaimsSetCoordinatorProtocol> claimsSetCoordinator = [JWTClaimsSetCoordinatorBase new];
    [claimsSetCoordinator registerClaim:claim serializer:claimSerializer verifier:claimVerifier forClaimName:JWTClaimsNames.intersectionOfIntervals];

    __auto_type deserialized = ({
        claimsSetCoordinator.configureClaimsSet(^JWTClaimsSetDSLBase *(JWTClaimsSetDSLBase *claimsSetDSL) {
            claimsSetDSL.intersection = @[@(2), @(5)];
            return claimsSetDSL;
        });
        self.claimsSetCoordinator.claimsSetStorage;
    });
    
    __auto_type serialized = ({
        __auto_type dictionary = [self.claimsSetCoordinator.claimsSetSerializer dictionaryFromClaimsSet:deserialized];
        dictionary;
    });
    
    __auto_type result = @{
        JWTClaimsNames.intersectionOfIntervals : @"2,5"
    };
    XCTAssertEqual(serialized.count, 1);
    XCTAssertEqualObjects(serialized, result);
}
```

## Use with Decoding and encoding

```objective-c
- (void)testEncodingAndDecodingViaCoordinator {
    id<JWTClaimsSetCoordinatorProtocol> claimsSetCoordinator = [JWTClaimsSetCoordinatorBase new];
    __auto_type claimsSetDSL = claimsSetCoordinator.dslDesrciption;
    // fill it
    claimsSetDSL.issuer = @"Facebook";
    claimsSetDSL.subject = @"Token";
    claimsSetDSL.audience = @"https://jwt.io";
    
    claimsSetCoordinator.claimsSetStorage = claimsSetDSL.claimsSetStorage;
    // encode it
    __auto_type secret = @"secret";
    __auto_type algorithmName = @"HS384";
    __auto_type headers = @{@"custom":@"value"};

    id<JWTAlgorithmDataHolderProtocol>holder = [JWTAlgorithmHSFamilyDataHolder new].algorithmName(algorithmName).secret(secret);

    JWTCodingResultType *result = [JWTEncodingBuilder encodeClaimsSetWithCoordinator:claimsSetCoordinator].headers(headers).addHolder(holder).result;

    NSString *encodedToken = result.successResult.encoded;
    if (result.successResult) {
        // handle encoded result
        NSLog(@"encoded result: %@", result.successResult.encoded);
    }
    else {
        // handle error
        NSLog(@"encode failed, error: %@", result.errorResult.error);
    }

    // decode it
    // you can set any property that you want, all properties are optional
    __auto_type trustedClaimsSet = claimsSetDSL.claimsSetStorage;

    NSNumber *options = @(JWTCodingDecodingOptionsNone);
    NSString *yourJwt = encodedToken; // from previous example
    JWTCodingResultType *decodedResult = [JWTDecodingBuilder decodeMessage:yourJwt].claimsSetCoordinator(claimsSetCoordinator).addHolder(holder).options(options).and.result;

    if (decodedResult.successResult) {
        // handle decoded result
        NSLog(@"decoded result: %@", decodedResult.successResult.headerAndPayloadDictionary);
        NSLog(@"headers: %@", decodedResult.successResult.headers);
        NSLog(@"payload: %@", decodedResult.successResult.payload);
        NSLog(@"trustedClaimsSet: %@", [claimsSetCoordinator.claimsSetSerializer dictionaryFromClaimsSet:trustedClaimsSet]);
        NSLog(@"decodedClaimsSet: %@", [claimsSetCoordinator.claimsSetSerializer dictionaryFromClaimsSet:decodedResult.successResult.claimsSetStorage]);
    }
    else {
        // handle error
        NSLog(@"decode failed, error: %@", decodedResult.errorResult.error);
    }

}
```