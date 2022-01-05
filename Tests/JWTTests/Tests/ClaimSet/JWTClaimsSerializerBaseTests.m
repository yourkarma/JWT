//
//  JWTClaimsSerializerBaseTests.m
//  Tests
//
//  Created by Dmitry Lobanov on 24.05.2021.
//

@import XCTest;
@import JWT;

@interface JWTClaimsSerializerBaseTests : XCTestCase
@property (strong, nonatomic, readwrite) id<JWTClaimsSetProtocol> deserialized;
@property (copy, nonatomic, readwrite) NSDictionary *serialized;

@property (assign, nonatomic, readwrite) NSTimeInterval expirationDateTimestamp;
@property (assign, nonatomic, readwrite) NSTimeInterval notBeforeDateTimestamp;
@property (assign, nonatomic, readwrite) NSTimeInterval issuedAtTimestamp;
@end

@implementation JWTClaimsSerializerBaseTests @end

@interface JWTClaimsSerializerBaseTests__Serialization : JWTClaimsSerializerBaseTests @end

@implementation JWTClaimsSerializerBaseTests__Serialization
- (void)setUp {
    self.expirationDateTimestamp = 1234567;
    self.notBeforeDateTimestamp = 1234321;
    self.issuedAtTimestamp = 1234333;

    
    __auto_type coordinator = [JWTClaimsSetCoordinatorBase new];
    self.deserialized = ({
        coordinator.configureClaimsSet(^JWTClaimsSetDSLBase * _Nonnull(JWTClaimsSetDSLBase * _Nonnull claimsSetDSL) {
            claimsSetDSL.issuer = @"Facebook";
            claimsSetDSL.subject = @"Token";
            claimsSetDSL.audience = @"https://jwt.io";
            claimsSetDSL.expirationDate = [NSDate dateWithTimeIntervalSince1970:self.expirationDateTimestamp];
            claimsSetDSL.notBeforeDate = [NSDate dateWithTimeIntervalSince1970:self.notBeforeDateTimestamp];
            claimsSetDSL.issuedAt = [NSDate dateWithTimeIntervalSince1970:self.issuedAtTimestamp];
            claimsSetDSL.identifier = @"thisisunique";
            claimsSetDSL.type = @"test";
            claimsSetDSL.scope = @"https://www.googleapis.com/auth/devstorage.read_write";
            return claimsSetDSL;
        });
        coordinator.claimsSetStorage;
    });
    
    __auto_type serializer = coordinator.claimsSetSerializer;
    self.serialized = ({
        __auto_type serialized = [serializer dictionaryFromClaimsSet:self.deserialized];
        serialized;
    });
}
- (void)testHaveEnoughKeys:(NSNumber *)number inDictionary:(NSDictionary *)dictionary {
    [XCTContext runActivityNamed:@"number of serialized values" block:^(id<XCTActivity> _Nonnull activity) {
        XCTAssertEqualObjects(@(dictionary.allValues.count), @(9));
    }];
}
- (void)testDictionary:(NSDictionary *)dictionary hasValue:(id)value forKey:(NSString *)key name:(NSString *)name {
    __auto_type activityName = [NSString stringWithFormat:@"serializes the %@ property", name];
    [XCTContext runActivityNamed:activityName block:^(id<XCTActivity>  _Nonnull activity) {
        XCTAssertEqualObjects([dictionary objectForKey:key], value);
    }];
}
- (void)test {
    [self testHaveEnoughKeys:@(9) inDictionary:self.serialized];
    [self testDictionary:self.serialized hasValue:[self.deserialized claimByName:JWTClaimsNames.issuer].value forKey:JWTClaimsNames.issuer name:@"issuer"];
    [self testDictionary:self.serialized hasValue:[self.deserialized claimByName:JWTClaimsNames.subject].value forKey:JWTClaimsNames.subject name:@"subject"];
    [self testDictionary:self.serialized hasValue:[self.deserialized claimByName:JWTClaimsNames.audience].value forKey:JWTClaimsNames.audience name:@"audience"];
    [self testDictionary:self.serialized hasValue:@(self.expirationDateTimestamp) forKey:JWTClaimsNames.expirationTime name:@"expirationDate"];
    [self testDictionary:self.serialized hasValue:@(self.notBeforeDateTimestamp) forKey:JWTClaimsNames.notBefore name:@"notBeforeDate"];
    [self testDictionary:self.serialized hasValue:@(self.issuedAtTimestamp) forKey:JWTClaimsNames.issuedAt name:@"issuedAtDate"];
    [self testDictionary:self.serialized hasValue:[self.deserialized claimByName:JWTClaimsNames.jwtID].value forKey:JWTClaimsNames.jwtID name:@"identifier(jti)"];
    [self testDictionary:self.serialized hasValue:[self.deserialized claimByName:JWTClaimsNames.type].value forKey:JWTClaimsNames.type name:@"type"];
    [self testDictionary:self.serialized hasValue:[self.deserialized claimByName:JWTClaimsNames.scope].value forKey:JWTClaimsNames.scope name:@"scope"];
}
@end

