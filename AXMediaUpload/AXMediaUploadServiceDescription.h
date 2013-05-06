//
//  AXMediaUploadServiceDescription.h
//  DemoApp
//
//  Created by James Savage on 4/22/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXMediaUploadConstants.h"

@class AXMediaUploadServiceCreationViewController;
@protocol AXMediaUploadService;

@interface AXMediaUploadServiceDescription : NSObject

+ (instancetype)serviceDescriptionWithClass:(Class)serviceClass;

@property (nonatomic, strong) NSString * serviceName;
@property (nonatomic, strong) NSString * serviceIdentifier;
@property (nonatomic) AXMediaCategory serviceCategories;

- (BOOL)supportsMediaType:(AXMediaType)type;

- (id <AXMediaUploadService>)createUploadServiceWithCredentials:(NSDictionary *)credentials;
- (AXMediaUploadServiceCreationViewController *)createServiceCreationViewController;

@end
