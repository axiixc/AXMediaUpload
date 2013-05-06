//
//  AXMediaUploadControllerKeychainDataSource.m
//  DemoApp
//
//  Created by James Savage on 4/22/13.
//  Copyright (c) 2013 James Savage <me@axiixc.com>. All rights reserved.
//

#import "AXMediaUploadControllerKeychainDataSource.h"
#import <Security/Security.h>

@implementation AXMediaUploadControllerKeychainDataSource

+ (instancetype)dataSource;
{
    return [[self alloc] init];
}

#pragma mark - AXMediaUploadControllerKeychainDataSource

//- (NSDictionary *)uploadController:(AXMediaUploadController *)controller credentialsForServiceClass:(Class)serviceClass
//{
//    return nil;
//}
//
//- (void)uploadController:(AXMediaUploadController *)controller selectServiceClass:(NSArray *)availableServiceClasses withContinuation:(void (^)(__unsafe_unretained Class))continuation
//{
//    
//}
//
//- (void)uploadController:(AXMediaUploadController *)controller setCredentials:(NSDictionary *)credentials forService:(id<AXMediaUploadService>)service
//{
//    NSData * credentialData = [NSKeyedArchiver archivedDataWithRootObject:credentialData];
//
//    NSMutableDictionary * keychainQuery = @{
//                                            (__bridge_transfer NSString *)kSecClass: (__bridge_transfer NSString *)kSecClassGenericPassword,
//                                            (__bridge_transfer NSString *)kSecAttrService: self.serviceName,
//                                            (__bridge_transfer NSString *)kSecAttrAccount: self.accountName,
//                                            }.mutableCopy;
//    
//    if (shouldReturnData)
//    {
//        [keychainQuery setObject:(__bridge_transfer NSString *)kCFBooleanTrue
//                          forKey:(__bridge_transfer NSString *)kSecReturnData];
//    }
//}

@end
