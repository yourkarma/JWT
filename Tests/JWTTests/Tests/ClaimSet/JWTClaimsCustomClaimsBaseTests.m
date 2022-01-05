//
//  JWTClaimsCustomClaimsBaseTests.m
//  iOS_Tests
//
//  Created by Dmitry Lobanov on 30.05.2021.
//

@import XCTest;
@import JWT;

/**
 Consider the following claims set.
 
 "intersection": "1, 2" // Actually, it is array
 
 and the rule
 
 "intersection" arrays should have non-empty intersection.

 Let's implement this claim.
 */

/// Define a name of claim
@interface JWTClaimsNames (Custom)
@property (copy, nonatomic, readonly, class) NSString *intersectionOfArrays;
@end

@implementation JWTClaimsNames (Custom)
+ (NSString *)intersectionOfArrays { return @"intersection"; }
@end

/// Define a claim
@interface JWTClaimCustomIntersectionOfArrays : JWTClaimBase
@end

@implementation JWTClaimCustomIntersectionOfArrays
+ (NSString *)name { return JWTClaimsNames.intersectionOfArrays; }
@end

/// Define a serialization
@interface JWTClaimSerializerForArray : JWTClaimSerializerBase
@end

@implementation JWTClaimSerializerForArray

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

/// Define a rule
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

/// Define a dsl
@interface JWTClaimsSetDSLBase (CustomDSL)
@property (copy, nonatomic, readwrite) NSArray *intersection;
@end

@implementation JWTClaimsSetDSLBase (CustomDSL)
- (NSArray *)intersection {
    return (NSArray *)[self dslValueForName:JWTClaimsNames.intersectionOfArrays];
}
- (void)setIntersection:(NSArray *)intersection {
    [self dslSetValue:intersection forName:JWTClaimsNames.intersectionOfArrays];
}
@end

@interface JWTClaimVariations (CustomDSL)
+ (id<JWTClaimProtocol>)intersectionOfArrays;
@end

@implementation JWTClaimVariations (CustomDSL)
+ (id<JWTClaimProtocol>)intersectionOfArrays {
    return [JWTClaimCustomIntersectionOfArrays new];
}
@end

@interface JWTClaimSerializerVariations (CustomDSL)
+ (id<JWTClaimSerializerProtocol>)array;
@end

@implementation JWTClaimSerializerVariations (CustomDSL)
+ (id<JWTClaimSerializerProtocol>)array {
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

@interface JWTClaimsCustomClaimsBaseTests : XCTestCase
@property (strong, nonatomic, readwrite) id<JWTClaimsSetCoordinatorProtocol> claimsSetCoordinator;
@end

@implementation JWTClaimsCustomClaimsBaseTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    __auto_type claim = JWTClaimVariations.intersectionOfArrays;
    __auto_type claimSerializer = JWTClaimSerializerVariations.array;
    __auto_type claimVerifier = JWTClaimVerifierVariations.intersection;
    

    self.claimsSetCoordinator = [JWTClaimsSetCoordinatorBase new];
    [self.claimsSetCoordinator registerClaim:claim serializer:claimSerializer verifier:claimVerifier forClaimName:JWTClaimsNames.intersectionOfArrays];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSerialize {
    __auto_type deserialized = ({
        self.claimsSetCoordinator.configureClaimsSet(^JWTClaimsSetDSLBase * _Nonnull(JWTClaimsSetDSLBase * _Nonnull claimsSetDSL) {
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
        JWTClaimsNames.intersectionOfArrays : @"2,5"
    };
    XCTAssertEqual(serialized.count, 1);
    XCTAssertEqualObjects(serialized, result);
}

- (void)testDeserialize {
    __auto_type given = @{
        JWTClaimsNames.intersectionOfArrays : @"2,5"
    };
    
    __auto_type deserialized = ({
        self.claimsSetCoordinator.claimsSetStorage = [JWTClaimsSetBase new];
        [self.claimsSetCoordinator.claimsSetSerializer claimsSetFromDictionary:given];
    });
    __auto_type result = ({
        __auto_type dsl = self.claimsSetCoordinator.dslDesrciption;
        dsl.intersection = @[@(2), @(5)];
        dsl;
    });
    XCTAssertEqualObjects(result.intersection, [deserialized claimByName:JWTClaimsNames.intersectionOfArrays].value);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

@interface JWTClaimsCustomClaimsDifferentNamesTests : XCTestCase
@property (strong, nonatomic, readwrite) id<JWTClaimsSetCoordinatorProtocol> claimsSetCoordinator;
@property (copy, nonatomic, readwrite) NSString *duplicateClaimName;
@end

@implementation JWTClaimsCustomClaimsDifferentNamesTests

- (void)setUp {
    self.duplicateClaimName = @"duplicateClaimName";
    __auto_type claim = JWTClaimVariations.intersectionOfArrays;
    __auto_type claimSerializer = JWTClaimSerializerVariations.array;
    __auto_type claimVerifier = JWTClaimVerifierVariations.intersection;
    

    self.claimsSetCoordinator = [JWTClaimsSetCoordinatorBase new];
//    [self.claimsSetCoordinator registerClaim:claim serializer:claimSerializer verifier:claimVerifier forClaimName:JWTClaimsNames.intersectionOfArrays];
    [self.claimsSetCoordinator registerClaim:claim serializer:claimSerializer verifier:claimVerifier forClaimName:self.duplicateClaimName];
}

- (void)testSerialize {
    __auto_type deserialized = ({
        self.claimsSetCoordinator.configureClaimsSet(^JWTClaimsSetDSLBase * _Nonnull(JWTClaimsSetDSLBase * _Nonnull claimsSetDSL) {
            [claimsSetDSL dslSetValue:@[@(2), @(5)] forName:self.duplicateClaimName];
            return claimsSetDSL;
        });
        
        self.claimsSetCoordinator.claimsSetStorage;
    });
    
    __auto_type serialized = ({
        __auto_type dictionary = [self.claimsSetCoordinator.claimsSetSerializer dictionaryFromClaimsSet:deserialized];
        dictionary;
    });
    
    __auto_type result = @{
        self.duplicateClaimName : @"2,5"
    };
    XCTAssertEqual(serialized.count, 1);
    XCTAssertEqualObjects(serialized, result);
}

- (void)testDeserialize {
    __auto_type given = @{
        self.duplicateClaimName : @"2,5"
    };
    
    __auto_type deserialized = ({
        self.claimsSetCoordinator.claimsSetStorage = [JWTClaimsSetBase new];
        [self.claimsSetCoordinator.claimsSetSerializer claimsSetFromDictionary:given];
    });
    __auto_type result = ({
        __auto_type dsl = self.claimsSetCoordinator.dslDesrciption;
//        dsl.intersection = @[@(2), @(5)];
        [dsl dslSetValue:@[@(2), @(5)] forName:self.duplicateClaimName];
        dsl;
    });
    XCTAssertNotNil([result dslValueForName:self.duplicateClaimName]);
    XCTAssertEqualObjects([result dslValueForName:self.duplicateClaimName], [deserialized claimByName:self.duplicateClaimName].value);
}


@end
