//
//  AXMediaUploadOperation.m
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import "AXMediaUploadOperation.h"

@implementation AXMediaUploadOperation

- (void)startUpload {}
- (void)cancelUpload {}

- (void)execProgressUpdate:(double)progress;
{
    if (self.progressBlock)
        self.progressBlock(progress);
}

- (void)execCompletionWithLinkURL:(NSURL *)linkURL embedURL:(NSURL *)embedURL embedString:(NSString *)embedString;
{
    if (self.completionBlock)
        self.completionBlock(linkURL, embedURL, embedString);
    
    if (self.cleanupBlock)
        self.cleanupBlock();
}

- (void)execError:(NSError *)error;
{
    if (self.errorBlock)
        self.errorBlock(error);
}

@end