//
//  BaseService.m
//  Core
//
//  Created by Armen on 3/28/14.
//  Copyright (c) 2014 Armen Mkrtchian All rights reserved.
//

#import "BaseNetwork.h"
#import "Util.h"

#define TimeOutInterval 30

#define kStatusCode @"statusCode"
#define kErrorMessage @"message"


@interface BaseNetwork ()
@end

@implementation BaseNetwork

- (instancetype)init {
    
    self = [self initWithUrl:nil];
    if (self) {
        
    }
    
    return  self;
}

- (instancetype)initWithUrl:(NSString *)url {
    
    self = [super init];
    if (self) {
        
        _baseServerUrl = url;
        
        _baseServerUrl = _baseServerUrl ? _baseServerUrl : BaseServerURL;
        //Init
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:_baseServerUrl]];
        NSOperationQueue *operationQueue = manager.operationQueue;
        operationQueue.maxConcurrentOperationCount = 1;
        [manager.reachabilityManager startMonitoring];
        
//        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//            NSLog(@"AFNetworkReachabilityStatus: %li", status);
//            
//            switch (status) {
//                case AFNetworkReachabilityStatusReachableViaWWAN:
//                case AFNetworkReachabilityStatusReachableViaWiFi: {
//                    [operationQueue setSuspended:NO];
//                }
//                    break;
//                case AFNetworkReachabilityStatusNotReachable:
//                default:
//                    [operationQueue setSuspended:YES];
//                    break;
//            }
//        }];
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [requestSerializer setHTTPShouldHandleCookies:NO];
        
        manager.requestSerializer = requestSerializer;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    }
    
    return  self;
}

- (void)preparingForRequests {
    
    __block __weak id blockDelegate = self.delegate;
    //Preparing For request
    if([blockDelegate respondsToSelector:@selector(preparingForRequests)])
    {
        [blockDelegate preparingForRequests];
    }
}

-(NSDictionary *)prepareParams:(NSDictionary *)params {
    NSMutableDictionary *newParams = [NSMutableDictionary dictionaryWithDictionary:params];
    
    return newParams;
}

-(void)makePostRequest:(NSString *)url withParams:(NSDictionary*)params success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock {
    //Preparing For request
    [self preparingForRequests];
    NSDictionary *newParams = [self prepareParams:params];

    [manager POST:url parameters:newParams timeoutInterval:TimeOutInterval success:successBlock failure:failureBlock];
}

-(void)makePutRequest:(NSString *)url withParams:(NSDictionary*)params success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock {
    //Preparing For request
    [self preparingForRequests];
    NSDictionary *newParams = [self prepareParams:params];

    [manager PUT:url parameters:newParams timeoutInterval:TimeOutInterval success:successBlock failure:failureBlock];
}

-(void)makeDeleteRequest:(NSString *)url withParams:(NSDictionary*)params success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock {
    //Preparing For request
    [self preparingForRequests];
    NSDictionary *newParams = [self prepareParams:params];

    [manager DELETE:url parameters:newParams timeoutInterval:TimeOutInterval success:successBlock failure:failureBlock];
}

-(void)makeGetRequest:(NSString *)url withParams:(NSDictionary*)params success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock {
    //Preparing For request
    [self preparingForRequests];
    NSDictionary *newParams = [self prepareParams:params];

    [manager GET:url parameters:newParams timeoutInterval:TimeOutInterval success:successBlock failure:failureBlock];
}

-(void)makePostRequest:(NSString *)url withParams:(NSDictionary*)params constructingBodyWithBlock:(AFConstructingBlock)constructingBlock success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock {
    //Preparing For request
    [self preparingForRequests];
    NSDictionary *newParams = [self prepareParams:params];

    [manager POST:url parameters:newParams timeoutInterval:TimeOutInterval constructingBodyWithBlock:constructingBlock success:successBlock failure:failureBlock];
}

- (AFSuccessBlock)constructSuccessBlockWithBlock:(AFSuccessBlock)completionBlock {
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        switch (operation.response.statusCode) {
            case 200: //Success Response
            {
                if ([responseObject isKindOfClass:[NSDictionary class]] || [responseObject isKindOfClass:[NSArray class]]) {
                    if (completionBlock) {
                        
                        completionBlock(operation , responseObject);
                        return;
                    }
                }
                
                ErrorDataModel *errorObj = [[ErrorDataModel alloc] init];
                errorObj.statusCode = @400;
                errorObj.message = kErrorMessageUnknown;
                completionBlock(operation, errorObj);
            }
                break;
                
            default:
            {
                ErrorDataModel *errorObj = [[ErrorDataModel alloc] init];
                errorObj.statusCode = @400;
                errorObj.message = kErrorMessageUnknown;
                completionBlock(operation, errorObj);
            }
                break;
        }
    };
    
    return successBlock;
}

