//
//  AXMediaUploadServiceDescription.m
//  DemoApp
//
//  Created by James Savage on 4/22/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import "AXMediaUploadServiceDescription.h"
#import "AXMediaUploadService.h"

@implementation AXMediaUploadServiceDescription {
    Class _serviceClass;
}

+ (instancetype)serviceDescriptionWithClass:(Class)serviceClass;
{
    NSAssert([serviceClass conformsToProtocol:@protocol(AXMediaUploadService)], @"Supplied class does not implement the AXMediaUploadService protocol.");
    
    AXMediaUploadServiceDescription * description = [[self alloc] init];
    description->_serviceClass = serviceClass;
    
    return description;
}

- (BOOL)supportsMediaType:(AXMediaType)type;
{
    return AXMediaCategoriesContainsType(self.serviceCategories, type);
}

- (id <AXMediaUploadService>)createUploadServiceWithCredentials:(NSDictionary *)credentials;
{
    return [_serviceClass createServiceWithCredentials:credentials];
}

- (AXMediaUploadServiceCreationViewController *)createServiceCreationViewController;
{
    return [_serviceClass createServiceCreationViewController];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
        return NO;
    
    return [self.serviceIdentifier isEqualToString:[object serviceIdentifier]];
}

@end
