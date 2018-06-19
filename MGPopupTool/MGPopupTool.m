//
//  MGPopupTool.m
//  MGPopupToolExample
//
//  Created by Luqiang on 2017/11/9.
//  Copyright © 2017年 libcore. All rights reserved.
//

#import "MGPopupTool.h"

typedef NS_ENUM(NSUInteger, MGPopupType) {
    MGPopupTypeAlert,
    MGPopupTypeActionSheet
};

@interface MGPopupContainerView : UIView

@property (nonatomic, strong) UIView *showView;
@property (nonatomic, weak) id<MGPopupToolDelegate> delegate;
/**
 *  点击背景是否自动隐藏
 *  默认：YES
 */
@property (nonatomic, assign) BOOL hideShowViewWhenClickBackground;
/**
 *  显示、隐藏动画持续时间
 *  默认：0.3
 */
@property (nonatomic, assign) NSTimeInterval duration;
/**
 *  蒙版颜色
 *  默认：黑
 */
@property (nonatomic, strong) UIColor *maskBackgroundColor;
/**
 *  视图弹出方式
 *  默认：从底部移出
 */
@property (nonatomic, assign) MGPopupType type;
- (void)showView:(UIView *)showView;
- (void)showView:(UIView *)showView type:(MGPopupType)type;
- (void)hide;

@end

@interface MGPopupContainerView () <UIGestureRecognizerDelegate>

@property (nonatomic, readonly, weak) UIWindow *window;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) BOOL showState;

@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;

@property (nonatomic, assign) CGFloat R;
@property (nonatomic, assign) CGFloat G;
@property (nonatomic, assign) CGFloat B;
@property (nonatomic, assign) CGFloat A;


@end

@implementation MGPopupContainerView

- (void)dealloc {
    NSLog(@"dealloc MGPopupContainerView");
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _setup];
        [self _setupUI];
        [self _setupLayout];
        [self _setupAction];
    }
    return self;
}

- (void)_setup {
    self.screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.type = MGPopupTypeActionSheet;
    self.showState = NO;
    self.duration = 0.3;
    self.maskBackgroundColor = nil;
}

- (void)_setupUI {
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    self.backgroundView.clipsToBounds = YES;
    self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.clipsToBounds = YES;
    [self.backgroundView addSubview:self.contentView];
    [self addSubview:self.backgroundView];
}

- (void)_setupLayout {
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.backgroundView.frame = self.frame;
}

- (void)_setupAction {
    UITapGestureRecognizer *backgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapBackground:)];
    backgroundTap.delegate = self;
    [self.backgroundView addGestureRecognizer:backgroundTap];
    
    UITapGestureRecognizer *contentTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapContent:)];
    contentTap.delegate = self;
    [self.contentView addGestureRecognizer:contentTap];
}

- (void)_tapBackground:(UITapGestureRecognizer *)tap {
    if (self.hideShowViewWhenClickBackground) {
        [[MGPopupTool shareInstance] hideTopView];
    }
}

- (void)_tapContent:(UITapGestureRecognizer *)tap {
    //屏蔽向底层传递事件
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    if ([touch.view isEqual:self.backgroundView]) {
        return YES;
    }
    return  NO;
}

#pragma mark - Getter And Setter
- (void)setShowView:(UIView *)showView {
    _showView = showView;
    [self.contentView.layer setMasksToBounds:YES];
    [self.contentView.layer setCornerRadius:showView.layer.cornerRadius];
    [self.contentView.layer setMask:showView.layer.mask];
}

