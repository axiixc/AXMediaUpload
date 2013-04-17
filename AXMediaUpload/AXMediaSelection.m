//
//  AXMediaSelection.m
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import "AXMediaSelection.h"

@interface AXMediaSelection ()

@property (nonatomic, strong) NSURL * assetURL;
@property (nonatomic, strong) ALAsset * asset;
@property (nonatomic, strong) UIImage * image;

@end

@implementation AXMediaSelection

+ (instancetype)selectionWithURL:(NSURL *)url;
{
    AXMediaSelection * selection = [self new];
    selection.assetURL = url;
    
    return selection;
}

+ (instancetype)selectionWithAsset:(ALAsset *)asset;
{
    AXMediaSelection * selection = [self new];
    selection.asset = asset;
    
    return selection;
}

+ (instancetype)selectionWithImage:(UIImage *)image;
{
    AXMediaSelection * selection = [self new];
    selection.image = image;
    
    return selection;
}

#pragma mark - Public Methods

- (void)imageContents:(void (^)(UIImage * image))resultBlock;
{
    NSParameterAssert(resultBlock);
    
    if (self.image)
    {
        resultBlock(self.image);
    }
    else if (self.asset)
    {
        resultBlock([UIImage imageWithCGImage:self.asset.defaultRepresentation.fullResolutionImage]);
    }
    else
    {
        [[ALAssetsLibrary new] assetForURL:self.assetURL resultBlock:^(ALAsset * asset) {
            self.asset = asset;
            [self imageContents:resultBlock];
        } failureBlock:^(NSError *error) {
            resultBlock(nil);
        }];
    }
}

@end