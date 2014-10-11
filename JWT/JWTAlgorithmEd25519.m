//
//  JWTAlgorithmEd25519.m
//  JWT
//
//  Created by Chris Ziogas on 09-10-2014.
//

#import "JWTAlgorithmEd25519.h"

#import "MF_Base64Additions+JWT.h"

@implementation JWTAlgorithmEd25519

- (NSString *)name;
{
    return @"Ed25519";
}

- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret withHeader:(NSDictionary *)theHeader;
{
    NSParameterAssert([theHeader valueForKey:@"kid"] != nil);

    NSString *secret = [theSecret stringFromBase64SafeString];
    
    NSData *seed = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSRange seedRange = {0, [NACLSigningKeyPair seedLength]};
    seed = [seed subdataWithRange:seedRange];
    
    NACLSigningKeyPair *signingKeyPair = [[NACLSigningKeyPair alloc] initWithSeed:seed];

    NSData *signedData;
    signedData = [theString signedDataUsingPrivateKey:signingKeyPair.privateKey error:nil];

    return signedData;
}

@end