- (void)setMaskBackgroundColor:(UIColor *)maskBackgroundColor {
    _maskBackgroundColor = maskBackgroundColor;
    CGFloat r=0,g=0,b=0,a=0;
    if ([maskBackgroundColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [maskBackgroundColor getRed:&r green:&g blue:&b alpha:&a];
        _R = r;
        _G = g;
        _B = b;
        _A = a;
    } else {
        NSAssert(YES, @"蒙版背景色设置失败！");
    }
}


#pragma mark - Public Method
- (void)showView:(UIView *)showView {
    [self showView:showView type:self.type];
}

- (void)showView:(UIView *)showView type:(MGPopupType)type {
    if (self.showState) {
        return;
    }
    self.showState = YES;
    [self willPopup];
    self.showView = showView;
    self.type = type;
    switch (type) {
        case MGPopupTypeActionSheet:
        {
            [self _setupMoveFromBottom];
            [self _showMoveFromBottom];
        }
            break;
        case MGPopupTypeAlert:
        {
            [self _setupShowInMiddle];
            [self _showShowInMiddle];
        }
            break;
            
        default:
            break;
    }
}

- (void)hide {
    if (!self.showState) {
        return;
    }
    [self endEditing:YES];
    self.showState = NO;
    [self willHide];
    switch (self.type) {
        case MGPopupTypeActionSheet:
        {
            [self _hideMoveFromBottom];
        }
            break;
        case MGPopupTypeAlert:
        {
            [self _hideShowInMiddle];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - 辅助方法

- (void)_setupCommon {
    if (!self.superview) {
        [self.window addSubview:self];
    }
    self.contentView.frame = self.showView.frame;
    [self.contentView addSubview:self.showView];
    CGRect frame = self.showView.frame;
    frame.origin = CGPointMake(0, 0);
    self.showView.frame = frame;
    [self _setBackgroundViewAlpha:0.0f];
}

- (void)_setupMoveFromBottom {
    [self _setupCommon];
    self.contentView.frame = CGRectMake((self.screenWidth - self.contentView.frame.size.width) / 2.0f, self.backgroundView.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
    [self _setContentViewAlpha:1];
}

- (void)_setupShowInMiddle {
    [self _setupCommon];
    CGRect originFrame = self.contentView.frame;
    originFrame.origin = CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0f - originFrame.size.width / 2.0f, [UIScreen mainScreen].bounds.size.height / 2.0f - originFrame.size.height / 2.0f);
    self.contentView.frame = originFrame;
    [self _setContentViewAlpha:0];
}

- (void)_showMoveFromBottom {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:_duration animations:^{
        [weakSelf _setBackgroundViewAlpha:weakSelf.A];
        CGRect showFrame = weakSelf.contentView.frame;
        showFrame.origin.y -= weakSelf.contentView.frame.size.height;
        weakSelf.contentView.frame = showFrame;
    } completion:^(BOOL finished) {
        if (finished && weakSelf.showState) {
            [weakSelf didPopup];
        }
    }];
}

- (void)_showShowInMiddle {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:_duration animations:^{
        [weakSelf _setBackgroundViewAlpha:weakSelf.A];
        [weakSelf _setContentViewAlpha:1];
    } completion:^(BOOL finished) {
        if (finished && weakSelf.showState) {
            [weakSelf didPopup];
        }
    }];
}

- (void)_hideMoveFromBottom {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:_duration animations:^{
        [weakSelf _setBackgroundViewAlpha:0.0f];
        CGRect showFrame = weakSelf.contentView.frame;
        showFrame.origin.y = weakSelf.backgroundView.frame.size.height;
        weakSelf.contentView.frame = showFrame;
    } completion:^(BOOL finished) {
        if (finished && !weakSelf.showState) {
            [weakSelf removeFromSuperview];
            [weakSelf.showView removeFromSuperview];
            [weakSelf didHide];
        }
    }];
}

- (void)_hideShowInMiddle {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:_duration animations:^{
        [weakSelf _setBackgroundViewAlpha:0.0f];
        [weakSelf _setContentViewAlpha:0.0f];
    } completion:^(BOOL finished) {
        if (finished && !weakSelf.showState) {
            [weakSelf removeFromSuperview];
            [weakSelf.showView removeFromSuperview];
            [weakSelf didHide];
        }
    }];
}

- (void)_setBackgroundViewAlpha:(CGFloat)alpha {
    self.backgroundView.backgroundColor = [UIColor colorWithRed:_R green:_G blue:_B alpha:alpha];
}

- (void)_setContentViewAlpha:(CGFloat)alpha {
    self.contentView.alpha = alpha;
}

