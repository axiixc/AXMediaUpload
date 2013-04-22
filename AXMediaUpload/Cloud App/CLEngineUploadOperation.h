//
//  CLEngineUploadToken.h
//  Firefly
//
//  Created by James Savage on 1/3/13.
//  Copyright (c) 2013 axiixc.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "AXMediaUploadOperation.h"

@class CLEngine;

@interface CLEngineUploadOperation : AXMediaUploadOperation

@property (nonatomic, strong) AFHTTPRequestOperation * s3Params;
@property (nonatomic, strong) AFHTTPRequestOperation * s3Upload;

@end
