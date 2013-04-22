//
//  CLEngine.h
//  Firefly
//
//  Created by James Savage on 1/2/13.
//  Copyright (c) 2013 axiixc.com. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "AXMediaUploadService.h"

extern NSString * const CLEngineErrorDomain;

typedef void (^CLEngineOperationCompletionBlock)(NSDictionary * response, NSError * error);

@interface CLEngine : AFHTTPClient <AXMediaUploadService>

- (void)testUsername:(NSString *)username
            password:(NSString *)password
onVerificationComplete:(void (^)(BOOL success))verificationCompleteBlock;
- (void)registerUsername:(NSString *)username
                password:(NSString *)password
  onRegistrationComplete:(void (^)(BOOL success))registrationCompleteBlock;

- (AFHTTPRequestOperation *)operationGetUploadCredentials:(CLEngineOperationCompletionBlock)completionBlock;

- (AFHTTPRequestOperation *)operationWithData:(NSData *)data
                        withUploadCredentials:(NSDictionary *)uploadCredentials
                                   completion:(CLEngineOperationCompletionBlock)completionBlock;

@end
