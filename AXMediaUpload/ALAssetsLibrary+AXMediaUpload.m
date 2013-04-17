//
//  FFAssetsLibraryHelpers.m
//  Firefly
//
//  Created by James Savage on 1/1/13.
//  Copyright (c) 2013 axiixc.com. All rights reserved.
//

#import "ALAssetsLibrary+AXMediaUpload.h"

@implementation ALAssetsLibrary (AXMediaUpload)

+ (void)fetchLastSavedAsset:(void (^)(ALAsset * asset))completionBlock;
{
    NSParameterAssert(completionBlock);
    
    if ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusAuthorized)
    {
        completionBlock(nil);
        return;
    }
    
    __block BOOL didFindMedia = NO;
    [[self new] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup * group, BOOL *stop) {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        if ([group numberOfAssets] != 0)
        {
            NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:[group numberOfAssets] - 1];
            id block = ^(ALAsset * alAsset, NSUInteger index, BOOL *innerStop) {
                if (alAsset)
                {
                    didFindMedia = YES;
                    completionBlock(alAsset);
                }
            };
            
            [group enumerateAssetsAtIndexes:indexSet options:0 usingBlock:block];
        }
        
        if (group == nil && !didFindMedia)
            completionBlock(nil);
    } failureBlock:^(NSError * error) {
        completionBlock(nil);
    }];
}

@end
