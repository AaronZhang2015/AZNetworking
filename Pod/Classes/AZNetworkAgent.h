//
//  AZNetworkAgent.h
//  AZNetworking
//
//  Created by ZhangMing on 11/24/15.
//  Copyright © 2015 Aaron Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZBaseRequest.h"
@class AZURLResponse;

typedef void(^AZCallback)(AZURLResponse *response);

@interface AZNetworkAgent : NSObject

+ (instancetype)sharedInstance;

- (NSNumber *)addRequest:(AZBaseRequest<AZRequest> *)request;


@end
