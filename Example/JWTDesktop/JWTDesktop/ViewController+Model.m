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
