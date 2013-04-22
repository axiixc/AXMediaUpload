//
//  AXMediaUploadOperation.h
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AXMediaUploadConstants.h"

@class AXMediaSelection;
@protocol AXMediaUploadService;

@interface AXMediaUploadOperation : NSObject

- (void)startUpload;
- (void)cancelUpload;

@property (nonatomic, copy) AXMediaUploadProgressBlock progressBlock;
@property (nonatomic, copy) AXMediaUploadCompletionBlock completionBlock;
@property (nonatomic, copy) AXMediaUploadErrorBlock errorBlock;

@property (nonatomic, strong) id <AXMediaUploadService> service;
@property (nonatomic, strong) AXMediaSelection * mediaSelection;
@property (nonatomic, copy) void (^cleanupBlock)();

@end

@interface AXMediaUploadOperation (Lifecycle)
- (void)execProgressUpdate:(double)progress;
- (void)execCompletionWithLinkURL:(NSURL *)linkURL embedURL:(NSURL *)embedURL embedString:(NSString *)embedString;
- (void)execError:(NSError *)error;
@end