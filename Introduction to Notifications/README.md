#WWDC2016 Session 707 - Introduction to Notifications
> 视频地址：[传送门](https://developer.apple.com/videos/play/wwdc2016/707/) </br>
> 字幕：[传送门](http://asciiwwdc.com/2016/sessions/707)

----------
#### 现有通知API的缺点：
1、本地通知和远程通知用的是两套回调方法

2、可控性差（eg.无法控修改已在调度队列中的通知，换句话说就是发出去的通知泼出去的水)

![现有通知的缺点](https://github.com/faimin/UNUserNotificationDemo/blob/master/NotificationSnapImages/%E7%8E%B0%E6%9C%89%E9%80%9A%E7%9F%A5API%E7%BC%BA%E7%82%B9.png)
#### 新通知框架的优点：
1、与旧API相似

2、支持的内容更丰富（eg.图片、附件）

3、本地与远程通知统一处理，减少了重复代码

4、更容易管理

5、可以在扩展中处理通知，比如替换`content`，下载附件

6、支持🍎多平台（iOS、watchOS、tvOS）

以前是通过别的设备建立连接，然后通知才能转到watch上，现在可以在watchOS上添加本地通知了，比如手机上装了一个锻炼app，但是锻炼时没带着手机，戴着watch呢，当用户完成训练时依然能够发送完成训练的通知。

> 至于如何与watchOS之间进行通知，🍎没说，只是说他们是利用`Quick Interaction Techniques`实现的。

------
### Now，坐好，新司机要发车了😄
#### 应用需要先注册通知来获取用户的授权（本地通知也需要）

```objc
//MARK: 注册通知
- (void)registerNotification {
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    // 这几种注册类型在手机的setting中单个设置
    UNAuthorizationOptions authorization = UNAuthorizationOptionBadge | UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionCarPlay;
    // 获取权限
    [notificationCenter requestAuthorizationWithOptions:authorization completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            // token registration（需要与APNs建立连接）
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            
            // 获取用户授权的相关信息
            [notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                NSLog(@"UNNotificationSettings ==> %@", settings);
            }];
        } else {
            NSLog(@"不允许注册通知");
        }
    }];
}
```

> Note：在iOS10中需要在`target -> Capabilties`中打开`Push Notifications`选项，否则会出现通知注册失败的问题，错误日志如下：

```
2016-12-05 12:06:33.243278 UNUserNotificationDemo[1053:951498] You've implemented -[<UIApplicationDelegate> application:didReceiveRemoteNotification:fetchCompletionHandler:], but you still need to add "remote-notification" to the list of your supported UIBackgroundModes in your Info.plist.
2016-12-05 12:06:40.703255 UNUserNotificationDemo[1053:951498] 注册通知失败 : 未找到应用程序的“aps-environment”的授权字符串
2016-12-05 12:06:40.707410 UNUserNotificationDemo[1053:951750] UNNotificationSettings ==> <UNNotificationSettings: 0x17408e560; authorizationStatus: Authorized, notificationCenterSetting: Enabled, soundSetting: Enabled, badgeSetting: Enabled, lockScreenSetting: Enabled, alertSetting: NotSupported, carPlaySetting: Enabled, alertStyle: Banner>
```
![打开通知选项](https://github.com/faimin/UNUserNotificationDemo/blob/master/NotificationSnapImages/Push%20Notifications.png)
![Background Models](https://github.com/faimin/UNUserNotificationDemo/blob/master/NotificationSnapImages/Background%20Models.png)

#### 通知内容

```
attachments         //附件
badge               //数字标志
title               //推送内容标题
subtitle            //推送内容子标题
body                //推送内容body
categoryIdentifier  //category标识，操作策略
launchImageName     //点击通知进入应用的启动图
sound               //声音
userInfo 			//附带通知内容
```

初始化方法：

```objc
UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
content.title = @"第一条推送标题";
content.subtitle = @"推送副标题";
content.body = @"详细内容xxxxxxxxxxx";
content.sound = [UNNotificationSound defaultSound];
```

#### 🍎提供了4种类型的通知触发器：

![4种触发器](https://github.com/faimin/UNUserNotificationDemo/blob/master/NotificationSnapImages/Triggers.png)

+ UNPushNotificationTrigger 触发APNS服务，系统自动设置（这是区分本地通知和远程通知的标识）
+ UNTimeIntervalNotificationTrigger 间隔多长时间后触发（eg.每隔2分钟发送一次通知）
+ UNCalendarNotificationTrigger 在将来指定的某一天触发（每天的某个时刻发送通知）
+ UNLocationNotificationTrigger 根据当前所在位置（离开或进入某一区域时触发通知）

```objc
- (void)contentNotification {
    UNMutableNotificationContent *content = ({
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"第一条推送标题";
        content.subtitle = @"推送副标题";
        content.body = @"详细内容xxxxxxxxxxx";
        //content.badge = @1;
        content.sound = [UNNotificationSound defaultSound];
        content;
    });
    
    UNNotificationTrigger *triger = nil;
    NSString *importantRequestIdentifier = @""; // 此参数不能为nil
    switch (self.trigerType) {
        case TrigerType_TimeInternal:
            triger = [self timeIntervalTriger];
            importantRequestIdentifier = TimeIntervalId;
            break;
        case TrigerType_Calendar:
            triger = [self canlendarTriger];
            importantRequestIdentifier = CalendarId;
            break;
        case TrigerType_Location:
            triger = [self locationNotification];
            importantRequestIdentifier = LocalRegionId;
            break;
        default:
            break;
    }
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:importantRequestIdentifier content:content trigger:triger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - Triger

// 定时器触发
- (UNNotificationTrigger *)timeIntervalTriger {
    // 5秒后通知(从你创建的时候开始计算)
    UNTimeIntervalNotificationTrigger *triger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    return triger;
}

//日期触发
- (UNNotificationTrigger *)canlendarTriger {
    NSDateComponents *component = ({
        NSDateComponents *component = [[NSDateComponents alloc] init];
        component.weekday = 2;
        component.hour = 17;
        component.minute = 30;
        component;
    });
    UNCalendarNotificationTrigger *triger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:component repeats:NO];
    return triger;
}

//位置触发
- (UNNotificationTrigger *)locationNotification {
    CLRegion *region = ({
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(100, 100);
        CLRegion *region = [[CLCircularRegion alloc] initWithCenter:center radius:100 identifier:@"center"];
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
        region;
    });
    UNLocationNotificationTrigger *triger = [UNLocationNotificationTrigger triggerWithRegion:region repeats:NO];
    return triger;
}
```

#### Notification Category

action：设置标识（identifier）、按钮标题（title）、按钮选项（options）

```
// API
+ (instancetype)actionWithIdentifier:(NSString *)identifier title:(NSString *)title options:(UNNotificationActionOptions)options;
```

```
options:
UNNotificationActionOptionAuthenticationRequired  执行前需要解锁确认
UNNotificationActionOptionDestructive  显示高亮（红色）
UNNotificationActionOptionForeground  将会引起程序启动到前台
```

action 有2种类型：

- UNNotificationAction 普通按钮样式
- UNTextInputNotificationAction 输入框样式

category：设置标识（identifier）、actions、intentIdentifiers（需要填写你想要添加到哪个推送消息的 id）、策略选项（options）

```
+ (instancetype)categoryWithIdentifier:(NSString *)identifier actions:(NSArray<UNNotificationAction *> *)actions intentIdentifiers:(NSArray<NSString *> *)intentIdentifiers options:(UNNotificationCategoryOptions)options;
```

```
options
UNNotificationCategoryOptionNone
UNNotificationCategoryOptionCustomDismissAction  当清除当前通知时，会走center的delegate。
UNNotificationCategoryOptionAllowInCarPlay  适用于行车模式
```

具体使用

```
UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action1" title:@"需要解锁" options:UNNotificationActionOptionAuthenticationRequired];
UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action2" title:@"启动app" options:UNNotificationActionOptionForeground];
//给category设置action
UNNotificationCategory *category1 = [UNNotificationCategory categoryWithIdentifier:@"category1" actions:@[action1, action2] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
//给通知内容设置category
content.categoryIdentifier = @"category1";
```

### 附件通知

1. 本地推送通知增加附件，只需给content.attachments设置UNNotificationAttachment附件对象
2. 远程推送通知增加附件，需要实现 UNNotificationServiceExtension（通知服务扩展），在回调方法中处理 推送内容时设置 request.content.attachments（请求内容的附件） 属性，之后调用 contentHandler 方法即可。

给本地推送通知增加附件

```
NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_0723" ofType:@"mp4"];
UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"atta1" URL:[NSURL fileURLWithPath:path] options:nil error:&error];

content.attachments = @[attachment];
```

> 如果要在后台进行一些附件操作，比如下载附件等，需要在`aps`里添加`"content-available":1`字段 </br>
> 如果想要指定操作策略，需要添加`"category":"categoryId"`字段

#### Service Extension
在通知展示之前，我们可以利用`Service Extensions`，下载通知中带的附件，但是需要注意的是：这个功能🍎只提供给了我们很短的时间来操作附件，原话如下：
> You will get a short execution time, which means this is not for long background running tasks.

所以，你不要梦想着在通知中观看大片，不过可以放一个压缩版的gif图片还是可以小试一下的 😝


#### Demo
[https://github.com/onevcat/UserNotificationDemo](https://github.com/onevcat/UserNotificationDemo)

[https://github.com/liuyanhongwl/UserNotification](https://github.com/liuyanhongwl/UserNotification)

####疑问
`removePendingNotificationRequestsWithIdentifiers`与`removeDeliveredNotificationsWithIdentifiers`的区别???

## 推荐文章：
+ [活见久的重构 - iOS 10 UserNotification 框架解析](http://onevcat.com/2016/08/notification/)
+ [WWDC2016 Session笔记 - iOS 10  推送Notification新特性](http://www.jianshu.com/p/9b720efe3779)
+ [iOS10 UserNotification](https://github.com/liuyanhongwl/ios_common/blob/master/files/ios10_usernotification.md#%E8%8E%B7%E5%8F%96%E6%9D%83%E9%99%90)

