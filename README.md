VLDLocalNotificationsScheduler
==============================

The imposed limit of 64 scheduled local notifications is almost always enough. You can also use the repeatInterval property of the UILocalNotification class to show the notification indefinite number of times as long as it doesn't change. 

Recently, however, I worked on a application which helps young mothers with pregnancy advices and information. For every day of 9 months there had to be a local notification with information about that particular day. 

One way to solve this is to add all notifications to a custom queue. Every time the app becomes active the queue schedules at most 64 of them and deletes any items that has passed. This implementation uses a SQLite database (with the help of FMDB) and 
lets you add and cancel notification for custom types.

## Example Usage
```objective-c
VLDLocalNotificationsScheduler scheduler = [[VLDLocalNotificationsScheduler alloc] init];
```
### Add local notification 

```objective-c
[scheduler perform: ^(VLDLocalNotificationsTransaction *transaction) {
  UILocalNotification *localNotification = [[UILocalNotification alloc] init];
  // ...
  [transaction addLocalNotification: localNotification
                           withType: @"test"];
}];
```



