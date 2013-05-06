//
//  AXMediaUploadTypedefs.h
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

typedef NS_OPTIONS(NSInteger, AXMediaCategory) {
    AXMediaCategoryImage = 1 << 0,
    AXMediaCategoryVideo = 1 << 1,
    AXMediaCategoryDefault = AXMediaCategoryImage | AXMediaCategoryVideo
};

typedef NS_ENUM(NSInteger, AXMediaType) {
    AXMediaTypeInvalid = 0,
    AXMediaTypeImage,
    AXMediaTypeVideo,
};

#define AXIsEmptyString(STR) ((STR) == nil || [@"" isEqualToString:(STR)])

extern BOOL AXMediaCategoriesContainsType(AXMediaCategory categories, AXMediaType type);

typedef void (^AXMediaUploadProgressBlock)(double progress);
typedef void (^AXMediaUploadCompletionBlock)(NSURL * linkURL, NSURL * embedURL, NSString * embedString);
typedef void (^AXMediaUploadErrorBlock)(NSError * error);
