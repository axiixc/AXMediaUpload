//
//  AXMediaUploadService.h
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXMediaUploadConstants.h"

@class AXMediaUploadServiceCreationViewController;
@class AXMediaUploadServiceDescription;
@class AXMediaUploadOperation;
@class AXMediaSelection;

@protocol AXMediaUploadService <NSObject>

+ (AXMediaUploadServiceDescription *)serviceDescription;

+ (id)createServiceWithCredentials:(NSDictionary *)credentials;
+ (AXMediaUploadServiceCreationViewController *)createServiceCreationViewController;

- (Class)mediaUploadOperationClassForSelection:(AXMediaSelection *)selection;

@optional
- (void)configureUploadOperation:(AXMediaUploadOperation *)uploadOperation;

@end