-(AFFailureBlock)constructFailureBlockWithBlock:(CompletionBlock)completionBlock {
    __block __weak id blockDelegate = self.delegate;
    
    AFFailureBlock failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error)
    {
        //URL Loading System Error Codes
        //https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/Reference/reference.html
        
        NSLog(@"Network call has failed");
        NSLog(@"response status code: %ld", operation.response.statusCode);
        NSLog(@"request: %@", operation.request);
        NSLog(@"request url: %@", operation.request.URL.absoluteString);
        NSLog(@"responseObject: %@", [operation responseObject]);
        id responseObject = [operation responseObject];
        if (responseObject) {
            switch (operation.response.statusCode) {
                    //Error Response
                case 400: {
                    
                    ErrorDataModel *errorObj;
                    
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        errorObj = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                    }
                    
                    completionBlock(nil, errorObj);
                    if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                    {
                        [blockDelegate errorResponse: errorObj];
                    }
                    break;
                }
                    
                case 404: {
                    
                    ErrorDataModel *errorObj;
                    
                    NSDictionary *errorData = @{kStatusCode: @404, kErrorMessage : @"Not found"};
                    errorObj = [[ErrorDataModel alloc] initWithDictionary:errorData];
                    
                    completionBlock(nil, errorObj);
                    if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                    {
                        [blockDelegate errorResponse: errorObj];
                    }
                    
                }
                    break;
                    //Session expired
                case 401: {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTokenExpired object:self];
                }
                    break;
                    //Internal Error Response
                case 500: {
                
                    ErrorDataModel *errorObj;
                    
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        errorObj = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                    } else {
                        NSDictionary *errorData = @{kStatusCode: @500, kErrorMessage : @"Network Error"};
                        errorObj = [[ErrorDataModel alloc] initWithDictionary:errorData];
                    }
                    
                    completionBlock(nil, errorObj);
                    if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                    {
                        [blockDelegate errorResponse: errorObj];
                    }
                    
                }
                    break;
                    //Default error response
                default: {
                    
                    ErrorDataModel *errorObj;
                    
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        errorObj = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                    }
                    
                    completionBlock(nil, errorObj);
                    if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                    {
                        [blockDelegate errorResponse: errorObj];
                    }
                }
                    break;
            }
        } else {
            NSLog(@"Error: %@", [error description]);
            if (error) {
                //general error
                switch (error.code) {
                        break;
                    case -999: //Request Canceled Error Response
                    {
                        //TODO handle Request Cancel Error
                        ErrorDataModel *errorObj;
                        NSDictionary *errorData = @{kStatusCode: @(-999), kErrorMessage : @"Request Cancelled"};
                        errorObj = [[ErrorDataModel alloc] initWithDictionary:errorData];
                        
                        completionBlock(nil, errorObj);
                        if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                        {
                            [blockDelegate errorResponse: errorObj];
                        }
                    }
                        break;
                    case -1001: //Request Timeout Error
                    {
                        //TODO handle Timeout Error
                        ErrorDataModel *errorObj;
                        
                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                            errorObj = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                        } else {
                            NSDictionary *errorData = @{kStatusCode: @(-1001), kErrorMessage : @"Network Timeout"};
                            errorObj = [[ErrorDataModel alloc] initWithDictionary:errorData];
                        }
                        
                        completionBlock(nil, errorObj);
                        if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                        {
                            [blockDelegate errorResponse: errorObj];
                        }
                    }
                        break;
                    case -1009: //The Internet connection appears to be offline.
                    {
                        ErrorDataModel *errorObj;
                        
                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                            errorObj = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                        } else {
                            NSDictionary *errorData = @{kStatusCode: @(-1009), kErrorMessage : @"The Internet connection appears to be offline."};
                            errorObj = [[ErrorDataModel alloc] initWithDictionary:errorData];
                        }
                        
                        completionBlock(nil, errorObj);
                        if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                        {
                            [blockDelegate errorResponse: errorObj];
                        }
                    }
                        break;
                    default:
                    {
                        ErrorDataModel *errorObj;
                        NSDictionary *errorData = @{kStatusCode: @(error.code), kErrorMessage : error.localizedDescription};
                        errorObj = [[ErrorDataModel alloc] initWithDictionary:errorData];
                        
                        completionBlock(nil, errorObj);
                        if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                        {
                            [blockDelegate errorResponse: errorObj];
                        }
                    }
                        break;
                }
            }
        }
    };
    return failureBlock;
}

- (void)cancelAllRequests {

    // cancel all of them!
    [manager.operationQueue cancelAllOperations];
    
//    for (NSOperation *operation in manager.operationQueue.operations) {
//
//        // here you can check if this is an operation you want to cancel
//        [operation cancel];
//    }
}
@end
