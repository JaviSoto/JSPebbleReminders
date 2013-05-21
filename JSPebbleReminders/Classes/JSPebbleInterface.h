//
//  JSPebbleInterface.h
//  JSPebbleReminders
//
//  Created by Javier Soto on 5/17/13.
//  Copyright (c) 2013 Javier Soto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSPebbleInterface : NSObject

+ (instancetype)defaultInterface;

- (void)startListening;

- (void)sendStringArray:(NSArray *)stringArray;

@end
