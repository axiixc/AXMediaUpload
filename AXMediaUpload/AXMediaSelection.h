//
//  AXMediaSelection.h
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AXMediaSelection : NSObject

+ (instancetype)selectionWithURL:(NSURL *)url;
+ (instancetype)selectionWithAsset:(ALAsset *)asset;
+ (instancetype)selectionWithImage:(UIImage *)image;

- (void)imageContents:(void (^)(UIImage * image))resultBlock;

@end
