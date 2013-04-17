//
//  AXAppDemoViewController.m
//  AXMediaUploadController
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import "AXAppDemoViewController.h"
#import "AXMediaUpload.h"

@interface AXAppDemoViewController () <AXMediaSelectionControllerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView * imageView;
@property (nonatomic, strong) IBOutlet UIToolbar * mediaSelectBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * mediaSelectButtonItem;
@property (nonatomic, strong) IBOutlet UILabel * mediaUploadLabel;
@property (nonatomic, strong) IBOutlet UIProgressView * mediaUploadProgressView;

@property (nonatomic, strong) AXMediaSelectionController * selectionController;
@property (nonatomic, strong) AXMediaSelection * lastSelection;

@end

@implementation AXAppDemoViewController

- (id)init
{
    if (!(self = [super initWithNibName:NSStringFromClass([AXAppDemoViewController class]) bundle:nil]))
        return nil;
    
    return self;
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
    
    NSLog(@"TODO: AXMediaUploadController");
}

- (IBAction)cancelUpload:(id)sender
{
    NSLog(@"TODO: AXMediaUploadController");    
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
    
    [selection imageContents:^(UIImage *image) {
        self.imageView.image = image;
    }];
}

@end
