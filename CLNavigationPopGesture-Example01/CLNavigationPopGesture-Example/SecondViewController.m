//
//  SecondViewController.m
//  CLNavigationPopGesture-Example
//
//  Created by long.chen28 on 2022/3/26.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
}

- (void)configureUI {
    self.title = @"Second";
    self.view.backgroundColor = UIColor.greenColor;
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 200)]; 
    label.backgroundColor = UIColor.blueColor;
    label.text = @"随意侧滑导航到上一个页面";
    [label sizeToFit];
    [self.view addSubview:label];
    label.center = self.view.center;
}
 
- (void)cl_popGestureDidEnd {
    NSLog(@"😂😂😂 %s", __FUNCTION__);
}

@end
