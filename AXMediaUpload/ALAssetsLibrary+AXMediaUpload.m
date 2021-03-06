//
//  FFAssetsLibraryHelpers.m
//  Firefly
//
//  Created by James Savage on 1/1/13.
//  Copyright (c) 2013 axiixc.com. All rights reserved.
//

#import "ALAssetsLibrary+AXMediaUpload.h"

@implementation ALAssetsLibrary (AXMediaUpload)

- (void)lastSavedAsset:(void (^)(ALAsset * asset, NSError * error))completionBlock withFilter:(ALAssetsFilter *)filter;
{
    NSParameterAssert(completionBlock);
    
    __block BOOL didFindMedia = NO;
    [self enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup * group, BOOL *stop) {
        [group setAssetsFilter:filter];
        
        if ([group numberOfAssets] == 0)
            return;
        
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:[group numberOfAssets] - 1];
        [group enumerateAssetsAtIndexes:indexSet options:0 usingBlock:^(ALAsset * alAsset, NSUInteger index, BOOL *innerStop) {
            if (!alAsset)
                return;
        
            didFindMedia = YES;
            completionBlock(alAsset, nil);
        }];
        
        if (group == nil && !didFindMedia)
            completionBlock(nil, nil);
    } failureBlock:^(NSError * error) {
        completionBlock(nil, error);
    }];
}

@end
