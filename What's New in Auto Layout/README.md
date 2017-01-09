## Xcode 8 Auto Layout新特性
+ [Session236 字幕](http://asciiwwdc.com/2016/sessions/236)
+ [视频地址](https://developer.apple.com/videos/play/wwdc2016/236/)
+ [Xcode 8 新特性](http://www.jianshu.com/p/2521c610fac3)


在Xcode8中我们可以使用autoresizing了，autoresizing会在运行时被转化为constraints，而不是在编译时期。这样做的好处是：可控性更强，更加灵活、透明。

> In fact, what we are going to do is we're going to take those autoresizing masks and we are going to translate them into constraints.

> But we are going to translate them into constraints at runtime.
> 
> We're generating them at runtime and not at build time because it's going to be more flexible and more transparent to you, giving you greater control if you need to do anything programmatic to these views, because for those who are pro-Auto Layout users out there, you might recognize this flag.
> 
> --------
> 
> On the view, we are simply setting translatesAutoresizingMask IntoConstraints equals true.
> 
> What about for the views that you've added constraints to inside of Interface Builder?
> They're going to be the same as before.
> 


### Warning
+ 当子视图上用了约束之后，父视图上假如一开始设置的是`autoresizing`的话，那么父视图上的`autoresizing`也会失效，即当子视图的`translatesAutoresizingMaskIntoConstraints`变为`NO`之后，其父视图的`translatesAutoresizingMaskIntoConstraints`属性也会自动变为NO； 反之，如果父视图是用的约束，子视图依然可以用`autoresizing`。


### Tips：
#### 针对于Autoresizing
+ Autoresizing模式下，如果`label`宽度被挤压，只需要把`fixed font size`改为`Minimum Font Size`即可。
![1](http://upload-images.jianshu.io/upload_images/1194012-79b7038d7df03eb8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240) 

![2](http://upload-images.jianshu.io/upload_images/1194012-d140165f6ca54036.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 以下是针对于无法确定视图大小导致约束报错的解决办法
+ Placeholder Constraints: ![](http://upload-images.jianshu.io/upload_images/1194012-ed8c011d75371e39.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
+ Intrinsic Content Size: ![](http://upload-images.jianshu.io/upload_images/1194012-5f22d602933155e2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
+ 关闭约束验证： 
![](http://upload-images.jianshu.io/upload_images/1194012-4f433ddf72781326.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### Debug
1、设置`Schemes`编辑选项

```objc
-UIViewLayoutFeedbackLoopDebuggingThreshold 100 // 50...1000
-NSViewLayoutFeedbackLoopDebuggingThreshold 100 // 50...1000
// Logs to com.apple.UIKit:LayoutLoop or com.apple.AppKit:LayoutLoop
```

![](http://upload-images.jianshu.io/upload_images/1194012-a46ee65eca84ff69.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
如果发现在一个Runloop中，layout在一个view上面调用的次数超过了阀值，这里设置的是100，也就是说次数超过100，这个死循环还会在跑一小段，因为这个时候要给debugger一个记录信息的时间。当记录完成之后，就会立即抛出异常。并且信息会显示在logs中。log会被记录在com.apple.UIKit:LayoutLoop(iOS)/com.apple.AppKit:LayoutLoop(macOS)中。

2、设置全局断点：
![](http://upload-images.jianshu.io/upload_images/1194012-a83832771675c027.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



## 推荐阅读
+ [FDStackView](https://github.com/forkingdog/FDStackView)
+ [黑魔法--“低版本中使用高版本中出现的类”之技术实现原理详解](http://www.tuicool.com/articles/zu67NbU)
+ [浅析为何能通过FDStackView在iOS以下使用UIStackView](http://www.tuicool.com/articles/m2UfIfJ)

> **原理：** 
> 
> 在编译的时候，系统中的每个类都在数据段上有一个标签(形式是这样的： OBJC_CLASS $_ClassName)，这个标签你可以理解成key，它的value就是该类的类名， 举例：数据段中会有一个key是 OBJC_CLASS $_UIAlertController，它对应的value就是UIAlertController的类名，当然也就会有 OBJC_CLASS $_UIStackView这个标签，标识着UIStackView这个类。
>
> 最重要的一点是： 在iOS7中，还没有UIAlertController的时候，这个标签 OBJC_CLASS $_UIAlertController已经存在了，只是这个标签对应的value值是nil，因为没有这个类，我们可以认为是苹果在给高版本的这个类站位，就是苹果的这个站位才使得我们有幸用上了这个黑魔法。 当然每个后出现的类都是有站位的，比如UIStackView。
> 
> [GJAlertController](https://github.com/GJGroup/GJAlertController)也是用的这个原理



























