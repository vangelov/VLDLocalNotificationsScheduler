//
//  VLDLocalNotificationsScheduler.m
//  Example
//
//  Created by Vladimir Angelov on 11/9/14.
//  Copyright (c) 2014 Vladimir Angelov. All rights reserved.
//

#import "VLDLocalNotificationsScheduler.h"
#import "FMDB.h"

@interface VLDLocalNotificationsScheduler ()

@property (strong, nonatomic) FMDatabaseQueue *databaseQueue;
@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation VLDLocalNotificationsScheduler

+ (instancetype) defaultScheduler {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id) init {
    self = [super init];
    
    if(self) {
        self.operationQueue = [NSOperationQueue new];
        self.operationQueue.maxConcurrentOperationCount = 1;
        
        self.maxScheduledNotificationsCount = 64;
        
        [self initDatabase];
    }
    
    return self;
}


- (void) initDatabase {
    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath: self.databasePath];
    
    [self.databaseQueue inDatabase: ^(FMDatabase *db) {
        [db executeUpdate: @"CREATE TABLE IF NOT EXISTS notifications ("
                           @"    id INTEGER PRIMARY KEY NOT NULL,"
                           @"    timeInterval DOUBLE,"
                           @"    type TEXT,"
                           @"    data BLOB"
                           @")"
         ];
    }];
}

- (NSString *) databasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent: @"VLDLocalNotificationsScheduler.db"];
}

- (void) executeTransaction: (void (^)(VLDLocalNotificationsTransaction *transaction)) transactionBlock {
    [self.operationQueue addOperationWithBlock: ^{
        VLDLocalNotificationsTransaction *transaction = [[VLDLocalNotificationsTransaction alloc] init];
        transactionBlock(transaction);
        
        [self.databaseQueue inDatabase: ^(FMDatabase *db) {
            [transaction executeInDatabase: db];
        }];
    }];
    
    [self reschedule];
}

- (void) reschedule {
    [self.operationQueue addOperationWithBlock: ^{
        NSMutableArray *localNotificationsToSchedule = [NSMutableArray array];
        
        [self.databaseQueue inDatabase: ^(FMDatabase *db) {
            [self cancelExpiredAndCollectNewNotificationsIn: localNotificationsToSchedule inDatabase: db];
        }];
        
        [UIApplication sharedApplication].scheduledLocalNotifications = localNotificationsToSchedule;
    }];
}

- (void) cancelExpiredAndCollectNewNotificationsIn: (NSMutableArray *) localNotificationsToSchedule
                                        inDatabase: (FMDatabase *) db {
    
    NSMutableArray *rowIDsToDelete = [NSMutableArray array];

    FMResultSet *resultSet = [db executeQuery: @"SELECT * FROM notifications ORDER by timeInterval"];
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];

    while ([resultSet next]) {
        NSTimeInterval timeInterval = [resultSet doubleForColumn: @"timeInterval"];
        BOOL isExpired = timeInterval < currentTimeInterval;
        
        if(isExpired) {
            NSInteger rowID = [resultSet intForColumn: @"id"];
            [rowIDsToDelete addObject: @(rowID)];
        }
        else if(localNotificationsToSchedule.count < self.maxScheduledNotificationsCount) {
            NSData *data = [resultSet dataForColumn: @"data"];
            UILocalNotification *localNotification = [NSKeyedUnarchiver unarchiveObjectWithData: data];
            
            [localNotificationsToSchedule addObject: localNotification];
        }
    }
    
    [self deleteRowsWithIDs: rowIDsToDelete inDatabase: db];
}

- (void) deleteRowsWithIDs: (NSArray *) rowIDsToDelete inDatabase: (FMDatabase *) db {
    if(rowIDsToDelete.count > 0) {
        NSString *deleteString = [NSString stringWithFormat: @"DELETE FROM notifications WHERE id in %@", rowIDsToDelete];
        [db executeUpdate: deleteString];
    }
}

@end
