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

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    __block UIBackgroundTaskIdentifier task = 0;

    task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:task];
    }];

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [[JSPebbleInterface defaultInterface] ping];

        [[UIApplication sharedApplication] endBackgroundTask:task];
    });
}

@end
