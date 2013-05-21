//
//  JSAppDelegate.m
//  JSPebbleReminders
//
//  Created by Javier Soto on 5/17/13.
//  Copyright (c) 2013 Javier Soto. All rights reserved.
//

#import "JSAppDelegate.h"

#import "JSViewController.h"

#import "JSPebbleInterface.h"

@implementation JSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [[JSPebbleInterface defaultInterface] startListening];

    self.viewController = [[JSViewController alloc] init];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
