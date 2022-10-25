//
//  CJGNavigationController.m
//  CJGNavigationController
//
//  Created by Chen Jinguo on 2022/3/29.
//

#import "CJGNavigationController.h"
#import "CJGNavigationBar.h"
#import "UIViewController+CJGNavigationBar.h"
@interface CJGNavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>
@property (nonatomic, readonly) CJGNavigationBar *navigationBar;//自定义的navigationBar
@property (nonatomic, strong) UIVisualEffectView *fromFakeBar;//上一个vc的最底层view（毛玻璃）
@property (nonatomic, strong) UIVisualEffectView *toFakeBar;//下一个vc的最底层view（毛玻璃）
@property (nonatomic, strong) UIImageView *fromFakeShadow;//上一个shadow（下边的线）
@property (nonatomic, strong) UIImageView *toFakeShadow;//下一个shadow（下边的线）
@property (nonatomic, strong) UIImageView *fromFakeImageView;//上一个navBar
@property (nonatomic, strong) UIImageView *toFakeImageView;//下一个navbar
@property (nonatomic, assign) BOOL inGesture;
@end

@implementation CJGNavigationController
@dynamic navigationBar;
//使用自定义的navBar创建导航栏(不使用根视图创建)
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[CJGNavigationBar class] toolbarClass:nil]) {
        self.viewControllers = @[rootViewController];
    }
    return self;
}
- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    NSAssert([navigationBarClass isSubclassOfClass:[CJGNavigationBar class]], @"navigationBarClass Must be a subclass of tsNavigationBar");
    return [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
}
- (instancetype)init {
    return [super initWithNavigationBarClass:[CJGNavigationBar class] toolbarClass:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.delegate = self;
    //返回手势的响应事件
    [self.interactivePopGestureRecognizer addTarget:self action:@selector(handlePopGesture:)];
    self.delegate = self;
    [self.navigationBar setTranslucent:YES]; //不透明
    [self.navigationBar setShadowImage:[UINavigationBar appearance].shadowImage];//全局设置shadowimage
}

- (void)handlePopGesture:(UIScreenEdgePanGestureRecognizer *)recognizer {
    //获取动画控制器
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];//来源控制器
    UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];//目标控制器
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        self.inGesture = YES;
        self.navigationBar.tintColor = blendColor(from.cjg_tintColor, to.cjg_tintColor, coordinator.percentComplete);//percentComplete：转场进度参数
    } else {
        self.inGesture = NO;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //当navbar可以返回并且返回手势激活的时候才可以响应手势 进行返回上层页面的操作
    if (self.viewControllers.count > 1) {
        return self.topViewController.cjg_backInteractive && self.topViewController.cjg_swipeBackEnabled;
    }
    return NO;
}

