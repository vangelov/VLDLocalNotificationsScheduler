//
//  VLDScheduleTransaction.m
//  Example
//
//  Created by Vladimir Angelov on 11/9/14.
//  Copyright (c) 2014 Vladimir Angelov. All rights reserved.
//

#import "VLDLocalNotificationsTransaction.h"
#import "FMDB.h"

static NSString * const VLDScheduleTransactionTypeKey = @"VLDScheduleTransactionTypeKey";

@interface VLDLocalNotificationsTransaction ()

@property (strong, nonatomic) NSMutableArray *localNotificationsToAdd;
@property (strong, nonatomic) NSMutableArray *localNotificationTypesToCancel;

@end

@implementation VLDLocalNotificationsTransaction

- (id) init {
    self = [super init];
    
    if(self) {
        self.localNotificationsToAdd = [NSMutableArray array];
        self.localNotificationTypesToCancel = [NSMutableArray array];
    }
    
    return self;
}

- (void) augmentUserInfoForLocalNotification: (UILocalNotification *) localNotification
                                    withType: (NSString *) type {
    
    NSMutableDictionary *augmentedUserInfo = [localNotification.userInfo mutableCopy];
    
    if(!augmentedUserInfo) {
        augmentedUserInfo = [NSMutableDictionary dictionary];
    }
    
    augmentedUserInfo[VLDScheduleTransactionTypeKey] = type;
    
    localNotification.userInfo = augmentedUserInfo;
}

- (void) addLocalNotification: (UILocalNotification *) localNotification
                     withType: (NSString *) type {
    
    NSDate *currentDate = [NSDate date];
    
    if([localNotification.fireDate compare: currentDate] == NSOrderedAscending) {
        return;
    }
    
    [self augmentUserInfoForLocalNotification: localNotification
                                     withType: type ? type : @""];
        
    [self.localNotificationsToAdd addObject: localNotification];
}

- (void) cancelLocalNotificationsWithType: (NSString *) type {
    [self.localNotificationTypesToCancel addObject: type ? type : @""];
}

- (void) executeInDatabase: (FMDatabase *) db {
    [self cancelLocalNotificationsInDatabase: db];
    [self addLocalNotificationsInDatabase: db];
}

- (void) cancelLocalNotificationsInDatabase: (FMDatabase *) db {
    for(NSString *typeToCancel in self.localNotificationTypesToCancel) {
        [db executeUpdate: @"DELETE FROM notifications WHERE type = ?", typeToCancel];
    }
}

- (void) addLocalNotificationsInDatabase: (FMDatabase *) db {
    for(UILocalNotification *localNotification in self.localNotificationsToAdd) {
        NSString *type = localNotification.userInfo[VLDScheduleTransactionTypeKey];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject: localNotification];
        
        [db executeUpdate: @"INSERT INTO notifications (timeInterval, type, data) VALUES (?, ?, ?)",@(localNotification.fireDate.timeIntervalSince1970), type, data];
    }
}

@end
