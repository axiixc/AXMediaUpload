//
//  AXMediaSelection.h
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AXMediaUploadConstants.h"

@interface AXMediaSelection : NSObject

+ (instancetype)selectionWithFileURL:(NSURL *)fileURL makeTemporaryCopy:(BOOL)makeTemp;
+ (instancetype)selectionWithImage:(UIImage *)image;

+ (void)selectionWithAssetURL:(NSURL *)assetURL result:(void (^)(AXMediaSelection * selection))resultBlock;
+ (void)selectionWithAsset:(ALAsset *)asset result:(void (^)(AXMediaSelection * selection))resultBlock;

@property (nonatomic, readonly) AXMediaType mediaType;

@property (nonatomic, strong, readonly) NSString * filenameSuggestion;

- (NSString *)genericFilenameSuggestion;

- (void)fullScreenImage:(void (^)(UIImage * image))resultBlock;
- (void)fullResolutionImage:(void (^)(UIImage * image))resultBlock;

- (void)getDataURL:(void (^)(NSURL * dataURL, NSString * mimeType))resultBlock;

@end
