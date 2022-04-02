//
//  CLBaseViewController.m
//  CLNavigationPopGesture-Example
//
//  Created by long.chen28 on 2022/3/26.
//

#import "CLBaseViewController.h"
#import "UIViewController+CLTransition.h"

@interface CLBaseViewController ()

@end

@implementation CLBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self configureLeftBarButton];
}

- (void)configureLeftBarButton {
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 55, 44);
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [leftButton setTitle:@"Back" forState:UIControlStateNormal];
    [leftButton setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(cl_leftBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

#pragma mark - Public methods

- (void)cl_leftBarButtonClicked {
    [self cl_popVC];
}

/**
 * @brief NOTE: please override this method in your child view controller. Don't remove this method because it may be called if necessary.
*/
- (void)cl_popGestureDidEnd {
    // Attention! Override this method in child view controller.
}

- (void)setHidesBackButton:(BOOL)hidesBackButton {
    _hidesBackButton = hidesBackButton;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
}

- (void)setCl_interactivePopGestureEnabled:(BOOL)cl_interactivePopGestureEnabled {
    _cl_interactivePopGestureEnabled = cl_interactivePopGestureEnabled;
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic push
    SEL sel = @selector(setSpecifiedViewControllerInteractivePopGestureEnabled:);
#pragma clang diagnostic pop
    if (self.navigationController && [self.navigationController respondsToSelector:sel]) {
        IMP imp = [self.navigationController methodForSelector:sel];
        void(*func)(id, SEL, BOOL) = (void *)imp;
        func(self.navigationController, sel, cl_interactivePopGestureEnabled);
    }
}

@end
