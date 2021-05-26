//
//  JWTClaimsSerializerBaseTests.m
//  Tests
//
//  Created by Dmitry Lobanov on 24.05.2021.
//

#import <XCTest/XCTest.h>
#import <JWT/JWT.h>

@interface JWTClaimsSerializerBaseTests : XCTestCase
@property (strong, nonatomic, readwrite) JWTClaimsSetDSLBase *deserialized;
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
    
//    __auto_type accessor = [[JWTClaimsProviderBase alloc] init];
//    __auto_type serializer = [[JWTClaimsSetSerializerBase alloc] init];
//    serializer.claimsProvider = [[JWTClaimsProviderBase alloc] init];
    
    __auto_type claimsProvider = [[JWTClaimsProviderBase alloc] init];
    __auto_type claimsSetProvider = [[JWTClaimsSetBase alloc] init];
    __auto_type claimsSet = [[JWTClaimsSetDSLBase alloc] init];
    claimsSet.claimsProvider = claimsProvider;
    claimsSet.claimsSetProvider = claimsSetProvider
    ;
    self.deserialized = ({
        
        claimsSet.issuer = @"Facebook";
        claimsSet.subject = @"Token";
        claimsSet.audience = @"https://jwt.io";
        claimsSet.expirationDate = [NSDate dateWithTimeIntervalSince1970:self.expirationDateTimestamp];
        claimsSet.notBeforeDate = [NSDate dateWithTimeIntervalSince1970:self.notBeforeDateTimestamp];
        claimsSet.issuedAt = [NSDate dateWithTimeIntervalSince1970:self.issuedAtTimestamp];
        claimsSet.identifier = @"thisisunique";
        claimsSet.type = @"test";
        claimsSet.scope = @"https://www.googleapis.com/auth/devstorage.read_write";
        claimsSet;
    });
    
    __auto_type serializer = [[JWTClaimsSetSerializerBase alloc] init];
    serializer.claimsProvider = claimsProvider;
    serializer.claimsSetProvider = claimsSetProvider;
    self.serialized = ({
        __auto_type serialized = [serializer dictionaryFromClaimsSet:self.deserialized.claimsSetProvider];
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
    [self testDictionary:self.serialized hasValue:self.deserialized.issuer forKey:@"iss" name:@"issuer"];
    [self testDictionary:self.serialized hasValue:self.deserialized.subject forKey:@"sub" name:@"subject"];
    [self testDictionary:self.serialized hasValue:self.deserialized.audience forKey:@"aud" name:@"audience"];
    [self testDictionary:self.serialized hasValue:@(self.expirationDateTimestamp) forKey:@"exp" name:@"expirationDate"];
    [self testDictionary:self.serialized hasValue:@(self.notBeforeDateTimestamp) forKey:@"nbf" name:@"notBeforeDate"];
    [self testDictionary:self.serialized hasValue:@(self.issuedAtTimestamp) forKey:@"iat" name:@"issuedAtDate"];
    [self testDictionary:self.serialized hasValue:self.deserialized.identifier forKey:@"jti" name:@"identifier(jti)"];
    [self testDictionary:self.serialized hasValue:self.deserialized.type forKey:@"typ" name:@"type"];
    [self testDictionary:self.serialized hasValue:self.deserialized.scope forKey:@"scope" name:@"scope"];
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
    __auto_type claimsSetProvider = [[JWTClaimsSetBase alloc] init];
    __auto_type serializer = [[JWTClaimsSetSerializerBase alloc] init];
    serializer.claimsProvider = claimsProvider;
    serializer.claimsSetProvider = claimsSetProvider;
    
    __auto_type result = [serializer claimsSetFromDictionary:self.serialized];
    self.deserialized = [[JWTClaimsSetDSLBase alloc] init];
    self.deserialized.claimsProvider = claimsProvider;
    self.deserialized.claimsSetProvider = result;
}
- (void)testDeserializeProperty:(id)property comparedToValue:(id)value name:(NSString *)name {
    __auto_type propertyKey = name;
    __auto_type activityName = [NSString stringWithFormat:@"deserializes the %@ property", propertyKey];
    [XCTContext runActivityNamed:activityName block:^(id<XCTActivity> _Nonnull activity) {
        XCTAssertEqualObjects(property, value);
    }];
}
- (void)test {
    [self testDeserializeProperty:self.deserialized.issuer comparedToValue:[self.serialized objectForKey:@"iss"] name:@"iss"];
    [self testDeserializeProperty:self.deserialized.subject comparedToValue:[self.serialized objectForKey:@"sub"] name:@"sub"];
    [self testDeserializeProperty:self.deserialized.audience comparedToValue:[self.serialized objectForKey:@"aud"] name:@"aud"];
    [self testDeserializeProperty:self.deserialized.expirationDate comparedToValue:[NSDate dateWithTimeIntervalSince1970:[[self.serialized objectForKey:@"exp"] doubleValue]] name:@"exp"];
    [self testDeserializeProperty:self.deserialized.notBeforeDate comparedToValue:[NSDate dateWithTimeIntervalSince1970:[[self.serialized objectForKey:@"nbf"] doubleValue]] name:@"nbf"];
    [self testDeserializeProperty:self.deserialized.issuedAt comparedToValue:[NSDate dateWithTimeIntervalSince1970:[[self.serialized objectForKey:@"iat"] doubleValue]] name:@"iat"];
    [self testDeserializeProperty:self.deserialized.identifier comparedToValue:[self.serialized objectForKey:@"jti"] name:@"jti"];
    [self testDeserializeProperty:self.deserialized.type comparedToValue:[self.serialized objectForKey:@"typ"] name:@"typ"];
    [self testDeserializeProperty:self.deserialized.scope comparedToValue:[self.serialized objectForKey:@"scope"] name:@"scope"];
}
@end
