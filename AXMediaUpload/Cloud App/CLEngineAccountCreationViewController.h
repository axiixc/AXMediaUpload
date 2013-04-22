//
//  CLEngineAccountCreationViewController.h
//  Firefly
//
//  Created by James Savage on 1/2/13.
//  Copyright (c) 2013 axiixc.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXMediaUploadServiceCreationViewController.h"

@class CLEngine;

@interface CLEngineAccountCreationViewController : AXMediaUploadServiceCreationViewController

- (id)initWithEngine:(CLEngine *)engine;

@end