#pragma mark - UINavigationBarDelegate
//item将要pop时调用，返回NO，不能pop
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    //当不是rootvc && 是本类来popitem的时候 当 cjg_backInteractive 为NO的时候 重置navbar上的subview的alpha为1
    if (self.viewControllers.count > 1 && self.topViewController.navigationItem == item ) {
        if (!self.topViewController.cjg_backInteractive) {
            [self resetSubviewsInNavBar:self.navigationBar];
            return NO;
        }
    }
    return [super navigationBar:navigationBar shouldPopItem:item];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.childViewControllers.count>0) {
        viewController.hidesBottomBarWhenPushed = YES;
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        NSBundle *bundle = [NSBundle bundleForClass:[NSClassFromString(@"CJGNavigationController")class]];
        NSURL *url = [bundle URLForResource:@"CJGNavigationController-source" withExtension:@"bundle"];
        bundle = [NSBundle bundleWithURL:url];
        NSString *name = @"back_icon";
        name = [name stringByAppendingString:@"@2x"];
        NSString *imagePath = [bundle pathForResource:name ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        [backBtn setImage:image forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)back{
//    if ([TSSingleTools popToCartsVC:self]) {
//        return;
//    }
    [self popViewControllerAnimated:YES];
}

- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar {
    if (@available(iOS 11, *)) {
    } else {
        // Workaround for >= iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        [navBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            if (subview.alpha < 1.0) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.0;
                }];
            }
        }];
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //转场动画控制器
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (coordinator) {
        //来源vc
        UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
        //目标vc
        UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        //专场动画
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if (shouldShowFake(viewController, from, to)) {
                if (self.inGesture) {
                    self.navigationBar.titleTextAttributes = viewController.cjg_titleTextAttributes;
                    self.navigationBar.barStyle = viewController.cjg_barStyle;
                } else {
                    [self cjg_updateNavigationBarAnimatedForController:viewController];
                }
                [UIView performWithoutAnimation:^{
                    self.navigationBar.cjg_fake_view.alpha = 0;
                    self.navigationBar.cjg_shadow_view.alpha = 0;
                    self.navigationBar.cjg_background_view.alpha = 0;
                    
                    // from
                    self.fromFakeImageView.image = from.cjg_computedBarImage;
                    self.fromFakeImageView.alpha = from.cjg_barAlpha;
                    self.fromFakeImageView.frame = [self fakeBarFrameForViewController:from];
                    [from.view addSubview:self.fromFakeImageView];
                    
                    self.fromFakeBar.subviews.lastObject.backgroundColor = from.cjg_computedBarTintColor;
                    self.fromFakeBar.alpha = from.cjg_barAlpha == 0 || from.cjg_computedBarImage ? 0.01:from.cjg_barAlpha;
                    if (from.cjg_barAlpha == 0 || from.cjg_computedBarImage) {
                        self.fromFakeBar.subviews.lastObject.alpha = 0.01;
                    }
                    self.fromFakeBar.frame = [self fakeBarFrameForViewController:from];
                    [from.view addSubview:self.fromFakeBar];
                    
                    self.fromFakeShadow.alpha = from.cjg_computedBarShadowAlpha;
                    self.fromFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.fromFakeBar.frame];
                    [from.view addSubview:self.fromFakeShadow];
                    
                    // to
                    self.toFakeImageView.image = to.cjg_computedBarImage;
                    self.toFakeImageView.alpha = to.cjg_barAlpha;
                    self.toFakeImageView.frame = [self fakeBarFrameForViewController:to];
                    [to.view addSubview:self.toFakeImageView];
                    
                    self.toFakeBar.subviews.lastObject.backgroundColor = to.cjg_computedBarTintColor;
                    self.toFakeBar.alpha = to.cjg_computedBarImage ? 0 : to.cjg_barAlpha;
                    self.toFakeBar.frame = [self fakeBarFrameForViewController:to];
                    [to.view addSubview:self.toFakeBar];
                    
                    self.toFakeShadow.alpha = to.cjg_computedBarShadowAlpha;
                    self.toFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.toFakeBar.frame];
                    [to.view addSubview:self.toFakeShadow];
                }];
            } else {
                [self cjg_updateNavigationBarForViewController:viewController];
            }
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if (context.isCancelled) {
                [self cjg_updateNavigationBarForViewController:from];
            } else {
                // 当 present 时 to 不等于 viewController
                [self cjg_updateNavigationBarForViewController:viewController];
            }
            if (to == viewController) {
                [self clearFake];
            }
        }];
        
        [coordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if (!context.isCancelled && self.inGesture) {
                [self cjg_updateNavigationBarAnimatedForController:viewController];
            }
        }];
        
    } else {
        [self cjg_updateNavigationBarForViewController:viewController];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *vc = [super popViewControllerAnimated:animated];
    self.navigationBar.barStyle = self.topViewController.cjg_barStyle;
    self.navigationBar.titleTextAttributes = self.topViewController.cjg_titleTextAttributes;
    return vc;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray *array = [super popToViewController:viewController animated:animated];
    self.navigationBar.barStyle = self.topViewController.cjg_barStyle;
    self.navigationBar.titleTextAttributes = self.topViewController.cjg_titleTextAttributes;
    return array;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    NSArray *array = [super popToRootViewControllerAnimated:animated];
    self.navigationBar.barStyle = self.topViewController.cjg_barStyle;
    self.navigationBar.titleTextAttributes = self.topViewController.cjg_titleTextAttributes;
    return array;
}

////返回当前控制器状态
- (UIViewController *)childViewControllerForStatusBarStyle {

    return self.topViewController;
}

