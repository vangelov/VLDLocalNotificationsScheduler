//
//  VLDLocalNotificationsScheduler.h
//  Example
//
//  Created by Vladimir Angelov on 11/9/14.
//  Copyright (c) 2014 Vladimir Angelov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLDLocalNotificationsTransaction.h"

@interface VLDLocalNotificationsScheduler : NSObject

+ (instancetype) defaultScheduler;

@property (assign, nonatomic) NSInteger maxScheduledNotificationsCount;

- (void) reschedule;
- (void) perform: (void (^)(VLDLocalNotificationsTransaction *transaction)) transactionBlock;

@end
