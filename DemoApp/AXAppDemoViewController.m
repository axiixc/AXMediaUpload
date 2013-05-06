//
//  AXAppDemoViewController.m
//  AXMediaUploadController
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import "AXAppDemoViewController.h"
#import "AXMediaUpload.h"

@interface AXAppDemoViewController () <
    AXMediaSelectionControllerDelegate,
    AXMediaUploadControllerDataSource,
    AXMediaUploadControllerDelegate,
    UIActionSheetDelegate
>

@property (nonatomic, strong) IBOutlet UIImageView * imageView;
@property (nonatomic, strong) IBOutlet UIToolbar * mediaSelectBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * mediaSelectButtonItem;
@property (nonatomic, strong) IBOutlet UILabel * mediaUploadLabel;
@property (nonatomic, strong) IBOutlet UIProgressView * mediaUploadProgressView;

@property (nonatomic, strong) AXMediaSelectionController * selectionController;
@property (nonatomic, strong) AXMediaUploadController * uploadController;
@property (nonatomic, strong) AXMediaSelection * lastSelection;
@property (nonatomic, strong) AXMediaUploadOperation * lastOperation;
@property (nonatomic, copy) void (^serviceSelectionContinuation)(NSInteger index);

@end

@implementation AXAppDemoViewController

- (id)init
{
    if (!(self = [super initWithNibName:NSStringFromClass([AXAppDemoViewController class]) bundle:nil]))
        return nil;
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self _updateLabels];
}

- (void)_updateLabels
{
    if (!self.lastSelection)
        self.mediaUploadLabel.text = @"Select something to upload";
    
    if (self.lastSelection)
        self.mediaUploadLabel.text = @"Okay, now press upload";
}

- (void)setLastSelection:(AXMediaSelection *)lastSelection
{
    _lastSelection = lastSelection;
    [self _updateLabels];
}

- (void)setLastOperation:(AXMediaUploadOperation *)lastOperation
{
    _lastOperation = lastOperation;
    [self _updateLabels];
}

#pragma mark - Controller Workflow

- (IBAction)selectMedia:(id)sender
{
    [self.selectionController present:YES];
}

- (IBAction)uploadMedia:(id)sender
{
    if (!self.lastSelection)
        return;
    
    [self.uploadController uploadOperationForSelection:self.lastSelection continuation:^(AXMediaUploadOperation * operation) {
        self.lastOperation = operation;
    }];
}

- (IBAction)cancelUpload:(id)sender
{
    [self.lastOperation cancelUpload];
}

#pragma mark - AXMediaSelectionControllerDelegate

- (AXMediaSelectionController *)selectionController
{
    return (_selectionController = (_selectionController) ?: [[AXMediaSelectionController alloc]
                                                              initWithDelegate:self
                                                              viewController:self
                                                              barButtonItem:self.mediaSelectButtonItem
                                                              categories:AXMediaCategoryDefault]);
}

- (void)selectionController:(AXMediaSelectionController *)controller didMakeSelection:(AXMediaSelection *)selection
{
    self.lastSelection = selection;
    
    [selection fullScreenImage:^(UIImage *image) {
        self.imageView.image = image;
    }];
}

- (void)selectionController:(AXMediaSelectionController *)controller encounteredError:(NSError *)error
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex == buttonIndex)
        return;
    
    self.serviceSelectionContinuation(buttonIndex);
}

#pragma mark - AXMediaUploadControllerDataSource

- (AXMediaUploadController *)uploadController
{
    return (_uploadController = (_uploadController) ?: [[AXMediaUploadController alloc]
                                                        initWithDataSource:self
                                                        delegate:self]);
}

- (NSDictionary *)uploadController:(AXMediaUploadController *)controller
  credentialsForServiceDescription:(AXMediaUploadServiceDescription *)servieDescription
{
    return @{ @"username": @"<#your username here#>", @"password": @"<#your password here#>" };
}

- (void)uploadController:(AXMediaUploadController *)controller
          setCredentials:(NSDictionary *)credentials
              forService:(id <AXMediaUploadService>)service;
{
    
}

#pragma mark - AXMediaUploadControllerDelegate

- (void)uploadController:(AXMediaUploadController *)controller
 requiresAccountCreation:(UIViewController *)accountCreationViewController;
{
    [self presentViewController:accountCreationViewController animated:YES completion:nil];
}

- (void)uploadController:(AXMediaUploadController *)controller
           selectService:(void (^)(AXMediaUploadServiceDescription *))serviceSelectionContinuation
           fromAvailable:(NSArray *)availableServiceDescriptions
{
    NSAssert(NO, @"This shouldn't be called yet");
}

@end
