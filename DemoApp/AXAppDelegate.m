//
//  AXAppDelegate.m
//  AXMediaUploadController
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import "AXAppDelegate.h"
#import "AXAppDemoViewController.h"

@implementation AXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [AXAppDemoViewController new];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
