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
@class AXMediaUploadOperation;

@protocol AXMediaUploadService <NSObject>

+ (NSDictionary *)serviceInformation;
+ (AXMediaCategory)serviceUploadCategories;
+ (AXMediaUploadServiceCreationViewController *)newServiceCreationViewController;

- (id)initWithCredentials:(NSDictionary *)credentials;

@optional
- (Class)mediaUploadOperationClass;
- (void)configureUploadOperation:(AXMediaUploadOperation *)uploadOperation;

@end