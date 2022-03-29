//
//  UIViewController+CJGNavigationBar.h
//  CJGNavigationController
//
//  Created by Chen Jinguo on 2022/3/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (CJGNavigationBar)
@property (nonatomic, assign) UIBarStyle cjg_barStyle;
@property (nonatomic, strong) UIColor *cjg_barTintColor;
@property (nonatomic, strong) UIImage *cjg_barImage;
@property (nonatomic, strong) UIColor *cjg_tintColor;
@property (nonatomic, strong) NSDictionary *cjg_titleTextAttributes;//标题的属性
@property (nonatomic, assign) float cjg_barAlpha;//navbar的透明度
@property (nonatomic, assign) BOOL cjg_barHidden;//navbar的隐藏/显示 配合self.navigationController.navigationBar.hidden使用
@property (nonatomic, assign) BOOL cjg_barShadowHidden;//导航栏下边线条的隐藏/显示
@property (nonatomic, assign) BOOL cjg_backInteractive;//是否可以返回 (手势+返回按钮)
@property (nonatomic, assign) BOOL cjg_swipeBackEnabled;//滑动返回手势是否响应
// computed
@property (nonatomic, assign, readonly) float cjg_computedBarShadowAlpha;//计算得到透明度
@property (nonatomic, strong, readonly) UIColor *cjg_computedBarTintColor;//计算得到tintcolor
@property (nonatomic, strong, readonly) UIImage *cjg_computedBarImage;//计算得到barImage
- (void)cjg_setNeedsUpdateNavigationBar;
- (void)cjg_setNeedsUpdateNavigationBarAlpha;
- (void)cjg_setNeedsUpdateNavigationBarColorOrImage;
- (void)cjg_setNeedsUpdateNavigationBarShadowAlpha;
@end

NS_ASSUME_NONNULL_END
