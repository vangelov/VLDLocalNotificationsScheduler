//
//  VLDScheduleTransaction.h
//  Example
//
//  Created by Vladimir Angelov on 11/9/14.
//  Copyright (c) 2014 Vladimir Angelov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface VLDLocalNotificationsTransaction : NSObject

- (void) addLocalNotification: (UILocalNotification *) localNotification
                     withType: (NSString *) type;

- (void) cancelLocalNotificationsWithType: (NSString *) type;

- (void) executeInDatabase: (FMDatabase *) db;

@end
