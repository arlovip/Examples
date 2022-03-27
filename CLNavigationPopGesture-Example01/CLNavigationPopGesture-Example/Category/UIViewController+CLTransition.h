//
//  UIViewController+CLTransition.h
//  CLNavigationPopGesture-Example
//
//  Created by long.chen28 on 2022/3/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (CLTransition)

/// Pop view controller.
- (void)cl_popVC;

///
/// Pop view controller from current view controller.
///
/// @param viewController A UIViewController or UINavigationController instance.
///
+ (void)cl_popVCFrom:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
