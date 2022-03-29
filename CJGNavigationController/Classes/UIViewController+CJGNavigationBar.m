//
//  UIViewController+CJGNavigationBar.m
//  CJGNavigationController
//
//  Created by Chen Jinguo on 2022/3/29.
//

#import "UIViewController+CJGNavigationBar.h"
#import <objc/runtime.h>
#import "CJGNavigationController.h"

@implementation UIViewController (CJGNavigationBar)
-(UIBarStyle)cjg_barStyle{
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return [obj integerValue];
    }
    return [UINavigationBar appearance].barStyle;
}

- (void)setCjg_barStyle:(UIBarStyle)cjg_barStyle{
    objc_setAssociatedObject(self, @selector(cjg_barStyle), @(cjg_barStyle), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIColor *)cjg_barTintColor{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCjg_barTintColor:(UIColor *)tintColor{
    objc_setAssociatedObject(self, @selector(cjg_barTintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)cjg_barImage{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCjg_barImage:(UIImage *)image{
    objc_setAssociatedObject(self, @selector(cjg_barImage), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)cjg_tintColor{
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ?: [UINavigationBar appearance].tintColor;
}

- (void)setCjg_tintColor:(UIColor *)tintColor{
    objc_setAssociatedObject(self, @selector(cjg_tintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)cjg_titleTextAttributes{
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ?: [UINavigationBar appearance].titleTextAttributes;
}

- (void)setCjg_titleTextAttributes:(NSDictionary *)attributes{
    objc_setAssociatedObject(self, @selector(cjg_titleTextAttributes), attributes, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (float)cjg_barAlpha{
    id obj = objc_getAssociatedObject(self, _cmd);
    if (self.cjg_barHidden) {
        return 0;
    }
    return obj ? [obj floatValue] : 1.0f;
}

- (void)setCjg_barAlpha:(float)alpha{
    objc_setAssociatedObject(self, @selector(cjg_barAlpha), @(alpha), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL) cjg_barHidden{
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setCjg_barHidden:(BOOL)hidden{
    if (hidden) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
        self.navigationItem.titleView = [UIView new];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.titleView = nil;
    }
    objc_setAssociatedObject(self, @selector(cjg_barHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)cjg_barShadowHidden{
    id obj = objc_getAssociatedObject(self, _cmd);
    return self.cjg_barHidden || obj ? [obj boolValue] : NO;
}

- (void)setCjg_barShadowHidden:(BOOL)hidden{
    objc_setAssociatedObject(self, @selector(cjg_barShadowHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)cjg_backInteractive{
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setCjg_backInteractive:(BOOL)interactive{
    objc_setAssociatedObject(self, @selector(cjg_backInteractive), @(interactive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)cjg_swipeBackEnabled{
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setCjg_swipeBackEnabled:(BOOL)enabled{
    objc_setAssociatedObject(self, @selector(cjg_swipeBackEnabled), @(enabled), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (float)cjg_computedBarShadowAlpha{
    return  self.cjg_barShadowHidden ? 0 : self.cjg_barAlpha;
}

- (UIImage *)cjg_computedBarImage{
    UIImage *image = self.cjg_barImage;
    if (!image) {
        if (self.cjg_barTintColor) {
            return nil;
        }
        return [[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault];
    }
    return image;
}

- (UIColor *)cjg_computedBarTintColor{
    if (self.cjg_barImage) {
        return nil;
    }
    UIColor *color = self.cjg_barTintColor;
    if (!color) {
        if ([[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault]) {
            return nil;
        }
        if ([UINavigationBar appearance].barTintColor) {
            color = [UINavigationBar appearance].barTintColor;
        } else {
            color = [UINavigationBar appearance].barStyle == UIBarStyleDefault ? [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:0.8]: [UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:0.729];
        }
    }
    return color;
}

- (void)cjg_setNeedsUpdateNavigationBar{
    if (self.navigationController && [self.navigationController isKindOfClass:[CJGNavigationController class]]) {
        CJGNavigationController *nav = (CJGNavigationController *)self.navigationController;
        [nav cjg_updateNavigationBarForViewController:self];
    }
}

- (void)cjg_setNeedsUpdateNavigationBarAlpha{
    if (self.navigationController && [self.navigationController isKindOfClass:[CJGNavigationController class]]) {
        CJGNavigationController *nav = (CJGNavigationController *)self.navigationController;
        [nav cjg_updateNavigationBarAlphaForViewController:self];
    }
}

- (void)cjg_setNeedsUpdateNavigationBarShadowAlpha{
    if (self.navigationController && [self.navigationController isKindOfClass:[CJGNavigationController class]]) {
        CJGNavigationController *nav = (CJGNavigationController *)self.navigationController;
        [nav cjg_updateNavigationBarShadowIAlphaForViewController:self];
    }
}

- (void)cjg_setNeedsUpdateNavigationBarColorOrImage{
    if (self.navigationController && [self.navigationController isKindOfClass:[CJGNavigationController class]]) {
        CJGNavigationController *nav = (CJGNavigationController *)self.navigationController;
        [nav cjg_updateNavigationBarColorOrImageForViewController:self];
    }
}

@end
