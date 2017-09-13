//
//  PBNotificationBanner.m
//  PBBanner
//
//  Created by nanhujiaju on 2017/9/13.
//  Copyright © 2017年 nanhujiaju. All rights reserved.
//

#import "PBNotificationBanner.h"

static NSString * hud_bundlePath() {
    NSString *clsName = @"PBNotificationBanner";
    Class cls = NSClassFromString(clsName);
    return [[NSBundle bundleForClass:cls] pathForResource:clsName ofType:@"bundle"];
}

static UIImage * hud_imageNamed(NSString *name) {
    NSString *bundlePath = hud_bundlePath();
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

#pragma mark --- banner content ---

@interface PBHUDContent : UIView

@property (nonatomic, strong) UIImageView *iconImg;

@property (nonatomic, strong) UILabel *infoLab;

@end

@implementation PBHUDContent

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:img];
        self.iconImg = img;
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectZero];
        lab.font = [UIFont systemFontOfSize:15];
        lab.textColor = [UIColor grayColor];
        [self addSubview:lab];
        self.infoLab = lab;
        
        //self.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat offset = 20;
    [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self).offset(offset);
        make.bottom.equalTo(self).offset(-offset);
        make.width.mas_equalTo(self.iconImg.mas_height);
    }];
    [self.infoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImg);
        make.left.equalTo(self.iconImg.mas_right).offset(offset);
        make.right.equalTo(self).offset(-offset);
        make.bottom.equalTo(self.iconImg);
    }];
}

@end

#pragma mark --- banner HUD ---

@interface PBNotificationBanner ()

@property (nonatomic, strong, nonnull) UIImage *errImg, *sucImg, *infoImg;

@property (nonatomic, strong) PBHUDContent *content;

@property (nonatomic, strong) MASConstraint *topConstraint;

@property (nonatomic, strong) NSTimer *fadeOutTimer;
@end

static PBNotificationBanner * instance = nil;
static CGFloat const PB_HUD_BANNER_EIGHT                =   64;
static CGFloat const PB_HUD_BANNER_SHOW_DURATION        =   1.25;

@implementation PBNotificationBanner

+ (PBNotificationBanner *)sharedView {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect bounds = [UIScreen mainScreen].bounds;
        CGFloat height = PB_HUD_BANNER_EIGHT;
        CGRect sharedBounds = CGRectMake(0, -height, bounds.size.width, height);
        instance = [[[self class] alloc] initWithFrame:sharedBounds];
    });
    return instance;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage *err = hud_imageNamed(@"error");
        self.errImg = [err pb_darkColor:[UIColor redColor] lightLevel:1];
        UIImage *suc = hud_imageNamed(@"success");
        self.sucImg = [suc pb_darkColor:[UIColor greenColor] lightLevel:1];
        UIImage *info = hud_imageNamed(@"info");
        self.infoImg = [info pb_darkColor:[UIColor yellowColor] lightLevel:1];
        
        CGRect contentBounds = [self contentBounds];
        self.content = [[PBHUDContent alloc] initWithFrame:contentBounds];
        [self addSubview:self.content];
        [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).priority(UILayoutPriorityDefaultHigh);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(PB_HUD_BANNER_EIGHT);
            if (!self.topConstraint) {
                self.topConstraint = make.top.equalTo(self).offset(PB_HUD_BANNER_EIGHT).priority(UILayoutPriorityRequired);
            }
        }];
        [self.topConstraint deactivate];
        self.backgroundColor = [UIColor blueColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark --- Getter Methods ---

- (CGRect)contentBounds {
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat height = PB_HUD_BANNER_EIGHT;
    return CGRectMake(0, 0, bounds.size.width, height);
}

- (void)hudWhetherShow:(BOOL)show withCompletion:(void(^_Nullable)())completion {
    //CGFloat pickerHeight = CGRectGetHeight(self.audioRecView.bounds);
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.55
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.5
                        options:(UIViewAnimationOptionBeginFromCurrentState|
                                 UIViewAnimationOptionCurveEaseInOut|
                                 UIViewAnimationOptionLayoutSubviews)
                     animations:^{
                         //weakSelf.recordTopConstraint.constant = hidden ? 0.f : -pickerHeight;
                         show?[weakSelf.topConstraint activate]:[weakSelf.topConstraint deactivate];
                         [weakSelf layoutSubviews];
                     } completion:^(BOOL finished) {
                         if (finished) {
                             if (completion) {
                                 completion();
                             }
                         }
                     }];
}

- (void)excuteCompletion:(void(^_Nullable)())completion {
    
}

+ (void)showInfoWithStatus:(NSString *)status {
    [[self sharedView] showImage:[self sharedView].infoImg withStatus:status];
}

+ (void)showErrorWithStatus:(NSString *)status {
    [[self sharedView] showImage:[self sharedView].errImg withStatus:status];
}

+ (void)showSuccessWithStatus:(NSString *)status {
    [[self sharedView] showImage:[self sharedView].sucImg withStatus:status];
}

+ (BOOL)isVisible {
    return [UIApplication sharedApplication].delegate.window.windowLevel == UIWindowLevelAlert;
}

- (void)showImage:(UIImage *)img withStatus:(NSString *)status {
    __weak typeof(self) wkSlf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong typeof(wkSlf) stgSlf = wkSlf;
        // Stop timer
        if (stgSlf.fadeOutTimer) {
            if ([stgSlf.fadeOutTimer isValid]) {
                [stgSlf.fadeOutTimer invalidate];
            }
            stgSlf.fadeOutTimer = nil;
        }
        
        //reset content image and info
        stgSlf.content.iconImg.image = img;
        stgSlf.content.infoLab.text = status;
        
        /// Add to window
        [UIApplication sharedApplication].delegate.window.windowLevel = UIWindowLevelAlert;
        [[UIApplication sharedApplication].delegate.window addSubview:self];
        
        //show content
        [stgSlf hudWhetherShow:true withCompletion:nil];
        
        //reset timer
        self.fadeOutTimer = [NSTimer timerWithTimeInterval:PB_HUD_BANNER_SHOW_DURATION target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
    }];
}

- (void)dismiss {
    __weak typeof(self) wkSlf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong typeof(wkSlf) stgSlf = wkSlf;
        // Stop timer
        if (stgSlf.fadeOutTimer) {
            if ([stgSlf.fadeOutTimer isValid]) {
                [stgSlf.fadeOutTimer invalidate];
            }
            stgSlf.fadeOutTimer = nil;
        }
        
        __block void(^dismissCompletion)() = ^{
            [UIApplication sharedApplication].delegate.window.windowLevel = UIWindowLevelNormal;
            [stgSlf removeFromSuperview];
        };
        [stgSlf hudWhetherShow:false withCompletion:dismissCompletion];
    }];
}

@end
