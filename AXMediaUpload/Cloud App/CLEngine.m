//
//  CLEngine.m
//  Firefly
//
//  Created by James Savage on 1/2/13.
//  Copyright (c) 2013 axiixc.com. All rights reserved.
//

#import "CLEngine.h"
#import "CLEngineUploadOperation.h"
#import "CLEngineAccountCreationViewController.h"
#import "AXMediaUploadController.h"

NSString * const CLEngineErrorDomain = @"com.axiixc.AXMediaUpload.cloud-app.error";

@interface CLEngine () {
    NSString * _paymentRedirectURL;
}

@property (nonatomic, strong) NSDictionary * credentials;

@end

@implementation CLEngine

#pragma mark - FFMediaUploadService

+ (NSDictionary *)serviceInformation;
{
    return @{ kAXMediaUploadServiceInformationLocalizedNameKey : @"CloudApp" };
}

+ (AXMediaUploadServiceCreationViewController *)newServiceCreationViewController
{
    CLEngine * engine = [[self alloc] initWithCredentials:nil];
    return [[CLEngineAccountCreationViewController alloc] initWithEngine:engine];
}

- (Class)mediaUploadOperationClass
{
    return [CLEngineUploadOperation class];
}

+ (AXMediaCategory)serviceUploadCategories
{
    return AXMediaCategoryDefault;
}

- (id)initWithCredentials:(NSDictionary *)credentials
{
    if (!(self = [super initWithBaseURL:[NSURL URLWithString:@"http://my.cl.ly"]]))
        return nil;
    
    [self setDefaultHeader:@"accept" value:@"application/json"];
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    self.credentials = credentials;
    
    return self;
}

- (void)setCredentials:(NSDictionary *)credentials
{
    _credentials = credentials;
    
    [self setDefaultCredential:[NSURLCredential credentialWithUser:credentials[@"username"]
                                                          password:credentials[@"password"]
                                                       persistence:NSURLCredentialPersistencePermanent]];
}

#pragma mark - Account Management

- (void)testUsername:(NSString *)username
            password:(NSString *)password
onVerificationComplete:(void (^)(BOOL success))verificationCompleteBlock;
{
    if (STR_EMPTY(username) || STR_EMPTY(password))
        return verificationCompleteBlock(NO);
    
    NSURLRequest * itemsRequest = [self requestWithMethod:@"GET" path:@"items" parameters:nil];
    AFHTTPRequestOperation * op = [self HTTPRequestOperationWithRequest:itemsRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.credentials = @{ @"username": username, @"password": password };
        verificationCompleteBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        verificationCompleteBlock(NO);
    }];
    [op setCredential:[NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceNone]];
    
    [self enqueueHTTPRequestOperation:op];
}

- (void)registerUsername:(NSString *)username
                password:(NSString *)password
  onRegistrationComplete:(void (^)(BOOL))registrationCompleteBlock
{
    [self postPath:@"register" parameters:@{
        @"email": username,
        @"password": password,
        @"accept_tos": @"true"
     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         self.credentials = @{ @"username": username, @"password": password };
         registrationCompleteBlock(YES);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         registrationCompleteBlock(NO);
     }];
}

#pragma mark - Internal Methods

- (AFHTTPRequestOperation *)operationGetUploadCredentials:(CLEngineOperationCompletionBlock)completionBlock;
{
    NSParameterAssert(completionBlock);
    
    NSURLRequest * request = [self requestWithMethod:@"GET" path:@"items/new" parameters:nil];
    return [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * operation, id responseObject) {
        if ([operation isKindOfClass:[AFJSONRequestOperation class]])
        {
            AFJSONRequestOperation * jsonOperation = (AFJSONRequestOperation *)operation;
            completionBlock(jsonOperation.responseJSON, nil);
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        completionBlock(nil, error);
    }];
}

- (AFHTTPRequestOperation *)operationWithData:(NSData *)data
                        withUploadCredentials:(NSDictionary *)uploadCredentials
                                   completion:(CLEngineOperationCompletionBlock)completionBlock;
{
    NSParameterAssert(completionBlock);
    
    NSNumber * remainingUploads = uploadCredentials[@"uploads_remaining"];
    if (remainingUploads != nil && remainingUploads.integerValue == 0)
    {
        [[[UIAlertView alloc]
          initWithTitle:@"Reached Upload Limit"
          message:nil
          delegate:nil
          cancelButtonTitle:@"Dismiss"
          otherButtonTitles:nil] show];
        return nil;
    }
    
    long long maxUploadSize = [uploadCredentials[@"max_upload_size"] longLongValue];
    
    if (data.length > maxUploadSize)
    {
        [[[UIAlertView alloc]
          initWithTitle:@"Filesize to Large"
          message:nil
          delegate:nil
          cancelButtonTitle:@"Dismiss"
          otherButtonTitles:nil] show];
        return nil;
    }
    
    // TODO This is all wrong
    NSURLRequest * request = [self
                              multipartFormRequestWithMethod:@"POST"
                              path:uploadCredentials[@"url"]
                              parameters:uploadCredentials[@"params"]
                              constructingBodyWithBlock:^(id <AFMultipartFormData> formData) { // TODO Change this
                                  [formData appendPartWithFileData:data name:@"file" fileName:@"fileName-changeme" mimeType:nil];
                              }];
    
    return [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation isKindOfClass:[AFJSONRequestOperation class]])
        {
            AFJSONRequestOperation * jsonOperation = (AFJSONRequestOperation *)operation;
            completionBlock(jsonOperation.responseJSON, nil);
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        completionBlock(nil, error);
    }];
}

@end
