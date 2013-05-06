 //
//  AXMediaUploadController.m
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import "AXMediaUploadController.h"
#import "AXMediaUpload.h"

static NSMutableSet * __serviceRegistrations = nil;

extern void AXMediaUploadControllerRegisterService(Class serviceClass)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __serviceRegistrations = [[NSMutableSet alloc] init];
    });
    
    if (serviceClass && ![serviceClass conformsToProtocol:@protocol(AXMediaUploadService)])
    {
        NSLog(@"Warning: %@ is not a valid AXMediaUpload service", serviceClass);
        return;
    }
    
    [__serviceRegistrations addObject:[serviceClass serviceDescription]];
}

@implementation AXMediaUploadController

static id <AXMediaUploadControllerDataSource> __defaultDataSource = nil;

+ (void)setDefaultDataSource:(id <AXMediaUploadControllerDataSource>)dataSource
{
    __defaultDataSource = dataSource;
}

+ (id <AXMediaUploadControllerDataSource>)defaultDataSource
{
    return __defaultDataSource;
}

+ (void)initialize
{
    AXMediaUploadControllerRegisterService(NSClassFromString(@"CLEngine"));
}

+ (NSArray *)availableServicesForMediaType:(AXMediaType)type;
{
    NSMutableArray * services = [NSMutableArray arrayWithCapacity:__serviceRegistrations.count];
    [__serviceRegistrations enumerateObjectsUsingBlock:^(AXMediaUploadServiceDescription * description, BOOL *stop) {
        if ([description supportsMediaType:type])
            [services addObject:description];
    }];
    
    return services;
}

- (id)initUsingDefaultDataSourceAndDelegate:(id <AXMediaUploadControllerDelegate>)delegate;
{
    return [self initWithDataSource:nil delegate:delegate];
}

- (id)initWithDataSource:(id <AXMediaUploadControllerDataSource>)dataSource
                delegate:(id <AXMediaUploadControllerDelegate>)delegate;
{
    if (!(self = [super init]))
        return nil;
    
    self.dataSource = dataSource;
    self.delegate = delegate;
    
    return self;
}

- (id <AXMediaUploadControllerDataSource>)dataSource
{
    return (_dataSource) ?: [[self class] defaultDataSource];
}

#pragma mark - Media Selection Uploads

- (void)uploadOperationForSelection:(AXMediaSelection *)selection continuation:(void (^)(AXMediaUploadOperation *))continuation;
{
    NSParameterAssert(continuation);
    
    [self _createServiceFromSelection:selection continuation:^(id <AXMediaUploadService> service) {
        Class operationClass = [service mediaUploadOperationClassForSelection:selection];
        AXMediaUploadOperation * operation = [[operationClass alloc] initWithSelection:selection service:service];
        
        if ([service respondsToSelector:@selector(configureUploadOperation:)])
            [service configureUploadOperation:operation];
        
        if ([self.delegate respondsToSelector:@selector(uploadController:prepareUploadOperation:)])
            [self.delegate uploadController:self prepareUploadOperation:operation];
        
        [operation startUpload];
    }];
}

- (void)_createServiceFromSelection:(AXMediaSelection *)selection continuation:(void (^)(id <AXMediaUploadService>))continuation;
{
    NSArray * serviceDescriptions = [[self class] availableServicesForMediaType:selection.mediaType];
    
    if ([self.dataSource respondsToSelector:@selector(uploadController:filterAvailableServices:)])
        serviceDescriptions = [self.dataSource uploadController:self filterAvailableServices:serviceDescriptions];
    
    void (^selectDescriptionBlock)(AXMediaUploadServiceDescription *) = ^(AXMediaUploadServiceDescription * description) {
        NSDictionary * credentials = [self.dataSource uploadController:self credentialsForServiceDescription:description];
        continuation([description createUploadServiceWithCredentials:credentials]);
    };
    
    if (serviceDescriptions.count <= 1)
        selectDescriptionBlock([serviceDescriptions lastObject]);
    else
        [self.delegate uploadController:self selectService:selectDescriptionBlock fromAvailable:serviceDescriptions];
}

#pragma mark - AXMediaSelectionControllerDelegate

- (void)selectionController:(AXMediaSelectionController *)controller didMakeSelection:(AXMediaSelection *)selection
{
    
}

- (void)selectionController:(AXMediaSelectionController *)controller encounteredError:(NSError *)error
{
    
}

@end
