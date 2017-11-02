//
//  ViewController+Model.m
//  JWTDesktop
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWT. All rights reserved.
//

#import "ViewController+Model.h"
#import <JWT/JWT.h>

@implementation ViewController (Model)

@end

@implementation ViewController__Model
- (JWTTokenTextTypeDescription *)tokenDescription {
    return _tokenDescription ?: (_tokenDescription = [JWTTokenTextTypeDescription new]);
}
- (JWTTokenTextTypeSerialization *)tokenSerialization {
    return _tokenSerialization ?: (_tokenSerialization = [JWTTokenTextTypeSerialization new]);
}
- (JWTTokenTextTypeAppearance *)tokenAppearance {
    return _tokenAppearance ?: (_tokenAppearance = [JWTTokenTextTypeAppearance new]);
}
- (SignatureValidationDescription *)signatureValidationDescription {
    return _signatureValidationDescription ?: (_signatureValidationDescription = [SignatureValidationDescription new]);
}
- (JWTTokenDecoder *)decoder {
    return _decoder ?: (_decoder = [JWTTokenDecoder new]);
}
@end

@implementation ViewController__Model (JWTAlgorithms)
- (NSArray *)availableAlgorithms {
    return [JWTAlgorithmFactory algorithms];
}
- (NSArray *)availableAlgorithmsNames {
    return [[self availableAlgorithms] valueForKey:@"name"];
}
@end

@interface ViewController__DataSeed ()
@property (copy, nonatomic, readwrite) NSString *algorithmName;
@property (copy, nonatomic, readwrite) NSString *secret;
@property (copy, nonatomic, readwrite) NSString *token;
@end

@implementation ViewController__DataSeed
- (instancetype)initWithAlgorithName:(NSString *)algorithmName secret:(NSString *)secret token:(NSString *)token {
    self = [super init];
    if (self) {
        self.algorithmName = algorithmName;
        self.secret = secret;
        self.token = token;
    }
    return self;
}
@end

@implementation ViewController__DataSeed (Create)
+ (instancetype)template {
    NSString *token = @"";
    NSString *secret = @"";
    NSString *algorithmName = @"";
    return [[self alloc] initWithAlgorithName:(NSString *)algorithmName secret:(NSString *)secret token:(NSString *)token];
}
+ (instancetype)RS256 {
    NSString *token = @"eyJraWQiOiJqd3RfdWF0X2tleXMiLCJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI1MDAxIiwiaXNzIjoiQ0xNIiwiZXhwIjoxNTA4MjQ5NTU3LCJqdGkiOiI2MjcyM2E4Yi0zOTZmLTQxYmYtOTljMi02NWRkMzk2MDNiNjQifQ.Cej8RJ6e2HEU27rh_TyHZBoMI1jErmhOfSFY4SRzRoijSP628hM82XxjDX24HsKqIsK1xeeGI1yg1bed4RPhnmDGt4jAY73nqguZ1oqZ2DTcfZ5olxCXyLLaytl2XH7-62M_mFUcGj7I2mwts1DQkHWnFky2i4uJXlksHFkUg2xZoGEjVHo0bxCxgQ5yQiOpxC5VodN5rAPM3A5yMG6EijOp-dvUThjoJ4RFTGKozw_x_Qg6RLGDusNcmLIMbHasTsyZAZle6RFkwO0Sij1k6z6_xssbOl-Q57m7CeYgVHMORdzy4Smkmh-0gzeiLsGbCL4fhgdHydpIFajW-eOXMw";
    NSString *secret = @"-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoPryo3IisfK3a028bwgso/CW5kB84mk6Y7rO76FxJRTWnOAla0Uf0OpIID7go4Qck66yT4/uPpiOQIR0oW0plTekkDP75EG3d/2mtzhiCtELV4F1r9b/InCN5dYYK8USNkKXgjbeVyatdUvCtokz10/ibNZ9qikgKf58qXnn2anGvpE6ded5FOUEukOjr7KSAfD0KDNYWgZcG7HZBxn/3N7ND9D0ATu2vxlJsNGOkH6WL1EmObo/QygBXzuZm5o0N0W15EXpWVbl4Ye7xqPnvc1i2DTKxNUcyhXfDbLw1ee2d9T/WU5895Ko2bQ/O/zPwUSobM3m+fPMW8kp5914kwIDAQAB-----END PUBLIC KEY-----";
    NSString *algorithmName = JWTAlgorithmNameRS256;
    return [[self alloc] initWithAlgorithName:(NSString *)algorithmName secret:(NSString *)secret token:(NSString *)token];
}
+ (instancetype)HS256 {
    NSString *token = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ";
    NSString *secret = @"secret";
    NSString *algorithmName = JWTAlgorithmNameHS256;
    return [[self alloc] initWithAlgorithName:(NSString *)algorithmName secret:(NSString *)secret token:(NSString *)token];
}

+ (instancetype)HS256__WithoutClaimsSet {
    NSString *token = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJvaG9oIjoiMTIzNDU2Nzg5MCIsImhhaGEiOiJKb2huIERvZSIsIm9oaGhoaCI6dHJ1ZX0.5V2Jk3Nnaj1czth5x7ssXgy12K_Oe1Lew1yfgQokpqE";
    NSString *secret = @"secret";
    NSString *algorithmName = JWTAlgorithmNameHS256;
    return [[self alloc] initWithAlgorithName:(NSString *)algorithmName secret:(NSString *)secret token:(NSString *)token];
}
@end
