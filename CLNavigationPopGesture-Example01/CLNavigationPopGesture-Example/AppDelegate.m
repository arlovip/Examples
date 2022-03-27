//
//  AppDelegate.m
//  CLNavigationPopGesture-Example
//
//  Created by long.chen28 on 2022/3/26.
//

#import "AppDelegate.h"
#import "CLBaseNavigationController.h"
#import "HomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initWindow];
    return YES;
}

- (void)initWindow {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = [UIColor cyanColor];
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    self.window.rootViewController = [[CLBaseNavigationController alloc] initWithRootViewController:homeVC];
    [self.window makeKeyAndVisible];
}

@end
