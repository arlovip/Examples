//
//  CLBaseViewController.h
//  CLNavigationPopGesture-Example
//
//  Created by long.chen28 on 2022/3/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLBaseViewController : UIViewController

/// Hide left bar button on top-left corner of navigation bar.
@property (nonatomic, assign) BOOL hidesBackButton;

/// Whether to enable the interactive pop gesture or not.
@property (nonatomic, assign) BOOL cl_interactivePopGestureEnabled;

/// Left bar back button event. Override this method if you'd like to do something for your needs.
- (void)cl_leftBarButtonClicked;

/// This method won't be called until the swipe gesture ends up with page's disappearance. Override this method according to your needs.
/// For instance, maybe you want to do something else if the view controller disappears when pop gesture is completely released by user.
- (void)cl_popGestureDidEnd;

@end

NS_ASSUME_NONNULL_END
