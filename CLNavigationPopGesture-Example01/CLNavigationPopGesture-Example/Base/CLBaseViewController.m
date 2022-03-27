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

@end
