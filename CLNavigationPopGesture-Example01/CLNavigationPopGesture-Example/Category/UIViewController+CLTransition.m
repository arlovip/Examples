//
//  UIViewController+CLTransition.m
//  CLNavigationPopGesture-Example
//
//  Created by long.chen28 on 2022/3/26.
//

#import "UIViewController+CLTransition.h"

@implementation UIViewController (CLTransition)


- (void)cl_popVC {
    [self.class cl_popVCFrom:self];
}

+ (void)cl_popVCFrom:(UIViewController *)viewController {
    
    UINavigationController *nav;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        nav = (UINavigationController *)viewController;
    } else {
        // nav may be nil here.
        nav = viewController.navigationController;
    }
    
    if (!nav) {
        [viewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    UIViewController *topVC = nav.topViewController;
    
    // Dismiss all the being presented view controllers.
    while (topVC.presentedViewController) {
        [topVC.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    UIViewController *vc = [nav popViewControllerAnimated:YES];
    // Dismiss the root view controller if topVC is the last presented view controller.
    if (!vc) {
        [topVC dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
