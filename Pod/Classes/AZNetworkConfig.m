//
//  AZNetworkConfig.m
//  AZNetworking
//
//  Created by ZhangMing on 11/24/15.
//  Copyright © 2015 Aaron Zhang. All rights reserved.
//

#import "AZNetworkConfig.h"

@interface AZNetworkConfig ()

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;

@end

@implementation AZNetworkConfig

+ (instancetype)sharedInstance
{
    static AZNetworkConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AZNetworkConfig alloc] init];
    });
    return sharedInstance;
}

- (void)registerService:(Class)serviceClassName withKey:(NSString *)serviceName
{
    [self.dispatchTable setValue:serviceClassName forKey:serviceName];
}

- (AZService<AZService> *)serviceWithIdentifier:(NSString *)identifier
{
    Class className = self.dispatchTable[identifier];
    if (!className) {
        NSAssert1(NO, @"%@ service unregistered", identifier);
        return nil;
    }
    
    return [[className alloc] init];
}

#pragma mark - getters
- (NSMutableDictionary *)dispatchTable
{
    if (!_dispatchTable) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

@end
