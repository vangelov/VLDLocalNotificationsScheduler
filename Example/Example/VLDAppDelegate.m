//
//  VLDAppDelegate.m
//  Example
//
//  Created by Vladimir Angelov on 11/9/14.
//  Copyright (c) 2014 Vladimir Angelov. All rights reserved.
//

#import "VLDAppDelegate.h"
#import "VLDLocalNotificationsScheduler.h"

@interface VLDAppDelegate ()

@property (strong, nonatomic) VLDLocalNotificationsScheduler *scheduler;

@end

@implementation VLDAppDelegate

- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.scheduler = [[VLDLocalNotificationsScheduler alloc] init];
   
    [self.scheduler perform: ^(VLDLocalNotificationsTransaction *transaction) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval: 10];
        localNotification.alertBody = @"Test message";
        
        [transaction addLocalNotification: localNotification
                                 withType: @"test"];
    }];
   
    return YES;
}

- (void)applicationDidBecomeActive: (UIApplication *) application {
    [self.scheduler reschedule];
}

@end
