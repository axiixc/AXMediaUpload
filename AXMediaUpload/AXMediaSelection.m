//
//  AXMediaSelection.m
//  DemoApp
//
//  Created by James Savage on 4/16/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import "AXMediaSelection.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface AXMediaSelection ()

@property (nonatomic, strong) NSURL * fileURL;
@property (nonatomic, readwrite) AXMediaType mediaType;

@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;
@property (nonatomic, strong) ALAsset * asset;

@end

@implementation AXMediaSelection

+ (instancetype)selectionWithFileURL:(NSURL *)fileURL makeTemporaryCopy:(BOOL)makeTemp;
{
    AXMediaSelection * selection = [self new];
    selection.fileURL = fileURL;
    
    if (makeTemp)
    {
        selection.fileURL = [self uniqueTemporaryURL];
        
        NSError * __autoreleasing error = nil;
        BOOL success = [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:selection.fileURL error:&error];
        
        if (!success || error)
            return nil;
    }
    
    return selection;
}

+ (instancetype)selectionWithImage:(UIImage *)image;
{
    AXMediaSelection * selection = [self new];
    selection.mediaType = AXMediaTypeImage;
    selection.fileURL = [self uniqueTemporaryURL];
    
    [UIImageJPEGRepresentation(image, 1.0) writeToURL:selection.fileURL atomically:YES];
    
    return selection;
}

+ (void)selectionWithAssetURL:(NSURL *)assetURL result:(void (^)(AXMediaSelection *))resultBlock
{
    AXMediaSelection * selection = [[self alloc] init];
    selection.assetLibrary = [[ALAssetsLibrary alloc] init];
    
    [selection.assetLibrary assetForURL:assetURL resultBlock:^(ALAsset * asset) {
        selection.asset = asset;
        resultBlock(selection);
    } failureBlock:^(NSError * error) {
        resultBlock(nil);
    }];
}

+ (void)selectionWithAsset:(ALAsset *)asset result:(void (^)(AXMediaSelection *))resultBlock
{
    [self selectionWithAssetURL:[asset valueForProperty:ALAssetPropertyAssetURL] result:resultBlock];
}

+ (NSURL *)uniqueTemporaryURL
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    CFRelease(uuid);
    
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:uuidString] isDirectory:YES];
}

- (void)setAsset:(ALAsset *)asset
{
    if (_asset == asset)
        return;
    
    _asset = asset;
    
    NSString * assetType = [asset valueForProperty:ALAssetPropertyType];
    if ([ALAssetTypePhoto isEqualToString:assetType])
        self.mediaType = AXMediaTypeImage;
    
    if ([ALAssetTypeVideo isEqualToString:assetType])
        self.mediaType = AXMediaTypeVideo;
}

- (void)fullScreenImage:(void (^)(UIImage * image))resultBlock;
{
    if ([[self.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
        resultBlock([UIImage imageWithCGImage:self.asset.defaultRepresentation.fullScreenImage]);
    
    [self fullResolutionImage:resultBlock];
}

- (void)fullResolutionImage:(void (^)(UIImage * image))resultBlock;
{
    if ([[self.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]
        || self.mediaType == AXMediaTypeVideo
        || self.mediaType == AXMediaTypeInvalid)
    {
        [self _generateVideoThumbnail:resultBlock];
    }
    else if ([[self.asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
    {
        resultBlock([UIImage imageWithCGImage:self.asset.defaultRepresentation.fullResolutionImage]);
    }
    else
    {
        resultBlock([UIImage imageWithContentsOfFile:[self.fileURL path]]);   
    }
}

- (NSString *)genericFilenameSuggestion
{
    NSString * fileExtension = [(NSURL *)[self.asset valueForProperty:ALAssetPropertyAssetURL] pathExtension];
    return [[[NSDate date] description] stringByAppendingPathExtension:fileExtension];
}

- (void)_generateVideoThumbnail:(void (^)(UIImage * thumbnail))resultBlock
{
    AVURLAsset * asset = [[AVURLAsset alloc] initWithURL:self.fileURL options:nil];
    AVAssetImageGenerator * generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = [[UIScreen mainScreen] bounds].size;
    
    CMTime duration = ((AVAssetTrack *)asset.tracks[0]).timeRange.duration;
    CMTime thumbTime = CMTimeMultiplyByFloat64(duration, 0.25);
    id handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * error)
    {
        if (result == AVAssetImageGeneratorSucceeded)
            resultBlock([UIImage imageWithCGImage:im]);
        else resultBlock(nil);
    };
    
    [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:thumbTime]]
                                    completionHandler:handler];
}

- (NSString *)_mimeTypeForFileAtPath:(NSURL *)fileURL
{
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[fileURL pathExtension], NULL);
    NSString * MIMEType = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    CFRelease(UTI);
    
    return (MIMEType) ?: @"application/octet-stream";
}

- (void)getDataURL:(void (^)(NSURL *, NSString *))resultBlock;
{
    NSParameterAssert(resultBlock);
    
    if (self.fileURL)
    {
        resultBlock(self.fileURL, [self _mimeTypeForFileAtPath:self.fileURL]);
        return;
    }
    
    ALAssetRepresentation * rep = [self.asset defaultRepresentation];
    if (!rep)
    {
        resultBlock(nil, nil);
        return;
    }
    
    NSError * __autoreleasing error = nil;
    
    NSString * fileExtension = [(NSURL *)[self.asset valueForProperty:ALAssetPropertyAssetURL] pathExtension];
    self.fileURL = [[[self class] uniqueTemporaryURL] URLByAppendingPathExtension:fileExtension];
    [[NSFileManager defaultManager] createFileAtPath:[self.fileURL path] contents:nil attributes:nil];
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingToURL:self.fileURL error:&error];
    
    NSUInteger bufferLength = 1024 * 1024;
    Byte * buffer = malloc(bufferLength);
    
    NSUInteger fileLength = [rep size];
    NSUInteger offset = 0;
    do {
        NSUInteger bytesCopied = [rep getBytes:buffer fromOffset:offset length:bufferLength error:nil];
        [handle writeData:[NSData dataWithBytesNoCopy:buffer length:bytesCopied]];
        
        offset += bytesCopied;
    } while (offset < fileLength);
    
    [handle closeFile];
    free(buffer);
    buffer = NULL;
    
    resultBlock(self.fileURL, [self _mimeTypeForFileAtPath:self.fileURL]);
}

@end