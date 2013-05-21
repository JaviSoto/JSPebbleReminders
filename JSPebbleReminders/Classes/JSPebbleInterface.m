//
//  JSPebbleInterface.m
//  JSPebbleReminders
//
//  Created by Javier Soto on 5/17/13.
//  Copyright (c) 2013 Javier Soto. All rights reserved.
//

#import "JSPebbleInterface.h"

#import <PebbleKit/PebbleKit.h>
#import "JSPebbleReminders.h"

static const uint8_t pebbleAppUUID[] = { 0x3C, 0xB4, 0x32, 0xD0, 0xD2, 0xF8, 0x44, 0x63, 0xA6, 0xC4, 0x36, 0xE0, 0xC5, 0x32, 0xB0, 0x50 };

@interface JSPebbleInterface () <PBPebbleCentralDelegate>

@property (nonatomic, strong) PBWatch *watch;

@end

@implementation JSPebbleInterface

+ (instancetype)defaultInterface
{
    static JSPebbleInterface *defaultInterface = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultInterface = [[self alloc] init];
    });

    return defaultInterface;
}

- (void)displayNoWatchErrorAlert
{
    showErrorAlertWithMessage(@"There's no watch connected. Check your bluetooth connection");
}

- (void)startListening
{
    PBWatch *lastWatch = [PBPebbleCentral defaultCentral].lastConnectedWatch;

    if (lastWatch)
    {
        self.watch = lastWatch;
    }
    else
    {
        [self displayNoWatchErrorAlert];
    }

    [PBPebbleCentral defaultCentral].delegate = self;
}

- (void)setWatch:(PBWatch *)watch
{
    if (watch != _watch)
    {
        _watch = watch;

        __weak JSPebbleInterface *weakSelf = self;
        [self.watch appMessagesGetIsSupported:^(PBWatch *w, BOOL isAppMessagesSupported) {
            if (!isAppMessagesSupported)
            {
                showErrorAlertWithMessage(@"App messages is not supported on the watch. Update the firmware");
            }

            NSData *uuid = [NSData dataWithBytes:pebbleAppUUID length:sizeof(pebbleAppUUID)];
            [watch appMessagesSetUUID:uuid];

            [self.watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *w2, NSDictionary *update) {
                NSLog(@"Watch sent: %@", update);

                // Dispatch async so that PebbleKit sends the ACK first.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[JSPebbleReminders defaultInstance] sendRemindersToPebbleInterface:weakSelf];
                });

                return YES;
            }];
        }];
    }
}

- (void)sendStringArray:(NSArray *)stringArray
{
    if (!self.watch)
    {
        [self displayNoWatchErrorAlert];
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [stringArray enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop) {
        dictionary[[NSNumber numberWithInt8:(int8_t)idx]] = string;
    }];

    [self.watch appMessagesPushUpdate:dictionary onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        NSLog(@"Dictionary %@ sent with error %@", dictionary, error);

        if (error)
        {
            showErrorAlertWithMessage([error description]);
        }
    }];
}

#pragma mark -

- (void)pebbleCentral:(PBPebbleCentral *)central watchDidConnect:(PBWatch *)watch isNew:(BOOL)isNew
{
    NSLog(@"Watch did connect");

    self.watch = watch;
}

@end
