//
//  JSPebbleReminders.h
//  JSPebbleReminders
//
//  Created by Javier Soto on 5/17/13.
//  Copyright (c) 2013 Javier Soto. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSPebbleInterface;

@interface JSPebbleReminders : NSObject

+ (JSPebbleReminders *)defaultInstance;

- (void)sendRemindersToPebbleInterface:(JSPebbleInterface *)interface;

@end
