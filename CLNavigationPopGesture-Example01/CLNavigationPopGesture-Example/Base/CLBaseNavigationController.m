//
//  CLBaseNavigationController.m
//  CLNavigationPopGesture-Example
//
//  Created by long.chen28 on 2022/3/26.
//

#import "CLBaseNavigationController.h"
#import "CLBaseViewController.h"

/// Whether to use system pop gesture. If NO, full-screen pop gesture will be set.
static const BOOL useSystemGesture = NO;
/// Whether to enable global pop gestures. The defaut is YES.
static const BOOL popGestureEnabled = YES;

@interface CLBaseNavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@end

@implementation CLBaseNavigationController {
    NSMutableDictionary <NSString *, NSNumber *> *vcsDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureNavigationGestures];
}

- (void)configureNavigationBar {
    
    NSDictionary *titleTextAttributes = @{
        NSForegroundColorAttributeName: UIColor.blackColor,
        NSFontAttributeName: [UIFont systemFontOfSize:19],
    };
    
    if (@available(iOS 13.0, *)) {
        // (Xcode 13.1)Sets these below to get rid of transparent light grey transition animation on navigation bar.
        UINavigationBarAppearance *nba = [[UINavigationBarAppearance alloc] init];
        [nba configureWithOpaqueBackground];
        nba.backgroundColor = UIColor.whiteColor;
        // Hide the bottom line.
        nba.shadowColor = [UIColor clearColor];
        nba.titleTextAttributes = titleTextAttributes;
        self.navigationBar.standardAppearance = nba;
        self.navigationBar.scrollEdgeAppearance = self.navigationBar.standardAppearance;
    } else {
        // Fallback on earlier versions
        self.navigationBar.titleTextAttributes = titleTextAttributes;
        self.navigationBar.barTintColor = UIColor.whiteColor;
        // Hide the bottom line of navigationBar.
        [self.navigationBar setValue:@1 forKeyPath:@"hidesShadow"];
    }
    
    // Common properties(Sets this to NO in case of the top offset of UITableView in plain style).
    self.navigationBar.translucent = NO;
}

- (void)configureNavigationGestures {
    
    vcsDic = @{}.mutableCopy;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL transitionSel = @selector(handleNavigationTransition:);
#pragma clang diagnostic pop
    
    id target = self.interactivePopGestureRecognizer.delegate;
    if (useSystemGesture && [self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = self;
        self.delegate = self;
    } else if ([target respondsToSelector:transitionSel]) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:transitionSel];
        pan.delegate = self;
        [self.view addGestureRecognizer:pan];
        self.delegate = self;
    }
}

// Override super method to initialize interactive pop gesture here.
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    self.interactivePopGestureRecognizer.enabled = popGestureEnabled;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // If root view controller, disable pop gesture.
    if (self.viewControllers.count == 1) {
        return NO;
    }
    NSString *vcKey = [self vcKeyFromVC:self.topViewController];
    if (vcKey && vcsDic[vcKey] != nil) {
        return vcsDic[vcKey].boolValue;
    }
    return self.interactivePopGestureRecognizer.isEnabled;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    [viewController.transitionCoordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (context.isCancelled) return;
        UIViewController *fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
        if ([fromVC isKindOfClass:[CLBaseViewController class]]) {
            CLBaseViewController *baseVC = (CLBaseViewController *)fromVC;
            if ([baseVC respondsToSelector:@selector(cl_popGestureDidEnd)]) {
                [baseVC cl_popGestureDidEnd];
            }
        }
    }];
}

/**
 * Use runtime if you like
 *
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
*/

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    NSString *vcKey = [self vcKeyFromVC:viewController];
    if (vcKey && vcsDic[vcKey] == nil) {
        // Saves each pop gesture enabled value if it's set for child view controller.
        vcsDic[vcKey] = @(self.interactivePopGestureRecognizer.isEnabled);
    }
}

#pragma mark - Convenience methods

- (nullable NSString *)vcKeyFromVC:(UIViewController *)viewController {
    return NSStringFromClass([viewController class]);
}

- (void)setSpecifiedViewControllerInteractivePopGestureEnabled:(BOOL)enabled {
    NSString *vcKey = [self vcKeyFromVC:self.topViewController];
    if (vcKey) {
        vcsDic[vcKey] = @(enabled);
    }
}

@end
