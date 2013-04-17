//
//  FFAssetsLibraryHelpers.h
//  Firefly
//
//  Created by James Savage on 1/1/13.
//  Copyright (c) 2013 axiixc.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (AXMediaUpload)

+ (void)fetchLastSavedAsset:(void (^)(ALAsset * asset))completionBlock;

@end
