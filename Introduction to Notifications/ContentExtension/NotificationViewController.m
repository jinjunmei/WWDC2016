//
//  NotificationViewController.m
//  ContentExtension
//
//  Created by 符现超 on 2016/12/5.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
}

- (void)didReceiveNotification:(UNNotification *)notification {
    self.label.text = notification.request.content.body;
    
    self.imageView.image = [UIImage imageNamed:@"hami.gif"];
    UNNotificationAttachment *attachment = notification.request.content.attachments.firstObject;
    if (attachment) {
        self.imageView.image = [UIImage imageWithContentsOfFile:attachment.URL.path];
    }
}

//- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption option))completion {
// 
//}

@end