#pragma mark - Getter And Setter

- (UIWindow *)window {
    return [[UIApplication sharedApplication].delegate window];
}

#pragma mark - 协议方法
- (void)willPopup {
    if (self.delegate && [self.delegate respondsToSelector:@selector(willPopupShowView:)]) {
        [self.delegate willPopupShowView:self.showView];
    }
}
- (void)didPopup {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPopupShowView:)]) {
        [self.delegate didPopupShowView:self.showView];
    }
}
- (void)willHide {
    if (self.delegate && [self.delegate respondsToSelector:@selector(willHideShowView:)]) {
        [self.delegate willHideShowView:self.showView];
    }
}
- (void)didHide {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didHideShowView:)]) {
        [self.delegate didHideShowView:self.showView];
    }
}

@end

@interface MGPopupTool ()

@property (nonatomic, strong) NSMutableArray *containerQueues;
@property (nonatomic, strong) NSMutableArray *showViewQueues;

@end

@implementation MGPopupTool

static MGPopupTool *instance;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MGPopupTool alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.containerQueues = [NSMutableArray new];
        self.showViewQueues = [NSMutableArray new];
        self.hideAlertWhenClickBackground = NO;
        self.hideActionSheetWhenClickBackground = YES;
        self.alertDuration = 0.3;
        self.actionSheetDuration = 0.3;
        self.maskBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    }
    return self;
}

#pragma mark - Public Method
- (void)alertShow:(UIView *)view {
    [self alertShow:view delegate:nil];
}

- (void)actionSheetShow:(UIView *)view {
    [self actionSheetShow:view delegate:nil];
}

- (void)alertShow:(UIView *)view delegate:(id<MGPopupToolDelegate>)delegate {
    [self _showView:view type:MGPopupTypeAlert hideShowViewWhenClickBackground:_hideAlertWhenClickBackground animationDuration:_alertDuration maskBackgroundColor:_maskBackgroundColor delegate:delegate];
}
- (void)actionSheetShow:(UIView *)view delegate:(id<MGPopupToolDelegate>)delegate {
    [self _showView:view type:MGPopupTypeActionSheet hideShowViewWhenClickBackground:_hideActionSheetWhenClickBackground animationDuration:_actionSheetDuration maskBackgroundColor:_maskBackgroundColor delegate:delegate];
}

- (void)hideTopView {
    if (self.containerQueues.count) {
        MGPopupContainerView *popupContainer = self.containerQueues.lastObject;
        [popupContainer hide];
        [self.showViewQueues removeObject:popupContainer.showView];
        [self.containerQueues removeObject:popupContainer];
    }
}

- (void)hideAllView {
    for (MGPopupContainerView *popupContainer in self.containerQueues) {
        [popupContainer hide];
    }
    [self.showViewQueues removeAllObjects];
    [self.containerQueues removeAllObjects];
}

#pragma mark - Help Method
- (void)_showView:(UIView *)view type:(MGPopupType)type hideShowViewWhenClickBackground:(BOOL)hideShowViewWhenClickBackground  animationDuration:(NSTimeInterval)duration maskBackgroundColor:(UIColor *)maskColor delegate:(id<MGPopupToolDelegate>)delegate {
    if ([self.showViewQueues indexOfObject:view] != NSNotFound) {
        //防止重复显示同一个View
        return;
    }
    MGPopupContainerView *popupContainer = [[MGPopupContainerView alloc] init];
    popupContainer.delegate = delegate;
    popupContainer.type = type;
    popupContainer.hideShowViewWhenClickBackground = hideShowViewWhenClickBackground;
    popupContainer.duration = duration;
    if (!self.containerQueues.count) {
        //如果是第一次弹出设置蒙版背景色
        popupContainer.maskBackgroundColor = maskColor;
    } else {
        //否则蒙版背景色为透明
        popupContainer.maskBackgroundColor = [UIColor clearColor];
    }
    [popupContainer showView:view];
    [self.showViewQueues addObject:view];
    [self.containerQueues addObject:popupContainer];
}
@end
