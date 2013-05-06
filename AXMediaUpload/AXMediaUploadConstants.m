//
//  AXMediaUploadTypedefs.h
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import "AXMediaUploadConstants.h"

extern BOOL AXMediaCategoriesContainsType(AXMediaCategory categories, AXMediaType type)
{
    switch (type)
    {
        case AXMediaTypeImage: return (categories & AXMediaCategoryImage);
        case AXMediaTypeVideo: return (categories & AXMediaCategoryVideo);
        default: return NO;
    }
}
