//
//  JSPebbleReminders.m
//  JSPebbleReminders
//
//  Created by Javier Soto on 5/17/13.
//  Copyright (c) 2013 Javier Soto. All rights reserved.
//

#import "JSPebbleReminders.h"

#import "JSPebbleInterface.h"
#import <EventKit/EventKit.h>

@interface JSPebbleReminders ()

@property (nonatomic, strong) EKEventStore *eventStore;

@end

@implementation JSPebbleReminders

static void showErrorAlertWithMessage(NSString *message)
{
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

+ (JSPebbleReminders *)defaultInstance
{
    static JSPebbleReminders *defaultInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultInstance = [[JSPebbleReminders alloc] init];
    });

    return defaultInstance;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.eventStore = [[EKEventStore alloc] init];
    }

    return self;
}

- (void)sendRemindersToPebbleInterface:(JSPebbleInterface *)interface
{
    __weak JSPebbleReminders *weakSelf = self;

    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error)
     {
         if (!granted)
         {
             showErrorAlertWithMessage(@"You should accept the permissions");
             return;
         }
         if (error)
         {
             showErrorAlertWithMessage([NSString stringWithFormat:@"An error occured: %@", error]);
             return;
         }

         [weakSelf.eventStore fetchRemindersMatchingPredicate:[weakSelf.eventStore predicateForIncompleteRemindersWithDueDateStarting:nil ending:nil calendars:@[[weakSelf.eventStore defaultCalendarForNewReminders]]]
                                                   completion:^(NSArray *reminders)
          {
              dispatch_async(dispatch_get_main_queue(), ^{
                  if (reminders.count == 0)
                  {
                      showErrorAlertWithMessage(@"No reminders found");
                      return;
                  }

                  NSArray *titles = [reminders valueForKey:NSStringFromSelector(@selector(title))];

                  [[JSPebbleInterface defaultInterface] sendStringArray:titles];
                  
              });
          }];
     }];
}

@end
