//
//  MGPopupTool.h
//  MGPopupToolExample
//
//  Created by Luqiang on 2017/11/9.
//  Copyright © 2017年 libcore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MGPopupToolDelegate <NSObject>

@optional
- (void)willPopupShowView:(UIView *)showView;
- (void)didPopupShowView:(UIView *)showView;
- (void)willHideShowView:(UIView *)showView;
- (void)didHideShowView:(UIView *)showView;

@end

@interface MGPopupTool : NSObject

/**
 *  default R:0 G:0 B:0 A:0.2;
 */
@property (nonatomic, strong) UIColor *maskBackgroundColor;

/**
 *  default NO;
 */
@property (nonatomic, assign) BOOL hideAlertWhenClickBackground;
/**
 *  default 0.3;
 */
@property (nonatomic, assign) NSTimeInterval alertDuration;

/**
 *  default YES;
 */
@property (nonatomic, assign) BOOL hideActionSheetWhenClickBackground;
/**
 *  default 0.3;
 */
@property (nonatomic, assign) NSTimeInterval actionSheetDuration;

+ (instancetype)shareInstance;

- (void)alertShow:(UIView *)view;
- (void)actionSheetShow:(UIView *)view;
- (void)alertShow:(UIView *)view delegate:(id<MGPopupToolDelegate>)delegate;
- (void)actionSheetShow:(UIView *)view delegate:(id<MGPopupToolDelegate>)delegate;
- (void)hideTopView;
- (void)hideAllView;

@end
