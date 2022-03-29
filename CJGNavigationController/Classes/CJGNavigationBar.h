//
//  CJGNavigationBar.h
//  CJGNavigationController
//
//  Created by Chen Jinguo on 2022/3/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJGNavigationBar : UINavigationBar
@property (nonatomic, strong, readonly) UIImageView *cjg_shadow_view;
@property (nonatomic, strong, readonly) UIVisualEffectView *cjg_fake_view;
@property (nonatomic, strong, readonly) UIImageView *cjg_background_view;
@end

NS_ASSUME_NONNULL_END
