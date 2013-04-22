 //
//  AXMediaUploadController.m
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import "AXMediaUploadController.h"
#import "AXMediaUpload.h"

static NSMutableDictionary * __serviceRegistrations = nil;

extern void AXMediaUploadControllerRegisterService(Class serviceClass, NSString * identifier)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __serviceRegistrations = [NSMutableDictionary new];
    });
    
    if (!identifier || !identifier.length || ![serviceClass conformsToProtocol:@protocol(AXMediaUploadService)])
        return;
    
    [__serviceRegistrations setObject:serviceClass forKey:identifier];
}

@implementation AXMediaUploadController

+ (void)initialize
{
    AXMediaUploadControllerRegisterService(NSClassFromString(@"CLEngine"), kAXMediaUploadServiceCloudApp);
}

+ (NSArray *)availableServicesForMediaType:(AXMediaType)type;
{
    NSMutableArray * services = [NSMutableArray arrayWithCapacity:__serviceRegistrations.count];
    [__serviceRegistrations enumerateKeysAndObjectsUsingBlock:^(NSString * identifier, Class serviceClass, BOOL *stop) {
        if (AXMediaCategoriesContainsType([serviceClass serviceUploadCategories], type))
            [services addObject:serviceClass];
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
    return (_dataSource) ? _dataSource : [[self class] defaultDataSource];
}

#pragma mark - Media Selection Uploads

- (void)uploadOperationForSelection:(AXMediaSelection *)selection continuation:(void (^)(AXMediaUploadOperation *))continuation;
{
    NSParameterAssert(continuation);
    
    [self _createServiceFromSelection:selection continuation:^(id <AXMediaUploadService> service) {
        if (![service respondsToSelector:@selector(mediaUploadOperationClass)]
            || [service mediaUploadOperationClass] == Nil)
        {
            continuation(nil);
            return;
        }
        
        AXMediaUploadOperation * operation = [[service mediaUploadOperationClass] new];
        operation.mediaSelection = selection;
        operation.service = service;
        
        if ([service respondsToSelector:@selector(configureUploadOperation:)])
            [service configureUploadOperation:operation];
        
        if ([self.delegate respondsToSelector:@selector(uploadController:prepareUploadOperation:)])
            [self.delegate uploadController:self prepareUploadOperation:operation];
        
        [operation startUpload];
    }];
}

- (void)_createServiceFromSelection:(AXMediaSelection *)selection continuation:(void (^)(id <AXMediaUploadService>))continuation;
{
    NSArray * serviceClasses = [[self class] availableServicesForMediaType:selection.mediaType];
    
    if (serviceClasses.count <= 1)
        return continuation([self _instanciateServiceClass:serviceClasses.lastObject]);
    
    [self.dataSource uploadController:self selectServiceClass:serviceClasses withContinuation:^(__unsafe_unretained Class serviceClass) {
        continuation([self _instanciateServiceClass:serviceClass]);
    }];
}

- (id <AXMediaUploadService>)_instanciateServiceClass:(Class)serviceClass
{
    if (serviceClass == Nil)
        return nil;
    
    NSDictionary * credentials = [self.dataSource uploadController:self credentialsForServiceClass:serviceClass];
    return [[serviceClass alloc] initWithCredentials:credentials];
}

@end
