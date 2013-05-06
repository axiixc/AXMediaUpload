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
@class AXMediaUploadServiceDescription;

@protocol AXMediaUploadControllerDataSource;
@protocol AXMediaUploadControllerDelegate;

extern void AXMediaUploadControllerRegisterService(Class serviceClass);

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

- (NSDictionary *)uploadController:(AXMediaUploadController *)controller
  credentialsForServiceDescription:(AXMediaUploadServiceDescription *)servieDescription;

// TODO: Never called
- (void)uploadController:(AXMediaUploadController *)controller
          setCredentials:(NSDictionary *)credentials
   forServiceDescription:(AXMediaUploadServiceDescription *)serviceDescription;

@optional
- (NSArray *)uploadController:(AXMediaUploadController *)controller
      filterAvailableServices:(NSArray *)availableServices;

@end

@protocol AXMediaUploadControllerDelegate <NSObject>

// TODO: Never called
- (void)uploadController:(AXMediaUploadController *)controller
 requiresAccountCreation:(UIViewController *)accountCreationViewController;

- (void)uploadController:(AXMediaUploadController *)controller
           selectService:(void (^)(AXMediaUploadServiceDescription *))serviceSelectionContinuation
           fromAvailable:(NSArray *)availableServiceDescriptions;

@optional
- (void)uploadController:(AXMediaUploadController *)controller
  prepareUploadOperation:(AXMediaUploadOperation *)operation;

@end
