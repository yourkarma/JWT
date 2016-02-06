//
//  NSData+JWT.h
//  JWT
//
//  Created by Lobanov Dmitry on 07.10.15.
//  Copyright © 2015 Karma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (JWT)

@property (nonatomic, readonly) NSString *base64UrlEncodedString;

@end
