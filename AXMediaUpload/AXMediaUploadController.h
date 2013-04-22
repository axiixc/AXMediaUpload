//
//  AXMediaUploadController.h
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXMediaSelectionController.h"

@class AXMediaSelection;
@class AXMediaUploadOperation;
@protocol AXMediaUploadService;
@protocol AXMediaUploadControllerDataSource;
@protocol AXMediaUploadControllerDelegate;

extern void AXMediaUploadControllerRegisterService(Class serviceClass, NSString * identifier);

@interface AXMediaUploadController : NSObject <AXMediaSelectionControllerDelegate>

+ (void)setDefaultDataSource:(id <AXMediaUploadControllerDataSource>)dataSource;
+ (id <AXMediaUploadControllerDataSource>)defaultDataSource;

+ (NSArray *)availableServicesForMediaType:(AXMediaType)type;

- (id)initUsingDefaultDataSourceAndDelegate:(id <AXMediaUploadControllerDelegate>)delegate;
- (id)initWithDataSource:(id <AXMediaUploadControllerDataSource>)dataSource
                delegate:(id <AXMediaUploadControllerDelegate>)delegate;

- (void)uploadOperationForSelection:(AXMediaSelection *)selection
                       continuation:(void (^)(AXMediaUploadOperation *))continuation;

@property (nonatomic, weak) id <AXMediaUploadControllerDataSource> dataSource;
@property (nonatomic, weak) id <AXMediaUploadControllerDelegate> delegate;

@end

@protocol AXMediaUploadControllerDataSource <NSObject>

- (void)uploadController:(AXMediaUploadController *)controller
      selectServiceClass:(NSArray *)availableServiceClasses
        withContinuation:(void (^)(Class serviceClass))continuation;

- (NSDictionary *)uploadController:(AXMediaUploadController *)controller
        credentialsForServiceClass:(Class)serviceClass;

- (void)uploadController:(AXMediaUploadController *)controller
          setCredentials:(NSDictionary *)credentials
              forService:(id <AXMediaUploadService>)service;

@end

@protocol AXMediaUploadControllerDelegate <NSObject>

- (void)uploadController:(AXMediaUploadController *)controller
 requiresAccountCreation:(UIViewController *)accountCreationViewController;

@optional
- (void)uploadController:(AXMediaUploadController *)controller
  prepareUploadOperation:(AXMediaUploadOperation *)operation;

@end
