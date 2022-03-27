# UINavigationController全屏侧滑&侧滑监听

在日常开发中，我们经常使用到系统的导航，来完成各页面的交互跳转，这是再正常不过且用到的基础功能。众所周知，我们也可以在具体的页面禁用系统导航，一般都是通过设置`interactivePopGestureRecognizer`是否开启来实现，不过，我们必须注意系统导航在根页面时，未经处理，用户再测滑则会导致`app`卡住甚至卡死，这个问题在之前的一篇文章中也有说过，并且也说了如何监听用户侧滑释放的方法，以便我们能够做一些额外操作。文章链接🔗: [iOS interactivePopGestureRecognizer卡住&手势滑动监听](https://www.jianshu.com/p/8fdff54a08c8)。

尽管系统的导航已满足大部分开发需求，但是用户的体验可能不是很好。之前的那篇文章虽然解决了以下两个问题：

- 导航在根页面时因为测滑卡死。
- 导航测滑监听的解决方案。

但是发现还是不够完美，因此，本文主要结合实际，实现系统的侧滑导航、全屏侧滑导航、导航侧滑监听的一体化方案，解决以下问题：

- 避免在根页面测滑卡死。
- 导航侧滑的更好的监听解决方案。
- 实现全屏测滑导航。

## 系统测滑导航

首先，在子类`BaseNavigationController`中设置手势代理和导航代理

```

@interface BaseNavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@end

- (void)viewDidLoad {
    [super viewDidLoad]; 
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = self;
        self.delegate = self;
    }
}
```

为了保证每一次`push`操作，都设置开启系统导航，我们复写父类`UINavigationController`的方法

```
// Override super method to initialize interactive pop gesture here.
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    self.interactivePopGestureRecognizer.enabled = YES;
}
```

这样的话，就保证了每次即将`push`到下一个页面时，系统测滑手势是被开启的。

实现`UINavigationControllerDelegate`的方法

```
#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        // If viewController is rootViewController, disable the pop gesture recognizer.
        self.interactivePopGestureRecognizer.enabled = self.viewControllers.count > 1 && self.interactivePopGestureRecognizer.isEnabled;
    }
}
```

这样就可以了吗？经测试，我们发现，虽然以上方案解决了根页面测滑卡死的问题，但是有一个`Bug`：`A页面 -> B页面 -> C页面`，如果`C页面`禁用测滑手势，即设置`self.navigationController.interactivePopGestureRecognizer.enabled = NO;`，此时返回到`B页面`时，发现`B页面`的测滑手势也被禁用了，即无法侧滑到`A页面`。这是因为侧滑手势的属性设置时全局性的，都是导航控制器的同一个设置，所以才出现了这么一个`Bug`。

既然`C页面`设置了禁用侧滑手势，导致`C页面`销毁时，所有的测滑手势都被禁用，那能不能在`C页面`消失的时候再把测滑手势开启呢？答案显然是可以的，比如

```
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}
```

但是，如果有多个页面都需要禁用测滑手势，其他都是开启，我们要每个页面都这样写一遍？显然太麻烦，而且都是些冗余代码。因此，我的思路是，在父类中用一个变量保存每一个控制器的侧滑手势，如下

```
@implementation BaseNavigationController {
    NSMutableDictionary <NSString *, NSNumber *> *vcsDic;
}

vcsDic = @{}.mutableCopy;

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSString *vcKey = NSStringFromClass(viewController.class);
    if (vcKey && vcsDic[vcKey] == nil) {
        // Saves each pop gesture enabled value if it's set for child view controller.
        vcsDic[vcKey] = @(self.interactivePopGestureRecognizer.isEnabled);
    }
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        // If viewController is rootViewController, disable the pop gesture recognizer.
        self.interactivePopGestureRecognizer.enabled = self.viewControllers.count > 1 && vcsDic[vcKey].boolValue;
    }
}
```

这样就完美地解决了测滑手势设置的相互之间的影响问题。接下来，我们看一下如何实现全屏手势侧滑。

## 全屏测滑导航

我们知道，系统测滑手势必然要依赖手势识别器，而在导航控制器的源码中

```
@property(nullable, nonatomic, readonly) UIGestureRecognizer *interactivePopGestureRecognizer
```

可知，`interactivePopGestureRecognizer`就是手势的核心，我们在`viewDidLoad`打印一下

```
- (void)viewDidLoad {
    [super viewDidLoad]; 
    ....................
    NSLog(@"result：%@", self.interactivePopGestureRecognizer);
}

result：
<_UIParallaxTransitionPanGestureRecognizer: 0x1275096e0;
 state = Possible; 
 delaysTouchesBegan = YES; 
 view = <UILayoutContainerView 0x12990a3e0>;
 target= <(action=handleNavigationTransition:, 
 target=<_UINavigationInteractiveTransition 0x127507ac0>)>>
```

发现这个手势中有一个`handleNavigationTransition:`方法，从字面意思就是**操作导航过渡**。既然如此，我们就直接对这个方法进行操作，添加到我们当前导航的手势上面

```
- (void)configureNavigationGestures {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL transitionSel = @selector(handleNavigationTransition:);
#pragma clang diagnostic pop
    
    id target = self.interactivePopGestureRecognizer.delegate;
    if ([target respondsToSelector:transitionSel]) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:transitionSel];
        pan.delegate = self;
        [self.view addGestureRecognizer:pan];
        self.delegate = self;
    }
}
```

然后实现手势代理`UIGestureRecognizerDelegate`

```
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // If root view controller, disable pop gesture.
    if (self.viewControllers.count == 1) {
        return NO;
    }
    NSString *vcKey = NSStringFromClass(self.topViewController.class);
    if (vcKey && vcsDic[vcKey] != nil) {
        return vcsDic[vcKey].boolValue;
    }
    return self.interactivePopGestureRecognizer.isEnabled;
}
```

这样就实现了全屏侧滑导航了。

## 侧滑手势监听

上一篇文章中，[iOS interactivePopGestureRecognizer卡住&手势滑动监听](https://www.jianshu.com/p/8fdff54a08c8)，尽管可以通过通知监听用户侧滑导航，但是实在是太不方便了，因为不仅要在导航的父类添加要监听的页面的字符串，还要在相应的页面做监听，还要移除监听，简直太繁琐了！

于是，针对这个问题，有了另一个思路，通过获取到正在测滑导航的页面，判断是否实现了相应的侧滑导航结束的方法，如果有，直接调用，如果没有，则什么也不做，太完美了！

但是有一个问题，我们如何知道当前正在侧滑的页面是哪一个呢？通过`navigationController.topViewController`并获取不到正在侧滑的页面，于是经过查看源码发现，系统提供的`UIViewControllerTransitionCoordinatorContext`有一个方法`- (nullable __kindof UIViewController *)viewControllerForKey:(UITransitionContextViewControllerKey)key;`可以获取到当前正在侧滑导航的`UIViewController`，这样就好实现了。

一般情况下，我们的所有页面都会有一个基类`BaseViewController`，我们在`BaseViewController.h`中添加

```
- (void)cl_popGestureDidEnd;
```

`BaseViewController.m`

```
/**
 * @brief NOTE: please override this method in your child view controller. Don't remove this method because it may be called if necessary.
*/
- (void)cl_popGestureDidEnd {
    // Attention! Override this method in child view controller.
}
```

在导航基类`BaseNavigationController`中导入

```
#import "BaseNavigationController.h"
#import "BaseViewController.h"
```

在监听导航侧滑的`UINavigationControllerDelegate`的方法中，实现

```
#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    [viewController.transitionCoordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (context.isCancelled) return;
        UIViewController *fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
        if ([fromVC isKindOfClass:[BaseViewController class]]) {
            BaseViewController *baseVC = (BaseViewController *)fromVC;
            if ([baseVC respondsToSelector:@selector(cl_popGestureDidEnd)]) {
                [baseVC cl_popGestureDidEnd];
            }
        }
    }];
}
```

我们在想要监听侧滑导航的页面，比如`SecondViewController(继承自BaseViewController)`，复写

```
- (void)cl_popGestureDidEnd {
    // 侧滑导航结束，即将pop到上一个页面，在这里做一些事吧...
}
```

这样，就实现了侧滑导航的监听，如果侧滑结束的时候，页面消失，即返回到上一个页面，`cl_popGestureDidEnd`方法就会被调用。

如何不想导入`BaseViewController`怎么办呢？也可以通过`runtime`运行时来做处理

```
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    [viewController.transitionCoordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (context.isCancelled) return;
        UIViewController *fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
        SEL sel = @selector(cl_popGestureDidEnd);
        if (fromVC && [fromVC respondsToSelector:sel]) {
            IMP imp = [fromVC methodForSelector:sel];
            void (*func)(id, SEL) = (void *)imp;
            func(fromVC, sel);
        }
    }];
}
```

> 在`BaseViewController.h`和`BaseViewController.m`中声明和实现`cl_popGestureDidEnd`方法，主要是为了子类可以直接调用，能够直接联想出来。如果使用`runtime`运行时的方案来实现的话，你也可以完全不用在`BaseViewController`中添加`cl_popGestureDidEnd`方法，直接在子类中实现`cl_popGestureDidEnd`方法即可。当然，不导入`BaseViewController`也可以直接使用`runtime`来调用，这里就不赘述了。

## 小结

本文主要介绍了全屏侧滑的实现，以及如何避免侧滑导航到根视图控制器`app`卡死的解决方案，最后也完美地实现如何监听用户侧滑导航的方法。全屏侧滑导航在一定程度上优化了用户体验，侧滑导航监听可以在一些特殊情况下，实现我们的一些特殊操作。

最后，本文将以上内容做了分开讲解，实际上我已经在`Demo`中将上面的代码完全整合到了一起，代码非常简单，总的一百多行代码。比如在`Demo`中有如下属性

```
/// Whether to use system pop gesture. If NO, full-screen pop gesture will be set.
static const BOOL useSystemGesture = NO;
/// Whether to enable global pop gestures. The defaut is YES.
static const BOOL popGestureEnabled = YES;
```

使用的时候，直接修改这两个属性即可，其余代码基本上直接使用，不需要修改！例如，想使用系统侧滑导航，直接修改

```
static const BOOL useSystemGesture = YES;
```

想使用全屏侧滑导航

```
static const BOOL useSystemGesture = NO;
```

默认开启全局侧滑手势

```
static const BOOL popGestureEnabled = YES;
```

默认关闭全局侧滑手势

```
static const BOOL popGestureEnabled = NO;
```

## 附录

- `Demo`地址：[CLNavigationPopGesture-Example](https://github.com/lchenfox/Examples/tree/main/CLNavigationPopGesture-Example01)。
- [个人博客](https://www.clcoder.com/)
- [个人简书](https://www.jianshu.com/u/5112193ea52d)

