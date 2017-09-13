//
//  PBNotificationBanner.h
//  PBBanner
//
//  Created by nanhujiaju on 2017/9/13.
//  Copyright © 2017年 nanhujiaju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PBKits/PBKits.h>
#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import <Masonry/Masonry.h>

@interface PBNotificationBanner : UIView

/**
 show info banner
 */
+ (void)showInfoWithStatus:(NSString * _Nullable)status;

/**
 show success banner
 */
+ (void)showSuccessWithStatus:(NSString * _Nullable)status;

/**
 show error banner
 */
+ (void)showErrorWithStatus:(NSString * _Nullable)status;

/**
 whether banner show
 */
+ (BOOL)isVisible;

@end
