//
//  AXAppDemoViewController.m
//  AXMediaUploadController
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import "AXAppDemoViewController.h"
#import "AXMediaUpload.h"

@interface AXAppDemoViewController ()

@property (nonatomic, strong) IBOutlet UIImageView * imageView;
@property (nonatomic, strong) IBOutlet UIToolbar * mediaSelectBar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * mediaSelectButtonItem;
@property (nonatomic, strong) IBOutlet UILabel * mediaUploadLabel;
@property (nonatomic, strong) IBOutlet UIProgressView * mediaUploadProgressView;

@end

@implementation AXAppDemoViewController

- (id)init
{
    return [super initWithNibName:NSStringFromClass([AXAppDemoViewController class]) bundle:nil];
}

#pragma mark - Controller Workflow

- (IBAction)selectMedia:(id)sender
{
    
}

@end
