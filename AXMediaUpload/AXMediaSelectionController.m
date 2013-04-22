//
//  AXMediaSelectionController.m
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import "AXMediaSelectionController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ALAssetsLibrary+AXMediaUpload.h"
#import "AXMediaSelection.h"

#define LAZY_GETTER(TYPE, NAME) \
- (TYPE)NAME { return (_##NAME = (_##NAME) ?: [self _lazyLoad_##NAME]); } \
- (TYPE)_lazyLoad_##NAME

@interface AXMediaSelectionController () <
    UIActionSheetDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate
>

@property (nonatomic, strong, readwrite) UIViewController * hostViewController;
@property (nonatomic, strong, readwrite) UIBarButtonItem * hostBarButtonItem;
@property (nonatomic, readwrite) AXMediaCategory categories;

@property (nonatomic, strong, readwrite) NSArray * actionCallbacks;
@property (nonatomic, strong, readwrite) NSArray * actionTitles;
@property (nonatomic, strong) UIActionSheet * actionSheet;
@property (nonatomic, strong) UIImagePickerController * imagePickerController;
@property (nonatomic, strong) ALAssetsLibrary * assetsLibrary;

@end

@implementation AXMediaSelectionController

- (id)initWithDelegate:(id <AXMediaSelectionControllerDelegate>)delegate
        viewController:(UIViewController *)viewController
         barButtonItem:(UIBarButtonItem *)item
            categories:(AXMediaCategory)categories;
{
    if (!(self = [super init]))
        return nil;
    
    self.delegate = delegate;
    self.hostViewController = viewController;
    self.hostBarButtonItem = item;
    self.categories = categories;
    
    return self;
}

LAZY_GETTER(ALAssetsLibrary *, assetsLibrary)
{
    return [[ALAssetsLibrary alloc] init];
}

#pragma mark - Selection Presentation

- (void)present:(BOOL)animated
{
    [self cancel:NO];
    [self.actionSheet showFromBarButtonItem:self.hostBarButtonItem animated:animated];
}

- (void)cancel:(BOOL)animated
{    
    [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:animated];
}

LAZY_GETTER(UIActionSheet *, actionSheet);
{
    UIActionSheet * actionSheet = [UIActionSheet new];
    actionSheet.delegate = self;
    actionSheet.tag = self.categories;
    
    for (NSString * title in self.actionTitles)
        [actionSheet addButtonWithTitle:title];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    return actionSheet;
}

#pragma mark - Callbacks

LAZY_GETTER(NSArray *, actionCallbacks);
{
    __weak __typeof(self) _self = self;
    return @[[^{ [_self _selectLastSavedCallback]; } copy],
             [^{ [_self _selectNewCallback]; } copy],
             [^{ [_self _selectExistingCallback]; } copy]];
}

LAZY_GETTER(NSArray *, actionTitles);
{
    if ((self.categories & AXMediaCategoryImage)
        && (self.categories & AXMediaCategoryVideo))
        return @[NSLocalizedString(@"Last Saved Media", nil),
                 NSLocalizedString(@"Take Photo or Video", nil),
                 NSLocalizedString(@"Choose Existing", nil)];
    
    if (self.categories & AXMediaCategoryImage)
        return @[NSLocalizedString(@"Last Saved Photo", nil),
                 NSLocalizedString(@"Take Photo", nil),
                 NSLocalizedString(@"Choose Existing", nil)];
    
    if (self.categories & AXMediaCategoryVideo)
        return @[NSLocalizedString(@"Last Saved Video", nil),
                 NSLocalizedString(@"Take Video", nil),
                 NSLocalizedString(@"Choose Existing", nil)];
    
    return nil;
}

- (ALAssetsFilter *)_assetsFilter
{
    if ((self.categories & AXMediaCategoryImage)
        && (self.categories & AXMediaCategoryVideo))
        return [ALAssetsFilter allAssets];
    
    if (self.categories & AXMediaCategoryImage)
        return [ALAssetsFilter allPhotos];
    
    if (self.categories & AXMediaCategoryVideo)
        return [ALAssetsFilter allVideos];
    
    return nil;
}

- (void)_selectLastSavedCallback;
{
    [self.assetsLibrary lastSavedAsset:^(ALAsset *asset, NSError * error) {
        if (!asset)
        {
            [self.delegate selectionController:self encounteredError:error];
            return;
        }
        
        [AXMediaSelection selectionWithAsset:asset result:^(AXMediaSelection * selection) {
            [self.delegate selectionController:self didMakeSelection:selection];
        }];
    } withFilter:[self _assetsFilter]];
}

- (void)_selectNewCallback;
{
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.hostViewController presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)_selectExistingCallback;
{
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.hostViewController presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex == buttonIndex)
        return;
    
    ((void (^)())self.actionCallbacks[buttonIndex])();
}

#pragma mark - UIImagePickerControllerDelegate

LAZY_GETTER(UIImagePickerController *, imagePickerController);
{
    UIImagePickerController * controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.view.backgroundColor = [UIColor blackColor];
    
    NSMutableArray * mediaTypes = [NSMutableArray arrayWithCapacity:2];
    if (AXMediaCategoryImage & self.categories)
        [mediaTypes addObject:(NSString *)kUTTypeImage];
    if (AXMediaCategoryVideo & self.categories)
        [mediaTypes addObject:(NSString *)kUTTypeMovie];
    
    controller.mediaTypes = mediaTypes;
    
    return controller;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    if (info[UIImagePickerControllerMediaURL])
    {
        [self.delegate selectionController:self didMakeSelection:
         [AXMediaSelection selectionWithFileURL:info[UIImagePickerControllerMediaURL] makeTemporaryCopy:NO]];
    }
    else if (info[UIImagePickerControllerReferenceURL])
    {
        [AXMediaSelection selectionWithAssetURL:info[UIImagePickerControllerReferenceURL] result:^(AXMediaSelection * selection) {
            [self.delegate selectionController:self didMakeSelection:selection];
        }];
    }
    else if (self.automaticallyWritesNewMediaToCameraRoll)
    {
        CGImageRef image = ((UIImage *)info[UIImagePickerControllerOriginalImage]).CGImage;
        NSDictionary * metadata = info[UIImagePickerControllerMediaMetadata];
        id completionBlock = ^(NSURL * assetURL, NSError * error) {
            if (!assetURL)
            {
                [self.delegate selectionController:self encounteredError:error];
                return;
            }
            
            [AXMediaSelection selectionWithAssetURL:assetURL result:^(AXMediaSelection * selection) {
                [self.delegate selectionController:self didMakeSelection:selection];
            }];
        };
        
        [self.assetsLibrary writeImageToSavedPhotosAlbum:image metadata:metadata completionBlock:completionBlock];
    }
    else
    {
        [self.delegate selectionController:self didMakeSelection:
         [AXMediaSelection selectionWithImage:info[UIImagePickerControllerOriginalImage]]];
    }
    
    [self.hostViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.hostViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
