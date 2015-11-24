//
//  AZNetworkConfig.h
//  AZNetworking
//
//  Created by ZhangMing on 11/24/15.
//  Copyright © 2015 Aaron Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZService.h"

@interface AZNetworkConfig : NSObject

@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;
@property (nonatomic, assign) BOOL useSignature;

+ (instancetype)sharedInstance;

- (void)registerService:(Class)serviceClassName withKey:(NSString *)serviceName;
- (AZService<AZService> *)serviceWithIdentifier:(NSString *)identifier;

@end
