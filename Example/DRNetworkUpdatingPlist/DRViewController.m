//
//  DRViewController.m
//  DRNetworkUpdatingPlist
//
//  Created by Daniel Broad on 02/05/2016.
//  Copyright (c) 2016 Daniel Broad. All rights reserved.
//

#import "DRViewController.h"

#import "DRNetworkUpdatingPlist.h"

@interface DRViewController ()

@end

@implementation DRViewController {
    DRNetworkUpdatingPlist *myPlist;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    myPlist = [[DRNetworkUpdatingPlist alloc] initWithRootURL:[NSURL URLWithString:@""] name:@"test.plist"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:[NSString stringWithFormat:@"Got Value %d",[myPlist integerForKey:@"test"]]
                                                    delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                    otherButtonTitles:nil];
    [alert show];
}
@end
