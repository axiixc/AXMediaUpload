//
//  AXMediaUploadControllerKeychainDataSource.h
//  DemoApp
//
//  Created by James Savage on 4/22/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXMediaUploadController.h"

@interface AXMediaUploadControllerKeychainDataSource : NSObject <AXMediaUploadControllerDataSource>

+ (instancetype)dataSource;

@end
