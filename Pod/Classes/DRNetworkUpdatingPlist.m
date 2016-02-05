//
//  DRNetworkUpdatingPlist.m
//  DoradaCore
//
//  Created by Daniel Broad on 11/02/2014.
//  Copyright (c) 2014 Dorada. All rights reserved.
//

#import "DRNetworkUpdatingPlist.h"

@interface DRNetworkUpdatingPlist ()

@property (strong) NSURL* root;
@property (strong) NSString *plistName;

@end

@implementation DRNetworkUpdatingPlist {
    NSDictionary *_cached;
}

-(id) initWithRootURL: (NSURL*) root name: (NSString*) plistName {
    self = [super init];
    if (self) {
        self.root = root;
        self.plistName = [plistName stringByDeletingPathExtension]; // extension must be plist
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self needsUpdate]) {
                [self updateFromNetwork];
            }
        });

    }
    return self;
}

#pragma mark - getters

-(id) objectForKey:(NSString *)key {
    
    if (!_cached) {
        NSString *docsPath = [[self applicationHiddenDocumentsDirectory] stringByAppendingPathComponent:[self plistNameWithExtension]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:docsPath isDirectory:nil]) {
            _cached = [NSDictionary dictionaryWithContentsOfFile:docsPath];
        }
        
        if (!_cached) {
            _cached = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.plistName ofType:@"plist"]];
        }
    }
    
    return [_cached objectForKey:key];
}

-(NSInteger) integerForKey: (NSString*) key {
    NSNumber *number = [self objectForKey:key];
    return [number integerValue];
}

#pragma mark - utils

-(NSString*) plistNameWithExtension {
    return [self.plistName stringByAppendingPathExtension:@"plist"];
}

- (void) wasUpdated {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"DRNetworkUpdatingPlist-%@-Update",self.plistName]];
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject: version forKey:[NSString stringWithFormat:@"DRNetworkUpdatingPlist-%@-AppVersion",self.plistName]];
}

- (BOOL) needsUpdate {
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"DRNetworkUpdatingPlist-%@-Update",self.plistName]];
    
    NSString *previousAppVersion = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"DRNetworkUpdatingPlist-%@-AppVersion",self.plistName]];
    
    if (!lastUpdate && !previousAppVersion) {
        return YES;
    }
    
    if ([lastUpdate compare:[NSDate dateWithTimeIntervalSinceNow:-60*60*24*7]] == NSOrderedAscending) {
        return YES;
    }
    
    if ([self.delegate respondsToSelector:@selector(networkUpdatingPlistShouldUpdateFromNetwork:)]) {
        BOOL canUpdate = [self.delegate networkUpdatingPlistShouldUpdateFromNetwork:self];
        if (!canUpdate) {
            return NO;
        }
    }
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (![previousAppVersion isEqualToString:version]) {
        NSString *docsPath = [[self applicationHiddenDocumentsDirectory] stringByAppendingPathComponent:[self plistNameWithExtension]];
        [[NSFileManager defaultManager] removeItemAtPath:docsPath error:nil];
        return YES;
    }
    
    return NO;
}

- (NSString *)applicationHiddenDocumentsDirectory {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [libraryPath stringByAppendingPathComponent:@"Private Documents"];
    
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (isDirectory)
            return path;
        else {
            [NSException raise:@".data exists, and is a file" format:@"Path: %@", path];
        }
    }
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
        [NSException raise:@"Failed creating directory" format:@"[%@], %@", path, error];
    }
    return path;
}

-(void) updateFromNetwork {
    NSURL *url = [self.root URLByAppendingPathComponent: [self plistNameWithExtension]];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:url];
    if ([NSURLConnection respondsToSelector:@selector(sendAsynchronousRequest:queue:completionHandler:)]) {
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   NSHTTPURLResponse *httpresponse = (NSHTTPURLResponse*) response;
                                   if (error == nil && httpresponse.statusCode == 200)
                                   {
                                       // Parse data here
                                       NSString *filePath = [[self applicationHiddenDocumentsDirectory] stringByAppendingPathComponent: [self plistNameWithExtension]];
                                       [data writeToFile:filePath atomically:YES];
                                       NSError *error;
                                       [[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey: NSFileProtectionNone} ofItemAtPath:filePath error:&error];
                                       if (error) {
                                           NSLog(@"Could not set file protection off %@ %@",filePath,error.localizedDescription);
                                       }
                                       _cached = nil;
                                       [self wasUpdated];
                                   }
                               }];
    }
}
@end
