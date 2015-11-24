//
//  AZService.h
//  AZNetworking
//
//  Created by ZhangMing on 11/24/15.
//  Copyright © 2015 Aaron Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AZService <NSObject>

@property (nonatomic, assign, readonly) BOOL isOnline;

@property (nonatomic, copy, readonly) NSString *offlineBaseURL;
@property (nonatomic, copy, readonly) NSString *onlineBaseURL;

@property (nonatomic, copy, readonly) NSString *offlineAPIVersion;
@property (nonatomic, copy, readonly) NSString *onlineAPIVersion;

@property (nonatomic, copy, readonly) NSString *offlinePublicKey;
@property (nonatomic, copy, readonly) NSString *onlinePublicKey;

@property (nonatomic, copy, readonly) NSString *offlinePrivateKey;
@property (nonatomic, copy, readonly) NSString *onlinePrivateKey;

@end

@interface AZService : NSObject

@property (nonatomic, copy) NSString *publicKey;
@property (nonatomic, copy) NSString *privateKey;
@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, copy) NSString *apiVersion;

@property (nonatomic, weak) id<AZService> child;

@end
