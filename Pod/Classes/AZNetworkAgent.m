//
//  AZNetworkAgent.m
//  AZNetworking
//
//  Created by ZhangMing on 11/24/15.
//  Copyright © 2015 Aaron Zhang. All rights reserved.
//

#import "AZNetworkAgent.h"
#import "AZNetworkConfig.h"
#import "AZService.h"
#import <AFNetworking/AFNetworking.h>
#import "AFDownloadRequestOperation.h"
#import "NSDictionary+AZNetworkingMethods.h"
#import "AZURLResponse.h"
#import "NSURLRequest+AZNetworkingMethods.h"

@interface AZNetworkAgent ()
@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recordedRequestId;
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;

@end

@implementation AZNetworkAgent

+ (instancetype)sharedInstance
{
    static AZNetworkAgent *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AZNetworkAgent alloc] init];
    });
    return sharedInstance;
}

- (NSNumber *)addRequest:(AZBaseRequest<AZRequest> *)request
{
    AZRequestMethod method = [request requestMethod];
    NSString *url = [self buildRequestURL:request];
    NSDictionary *param = request.requestParams;
    AFConstructingBlock constructingBlock = [request constructingBodyBlock];
    
    if (request.requestSerializerType == AZRequestSerializerTypeHTTP) {
        self.operationManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == AZRequestSerializerTypeJSON) {
        self.operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    if ([request requestTimeoutInterval] > 0) {
        self.operationManager.requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    } else {
        self.operationManager.requestSerializer.timeoutInterval = [AZNetworkConfig sharedInstance].requestTimeoutInterval;
    }
    // if api need server username and password
    NSArray *authorizationHeaderFieldArray = [request requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray) {
        [self.operationManager.requestSerializer setAuthorizationHeaderFieldWithUsername:authorizationHeaderFieldArray.firstObject password:authorizationHeaderFieldArray.lastObject];
    }
    // if api need add custom value to HTTPHeaderField
    NSDictionary *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary) {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [self.operationManager.requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
            } else {
                NSAssert(NO, @"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }
    // if api build custom url request
    NSURLRequest *customURLRequest= [request buildCustomURLRequest];
    if (customURLRequest) {
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:customURLRequest];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self requestDidFinished:operation];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self requestDidFailed:operation error:error];
        }];
        request.operation = operation;
        operation.responseSerializer = self.operationManager.responseSerializer;
        [self.operationManager.operationQueue addOperation:operation];
    } else {
        if (method == AZRequestMethodGet) {
            // 下载操作
            if (request.resumableDownloadPath) {
                NSString *urlString = [NSString stringWithFormat:@"%@?%@", url, [param AZ_urlParamsStringSignature:YES]];
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                urlRequest.requestParams = param;
                
                AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:urlRequest targetPath:request.resumableDownloadPath shouldResume:YES];
                [operation setProgressiveDownloadProgressBlock:request.resumableDownloadProgressBlock];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                    [self requestDidFinished:operation];
                } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                    [self requestDidFailed:operation error:error];
                }];
                request.operation = operation;
                [self.operationManager.operationQueue addOperation:operation];
            } else {
                AFHTTPRequestOperation *operation = [self.operationManager GET:url parameters:param success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                    [self requestDidFinished:operation];
                } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                    [self requestDidFailed:operation error:error];
                }];
                request.operation = operation;
            }
        } else if (method == AZRequestMethodPost) {
            if (constructingBlock) {
                AFHTTPRequestOperation *operation = [self.operationManager POST:url parameters:param constructingBodyWithBlock:constructingBlock success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                    [self requestDidFinished:operation];
                } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                    [self requestDidFailed:operation error:error];
                }];
                request.operation = operation;
            } else {
                AFHTTPRequestOperation *operation = [self.operationManager POST:url parameters:param success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                    [self requestDidFinished:operation];
                } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                    [self requestDidFailed:operation error:error];
                }];
                request.operation = operation;
            }
        }
    }
    
    [self addOperation:request];
    return @(request.operation.hash);
}

#pragma mark - callbacks
- (void)requestDidFinished:(AFHTTPRequestOperation *)operation
{
    AZBaseRequest *request = self.dispatchTable[@(operation.hash)];
    AZURLResponse *response = [[AZURLResponse alloc] initWithResponseString:operation.responseString request:operation.request responseData:operation.responseData status:AZURLResponseStatusSuccess];
    [request requestDidFinished:response];
    [self removeOperation:operation];
}

- (void)requestDidFailed:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    AZBaseRequest *request = self.dispatchTable[@(operation.hash)];
    AZURLResponse *response = [[AZURLResponse alloc] initWithResponseString:operation.responseString request:operation.request responseData:operation.responseData error:error];
    [request requestDidFailed:response];
    [self removeOperation:operation];
}

#pragma mark - private methods
- (NSString *)buildRequestURL:(AZBaseRequest<AZRequest> *)request
{
    NSString *requestURL = [request requestURL];
    AZService<AZService> *service = [[AZNetworkConfig sharedInstance] serviceWithIdentifier:[request serviceType]];
    NSString *baseURL = service.baseURL;
    // 是否需要签名
    BOOL useSignature = NO;
    if ([request respondsToSelector:@selector(useSignature)]) {
        useSignature = [request useSignature];
    } else {
        useSignature = [AZNetworkConfig sharedInstance].useSignature;
    }
    
    // 如果需要签名
    if (useSignature) {
        return [NSString stringWithFormat:@"%@%@%@", baseURL, service.apiVersion, requestURL];
    }
    // 如果有版本号
    if (service.apiVersion.length > 0) {
        return [NSString stringWithFormat:@"%@%@/%@", baseURL, service.apiVersion, requestURL];
    }
    
    return [NSString stringWithFormat:@"%@%@%@", baseURL, service.apiVersion, requestURL];
}

- (void)addOperation:(AZBaseRequest *)request {
    if (request.operation != nil) {
        @synchronized(self) {
            self.dispatchTable[@(request.operation.hash)] = request;
        }
    }
}

- (void)removeOperation:(AFHTTPRequestOperation *)operation {
    @synchronized(self) {
        [self.dispatchTable removeObjectForKey:@(operation.hash)];
    }
    NSLog(@"Request queue size = %lu", (unsigned long)[self.dispatchTable count]);
}

#pragma mark - getters and setters
- (NSMutableDictionary *)dispatchTable
{
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPRequestOperationManager *)operationManager
{
    if (_operationManager == nil) {
        _operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:nil];
        _operationManager.operationQueue.maxConcurrentOperationCount = 4;
    }
    return _operationManager;
}

@end
