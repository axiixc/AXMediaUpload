//
//  CLEngineUploadToken.m
//  Firefly
//
//  Created by James Savage on 1/3/13.
//  Copyright (c) 2013 axiixc.com. All rights reserved.
//

#import "CLEngineUploadOperation.h"
#import "CLEngine.h"
#import "AXMediaSelection.h"

@implementation CLEngineUploadOperation

#pragma mark - AXMediaUploadOperation

- (void)startUpload;
{
    CLEngine * engine = (CLEngine *)self.service;
    
    NSURLRequest * request = [engine requestWithMethod:@"GET" path:@"items/new" parameters:nil];
    self.s3Params = [engine HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * operation, id responseObject) {
        if ([operation isKindOfClass:[AFJSONRequestOperation class]])
        {
            AFJSONRequestOperation * jsonOperation = (AFJSONRequestOperation *)operation;
            [self _secondStageUpload:jsonOperation.responseJSON];
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        [self execError:error];
    }];
    
    [engine enqueueHTTPRequestOperation:self.s3Params];
}

- (void)finishUpload
{
    // TODO: This is me being too lazy to actually debug retian cycles in blocks :(
    self.s3Params = nil;
    self.s3Upload = nil;
}

- (void)cancelUpload;
{
    [self.s3Params cancel];
    [self.s3Upload cancel];
}

#pragma mark - Internal Upload Methods

- (BOOL)isValidUpload:(NSURL *)dataURL withCredentials:(NSDictionary *)uploadCredentials
{
    NSNumber * remainingUploads = uploadCredentials[@"uploads_remaining"];
    if (remainingUploads != nil && remainingUploads.integerValue == 0)
    {
        NSDictionary * userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Upload limit reached", nil) };
        [self execError:[NSError errorWithDomain:CLEngineErrorDomain code:0 userInfo:userInfo]];
        
        return NO;
    }
    
    NSError * __autoreleasing error = nil;
    NSDictionary * dataInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:[dataURL path] error:&error];
    if (!dataInfo || error)
    {
        [self execError:error];
        return NO;
    }
    
    long long maxUploadSize = [uploadCredentials[@"max_upload_size"] longLongValue];
    if (dataInfo.fileSize > maxUploadSize)
    {
        NSDictionary * userInfo = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Filesize is too large", nil) };
        [self execError:[NSError errorWithDomain:CLEngineErrorDomain code:0 userInfo:userInfo]];
        
        return NO;
    }
    
    return YES;
}

- (void)_secondStageUpload:(NSDictionary *)credentials
{
    [self.mediaSelection getDataURL:^(NSURL * dataURL, NSString * mimeType) {
        
        if (![self isValidUpload:dataURL withCredentials:credentials])
            return;
        
        CLEngine * engine = (CLEngine *) self.service;
        
        NSURLRequest * request = [engine multipartFormRequestWithMethod:@"POST" path:credentials[@"url"] parameters:credentials[@"params"] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSError * __autoreleasing error = nil;
            NSString * fileName = (self.mediaSelection.filenameSuggestion) ? self.mediaSelection.filenameSuggestion : self.mediaSelection.genericFilenameSuggestion;
            [formData appendPartWithFileURL:dataURL name:@"file" fileName:fileName mimeType:mimeType error:&error];
        }];
        
        self.s3Upload = [engine HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([operation isKindOfClass:[AFJSONRequestOperation class]])
            {
                AFJSONRequestOperation * jsonOperation = (AFJSONRequestOperation *)operation;
                [self _thirdStageUpload:jsonOperation.responseJSON];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self execError:error];
        }];
        
        [self.s3Upload setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            double progress = (totalBytesWritten / totalBytesExpectedToWrite);
            [self execProgressUpdate:progress];
        }];
        
        [engine enqueueHTTPRequestOperation:self.s3Upload];

    }];
}

- (void)_thirdStageUpload:(NSDictionary *)response
{
    [self execCompletionWithLinkURL:[NSURL URLWithString:response[@"url"]]
                          directURL:[NSURL URLWithString:response[@"remote_url"]]
                          embedHTML:nil];
}

@end
