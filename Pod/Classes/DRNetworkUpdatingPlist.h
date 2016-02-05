//
//  DRNetworkUpdatingPlist.h
//  DoradaCore
//
//  Created by Daniel Broad on 11/02/2014.
//  Copyright (c) 2014 Dorada. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRNetworkUpdatingPlist;

@protocol DRNetworkUpdatingPlistDelegate <NSObject>

-(BOOL) networkUpdatingPlistShouldUpdateFromNetwork: (DRNetworkUpdatingPlist*) plist;

@end
@interface DRNetworkUpdatingPlist : NSObject

-(id) initWithRootURL: (NSURL*) root name: (NSString*) plistName;

@property (readonly) NSURL* root;
@property (readonly) NSString *plistName;
@property (weak) id<DRNetworkUpdatingPlistDelegate> delegate;

-(id) objectForKey:(NSString *)key;
-(NSInteger) integerForKey: (NSString*) key;

@end