@interface JWTClaimsSerializerBaseTests__Deserialization : JWTClaimsSerializerBaseTests @end

@implementation JWTClaimsSerializerBaseTests__Deserialization
- (void)setUp {
    self.serialized = @{
                   @"iss": @"Facebook",
                   @"sub": @"Token",
                   @"aud": @"https://jwt.io",
                   @"exp": @(64092211200),
                   @"nbf": @(-62135769600),
                   @"iat": @(1370005175),
                   @"jti": @"thisisunique",
                   @"typ": @"test",
                   @"scope": @"https://www.googleapis.com/auth/devstorage.read_write"
                   };
    __auto_type claimsProvider = [[JWTClaimsProviderBase alloc] init];
    __auto_type claimsSetStorage = [[JWTClaimsSetBase alloc] init];
    __auto_type serializer = [[JWTClaimsSetSerializerBase alloc] init];
    serializer.claimsProvider = claimsProvider;
    serializer.claimsSetStorage = claimsSetStorage;
    
    __auto_type result = [serializer claimsSetFromDictionary:self.serialized];
    self.deserialized = [[[JWTClaimsSetBase alloc] init] copyWithClaims:result.claims];
}
- (void)testDeserializeProperty:(id)property comparedToValue:(id)value name:(NSString *)name {
    __auto_type propertyKey = name;
    __auto_type activityName = [NSString stringWithFormat:@"deserializes the %@ property", propertyKey];
    [XCTContext runActivityNamed:activityName block:^(id<XCTActivity> _Nonnull activity) {
        XCTAssertEqualObjects(property, value);
    }];
}
- (void)test {
    [self testDeserializeProperty:[self.deserialized claimByName:JWTClaimsNames.issuer].value comparedToValue:self.serialized[JWTClaimsNames.issuer] name:JWTClaimsNames.issuer];
    [self testDeserializeProperty:[self.deserialized claimByName:JWTClaimsNames.subject].value comparedToValue:self.serialized[JWTClaimsNames.subject] name:JWTClaimsNames.subject];
    [self testDeserializeProperty:[self.deserialized claimByName:JWTClaimsNames.audience].value comparedToValue:self.serialized[JWTClaimsNames.audience] name:JWTClaimsNames.audience];
    [self testDeserializeProperty:[self.deserialized claimByName:JWTClaimsNames.expirationTime].value comparedToValue:[NSDate dateWithTimeIntervalSince1970:[self.serialized[JWTClaimsNames.expirationTime] doubleValue]] name:JWTClaimsNames.expirationTime];
    [self testDeserializeProperty:[self.deserialized claimByName:JWTClaimsNames.notBefore].value comparedToValue:[NSDate dateWithTimeIntervalSince1970:[self.serialized[JWTClaimsNames.notBefore] doubleValue]] name:JWTClaimsNames.notBefore];
    [self testDeserializeProperty:[self.deserialized claimByName:JWTClaimsNames.issuedAt].value comparedToValue:[NSDate dateWithTimeIntervalSince1970:[self.serialized[JWTClaimsNames.issuedAt] doubleValue]] name:JWTClaimsNames.issuedAt];
    [self testDeserializeProperty:[self.deserialized claimByName:JWTClaimsNames.jwtID].value comparedToValue:self.serialized[JWTClaimsNames.jwtID] name:JWTClaimsNames.jwtID];
    [self testDeserializeProperty:[self.deserialized claimByName:JWTClaimsNames.type].value comparedToValue:self.serialized[JWTClaimsNames.type] name:JWTClaimsNames.type];
    [self testDeserializeProperty:[self.deserialized claimByName:JWTClaimsNames.scope].value comparedToValue:self.serialized[JWTClaimsNames.scope] name:JWTClaimsNames.scope];
}
@end
