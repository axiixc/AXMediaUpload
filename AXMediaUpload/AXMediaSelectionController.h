//
//  AXMediaSelectionController.h
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AXMediaUploadConstants.h"

@protocol AXMediaSelectionControllerDelegate;
@class AXMediaSelection;

@interface AXMediaSelectionController : NSObject

@property (nonatomic, weak) id <AXMediaSelectionControllerDelegate> delegate;

@property (nonatomic, strong, readonly) UIViewController * hostViewController;
@property (nonatomic, strong, readonly) UIBarButtonItem * hostBarButtonItem;
@property (nonatomic, readonly) AXMediaCategory categories;

@property (nonatomic, strong, readonly) NSArray * actionCallbacks;
@property (nonatomic, strong, readonly) NSArray * actionTitles;

@property (nonatomic) BOOL automaticallyWritesNewMediaToCameraRoll;

- (id)initWithDelegate:(id <AXMediaSelectionControllerDelegate>)delegate
        viewController:(UIViewController *)viewController
         barButtonItem:(UIBarButtonItem *)item
            categories:(AXMediaCategory)categories;

- (void)present:(BOOL)animated;
- (void)cancel:(BOOL)animated;

@end

@protocol AXMediaSelectionControllerDelegate <NSObject>

- (void)selectionController:(AXMediaSelectionController *)controller didMakeSelection:(AXMediaSelection *)selection;
- (void)selectionController:(AXMediaSelectionController *)controller encounteredError:(NSError *)error;

@end