- (UIVisualEffectView *)fromFakeBar {
    if (!_fromFakeBar) {
        _fromFakeBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _fromFakeBar;
}

- (UIVisualEffectView *)toFakeBar {
    if (!_toFakeBar) {
        _toFakeBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _toFakeBar;
}

- (UIImageView *)fromFakeImageView {
    if (!_fromFakeImageView) {
        _fromFakeImageView = [[UIImageView alloc] init];
    }
    return _fromFakeImageView;
}

- (UIImageView *)toFakeImageView {
    if (!_toFakeImageView) {
        _toFakeImageView = [[UIImageView alloc] init];
    }
    return _toFakeImageView;
}

- (UIImageView *)fromFakeShadow {
    if (!_fromFakeShadow) {
        _fromFakeShadow = [[UIImageView alloc] initWithImage:self.navigationBar.cjg_shadow_view.image];
        _fromFakeShadow.backgroundColor = self.navigationBar.cjg_shadow_view.backgroundColor;
    }
    return _fromFakeShadow;
}

- (UIImageView *)toFakeShadow {
    if (!_toFakeShadow) {
        _toFakeShadow = [[UIImageView alloc] initWithImage:self.navigationBar.cjg_shadow_view.image];
        _toFakeShadow.backgroundColor = self.navigationBar.cjg_shadow_view.backgroundColor;
    }
    return _toFakeShadow;
}

- (void)clearFake {
    [_fromFakeBar removeFromSuperview];
    [_toFakeBar removeFromSuperview];
    [_fromFakeShadow removeFromSuperview];
    [_toFakeShadow removeFromSuperview];
    [_fromFakeImageView removeFromSuperview];
    [_toFakeImageView removeFromSuperview];
    _fromFakeBar = nil;
    _toFakeBar = nil;
    _fromFakeShadow = nil;
    _toFakeShadow = nil;
    _fromFakeImageView = nil;
    _toFakeImageView = nil;
}

- (CGRect)fakeBarFrameForViewController:(UIViewController *)vc {
    UIView *back = self.navigationBar.subviews[0];
    CGRect frame = [self.navigationBar convertRect:back.frame toView:vc.view];
    frame.origin.x = vc.view.frame.origin.x;
    //  解决根视图为scrollView的时候，Push不正常
    if ([vc.view isKindOfClass:[UIScrollView class]]) {
        //  适配iPhoneX
        frame.origin.y = -([UIScreen mainScreen].bounds.size.height == 812.0 ? 88 : 64);
    }
    return frame;
}

- (CGRect)fakeShadowFrameWithBarFrame:(CGRect)frame {
    return CGRectMake(frame.origin.x, frame.size.height + frame.origin.y - 0.5, frame.size.width, 0.5);
}

- (void)cjg_updateNavigationBarForViewController:(UIViewController *)vc {
    //更新navbar的 各种属性。alpha、背景、tintcolor、shodow的透明度
    [self cjg_updateNavigationBarAlphaForViewController:vc];
    [self cjg_updateNavigationBarColorOrImageForViewController:vc];
    [self cjg_updateNavigationBarShadowIAlphaForViewController:vc];
    [self cjg_updateNavigationBarAnimatedForController:vc];
}
/** 更新navbar */
- (void)cjg_updateNavigationBarAnimatedForController:(UIViewController *)vc {
    self.navigationBar.barStyle = vc.cjg_barStyle;
    self.navigationBar.titleTextAttributes = vc.cjg_titleTextAttributes;
    self.navigationBar.tintColor = vc.cjg_tintColor;
}

/**更新navbar的透明度*/
- (void)cjg_updateNavigationBarAlphaForViewController:(UIViewController *)vc {
    if (vc.cjg_computedBarImage) {
        self.navigationBar.cjg_fake_view.alpha = 0;
        self.navigationBar.cjg_background_view.alpha = vc.cjg_barAlpha;
    } else {
        self.navigationBar.cjg_fake_view.alpha = vc.cjg_barAlpha;
        self.navigationBar.cjg_background_view.alpha = 0;
    }
    self.navigationBar.cjg_shadow_view.alpha = vc.cjg_computedBarShadowAlpha;
}

/** 更新navbar的tintcolor为目标vc的tintcolor 背景图为目标vc的背景图 */
- (void)cjg_updateNavigationBarColorOrImageForViewController:(UIViewController *)vc {
    self.navigationBar.barTintColor = vc.cjg_computedBarTintColor;
    self.navigationBar.cjg_background_view.image = vc.cjg_computedBarImage;
}

/** 更新navbar的shadow的透明度 (更新的是自定义bavbar中用来替代shodow的imageV的alpha) */
- (void)cjg_updateNavigationBarShadowIAlphaForViewController:(UIViewController *)vc {
    self.navigationBar.cjg_shadow_view.alpha = vc.cjg_computedBarShadowAlpha;
}

BOOL shouldShowFake(UIViewController *vc,UIViewController *from, UIViewController *to) {
    //如果将要出现的vc与目标vc不一致 return
    if (vc != to ) {
        return NO;
    }
    
    if (from.cjg_computedBarImage && to.cjg_computedBarImage && isImageEqual(from.cjg_computedBarImage, to.cjg_computedBarImage)) {
        // 都有图片，并且是同一张图片
        if (ABS(from.cjg_barAlpha - to.cjg_barAlpha) > 0.1) {
            return YES;
        }
        return NO;
    }
    
    if (!from.cjg_computedBarImage && !to.cjg_computedBarImage && [from.cjg_computedBarTintColor.description isEqual:to.cjg_computedBarTintColor.description]) {
        // 都没图片，并且颜色相同
        if (ABS(from.cjg_barAlpha - to.cjg_barAlpha) > 0.1) {
            return YES;
        }
        return NO;
    }
    
    return YES;
}

BOOL isImageEqual(UIImage *image1, UIImage *image2) {
    if (image1 == image2) {
        return YES;
    }
    if (image1 && image2) {
        NSData *data1 = UIImagePNGRepresentation(image1);
        NSData *data2 = UIImagePNGRepresentation(image2);
        BOOL result = [data1 isEqual:data2];
        return result;
    }
    return NO;
}

UIColor* blendColor(UIColor *from, UIColor *to, float percent) {
    CGFloat fromRed = 0;
    CGFloat fromGreen = 0;
    CGFloat fromBlue = 0;
    CGFloat fromAlpha = 0;
    [from getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed = 0;
    CGFloat toGreen = 0;
    CGFloat toBlue = 0;
    CGFloat toAlpha = 0;
    [to getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat newRed = fromRed + (toRed - fromRed) * percent;
    CGFloat newGreen = fromGreen + (toGreen - fromGreen) * percent;
    CGFloat newBlue = fromBlue + (toBlue - fromBlue) * percent;
    CGFloat newAlpha = fromAlpha + (toAlpha - fromAlpha) * percent;
    return [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}

- (UIModalPresentationStyle)modalPresentationStyle{
    return UIModalPresentationFullScreen;
}



@end
