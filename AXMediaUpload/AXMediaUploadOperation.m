//
//  AXMediaUploadOperation.m
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import "AXMediaUploadOperation.h"

@implementation AXMediaUploadOperation

- (id)initWithSelection:(AXMediaSelection *)selection service:(id <AXMediaUploadService>)service;
{
    if ((self = [super init]))
    {
        _mediaSelection = selection;
        _service = service;
    }
    
    return self;
}

- (void)startUpload {}
- (void)cancelUpload {}
- (void)finishUpload {}

- (void)execProgressUpdate:(double)progress;
{
    if (self.progressBlock)
        self.progressBlock(progress);
}

- (void)execCompletionWithLinkURL:(NSURL *)linkURL directURL:(NSURL *)embedURL embedHTML:(NSString *)embedString;
{
    if (self.completionBlock)
        self.completionBlock(linkURL, embedURL, embedString);
    
    if (self.cleanupBlock)
    {
        [self finishUpload];
        self.cleanupBlock();
    }
}

- (void)execError:(NSError *)error;
{
    if (self.errorBlock)
        self.errorBlock(error);
}

@end