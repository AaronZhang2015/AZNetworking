//
//  AZService.m
//  AZNetworking
//
//  Created by ZhangMing on 11/24/15.
//  Copyright © 2015 Aaron Zhang. All rights reserved.
//

#import "AZService.h"

@implementation AZService

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(AZService)]) {
            self.child = (id<AZService>)self;
        } else {
            NSAssert(YES, @"AZService class must be conform AZService protocol");
        }
    }
    return self;
}

#pragma mark - getters
- (NSString *)privateKey
{
    return self.child.isOnline ? self.child.onlinePrivateKey : self.child.offlinePrivateKey;
}

- (NSString *)publicKey
{
    return self.child.isOnline ? self.child.onlinePublicKey : self.child.offlinePublicKey;
}

- (NSString *)baseURL
{
    return self.child.isOnline ? self.child.onlineBaseURL : self.child.offlineBaseURL;
}

- (NSString *)apiVersion
{
    return self.child.isOnline ? self.child.onlineAPIVersion : self.child.offlineAPIVersion;
}

@end
