//
//  CJGNavigationBar.m
//  CJGNavigationController
//
//  Created by Chen Jinguo on 2022/3/29.
//

#import "CJGNavigationBar.h"
@interface CJGNavigationBar()
@property (nonatomic, strong, readwrite) UIImageView *cjg_shadow_view;
@property (nonatomic, strong, readwrite) UIVisualEffectView *cjg_fake_view;
@property (nonatomic, strong, readwrite) UIImageView *cjg_background_view;
@end
@implementation CJGNavigationBar
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }
    
    UIView *view = [super hitTest:point withEvent:event];
    
    //获取类名 去掉前缀'_'
    NSString *viewName = [[[view classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    
    if (view && [viewName isEqualToString:@"CJGNavigationBar"]) {
        for (UIView *subview in self.subviews) {
            NSString *viewName = [[[subview classForCoder] description] stringByReplacingOccurrencesOfString:@"_" withString:@""];
            NSArray *array = @[ @"UINavigationItemButtonView" ];
            if ([array containsObject:viewName]) {
                CGPoint convertedPoint = [self convertPoint:point toView:subview];
                CGRect bounds = subview.bounds;
                if (bounds.size.width < 80) {
                    bounds = CGRectInset(bounds, bounds.size.width - 80, 0);
                }
                if (CGRectContainsPoint(bounds, convertedPoint)) {
                    return view;
                }
            }
        }
    }
    
    //如果隐藏了 不响应点击
    NSArray *array = @[@"UINavigationBarContentView", @"CJGNavigationBar" ];
    if ([array containsObject:viewName]) {
        if (self.cjg_background_view.image) {
            if (self.cjg_background_view.alpha < 0.01) {
                return nil;
            }
        } else if (self.cjg_fake_view.alpha < 0.01) {
            return nil;
        }
    }
    //点击状态栏
    if (CGRectEqualToRect(view.bounds, CGRectZero)) {
        return nil;
    }
    return view;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.cjg_fake_view.frame = self.cjg_fake_view.superview.bounds;
    self.cjg_background_view.frame = self.cjg_background_view.superview.bounds;
    self.cjg_shadow_view.frame = CGRectMake(0, CGRectGetHeight(self.cjg_shadow_view.superview.bounds) - 0.5, CGRectGetWidth(self.cjg_shadow_view.superview.bounds), 0.5);
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    self.cjg_fake_view.subviews.lastObject.backgroundColor =  barTintColor;
    [self makeSurecjg_fake_view];
}

- (UIView *)cjg_fake_view {
    if (!_cjg_fake_view) {
        [super setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        _cjg_fake_view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _cjg_fake_view.userInteractionEnabled = NO;
        _cjg_fake_view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[self.subviews firstObject] insertSubview:_cjg_fake_view atIndex:0];
    }
    return _cjg_fake_view;
}

- (UIImageView *)cjg_background_view {
    if (!_cjg_background_view) {
        _cjg_background_view = [[UIImageView alloc] init];
        _cjg_background_view.userInteractionEnabled = NO;
        _cjg_background_view.contentScaleFactor = 1;
        _cjg_background_view.contentMode = UIViewContentModeScaleToFill;
        _cjg_background_view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[self.subviews firstObject] insertSubview:_cjg_background_view aboveSubview:self.cjg_fake_view];
    }
    return _cjg_background_view;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {
    self.cjg_background_view.image = backgroundImage;
    [self makeSurecjg_fake_view];
}

- (void)setTranslucent:(BOOL)translucent {
    // prevent default behavior
    [super setTranslucent:YES];
}

- (void)setShadowImage:(UIImage *)shadowImage {
    self.cjg_shadow_view.image = shadowImage;
    if (shadowImage) {
        self.cjg_shadow_view.backgroundColor = nil;
    } else {
        if (@available(iOS 13.0, *)) {
            self.cjg_shadow_view.backgroundColor = UIColor.separatorColor;
        } else {
            self.cjg_shadow_view.backgroundColor = UIColor.lightGrayColor;
        }
    }
}

- (UIImageView *)cjg_shadow_view {
    if (!_cjg_shadow_view) {
        [super setShadowImage:[UIImage new]];
        _cjg_shadow_view = [[UIImageView alloc] init];
        _cjg_shadow_view.userInteractionEnabled = NO;
        _cjg_shadow_view.contentScaleFactor = 1;
        [[self.subviews firstObject] insertSubview:_cjg_shadow_view aboveSubview:self.cjg_background_view];
    }
    return _cjg_shadow_view;
}

- (void)makeSurecjg_fake_view {
    [UIView setAnimationsEnabled:NO];
    if (!self.cjg_fake_view.superview) {
        [[self.subviews firstObject] insertSubview:_cjg_fake_view atIndex:0];
        self.cjg_fake_view.frame = self.cjg_fake_view.superview.bounds;
        
    }
    
    if (!self.cjg_shadow_view.superview) {
        [[self.subviews firstObject] insertSubview:_cjg_shadow_view aboveSubview:self.cjg_background_view];
        self.cjg_shadow_view.frame = CGRectMake(0, CGRectGetHeight(self.cjg_shadow_view.superview.bounds) - 0.5, CGRectGetWidth(self.cjg_shadow_view.superview.bounds), 0.5);
    }
    
    if (!self.cjg_background_view.superview) {
        [[self.subviews firstObject] insertSubview:_cjg_background_view aboveSubview:self.cjg_fake_view];
        self.cjg_background_view.frame = self.cjg_background_view.superview.bounds;
    }
    [UIView setAnimationsEnabled:YES];
}
@end
