//
//  JWTAlgorithmEd25519.m
//  JWT
//
//  Created by Chris Ziogas on 09-10-2014.
//

#import "JWTAlgorithmEd25519.h"

#import "MF_Base64Additions+JWT.h"
#import "MF_Base64Additions.h"

@implementation JWTAlgorithmEd25519

@synthesize headers;

- (NSString *)name;
{
    return @"Ed25519";
}

- (id)init
{
    // generate the SigningKeyPair
    self.signingKeyPair = [NACLSigningKeyPair keyPair];
    
    // add publicKey in base64Safe format in the JWT headers as "kid"
    NSString *publicKeyBase64Safe = [self.signingKeyPair.publicKey.data base64SafeString];
    self.headers = [NSMutableDictionary
                    dictionaryWithObjects:@[publicKeyBase64Safe]
                    forKeys:@[@"kid"]];
    
    return self;
}

- (id)initWithSecret:(NSString *)theSecret;
{
    // prepare the seed for generating the SigningKeyPair
    NSData *seed = [[NSData alloc] initWithBase64EncodedString: theSecret options: NSDataBase64DecodingIgnoreUnknownCharacters];
    
    // generate the SigningKeyPair
    self.signingKeyPair = [[NACLSigningKeyPair alloc] initWithSeed:seed];
    
    // add publicKey in base64Safe format in the JWT headers as "kid"
    NSString *publicKeyBase64Safe = [self.signingKeyPair.publicKey.data base64SafeString];
    self.headers = [NSMutableDictionary
                    dictionaryWithObjects:@[publicKeyBase64Safe]
                    forKeys:@[@"kid"]];
    
    return self;
}

- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret;
{
    NSData *signedData;
    signedData = [theString signedDataUsingPrivateKey:self.signingKeyPair.privateKey error:nil];

    // get the first 64bytes where the signature is
    NSData *signature = [signedData subdataWithRange:NSMakeRange(0, 64)];
    
    return signature;
}

@end