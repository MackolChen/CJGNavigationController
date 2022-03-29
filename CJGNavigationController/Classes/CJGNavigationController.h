//
//  CJGNavigationController.h
//  CJGNavigationController
//
//  Created by Chen Jinguo on 2022/3/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface CJGNavigationController : UINavigationController
- (void)cjg_updateNavigationBarForViewController:(UIViewController *)vc;
- (void)cjg_updateNavigationBarAlphaForViewController:(UIViewController *)vc;
- (void)cjg_updateNavigationBarColorOrImageForViewController:(UIViewController *)vc;
- (void)cjg_updateNavigationBarShadowIAlphaForViewController:(UIViewController *)vc;
@end
@interface UINavigationController(UINavigationBar) <UINavigationBarDelegate>
@end
NS_ASSUME_NONNULL_END
