//
//  ViewController.m
//  MGPopupToolExample
//
//  Created by Luqiang on 2017/11/6.
//  Copyright © 2017年 libcore. All rights reserved.
//

#import "ViewController.h"
#import "MGPopupTool.h"

@interface ViewController () <MGPopupToolDelegate>

@property (weak, nonatomic) IBOutlet UITextField *colorHexTextField;
@property (weak, nonatomic) IBOutlet UISwitch *hideSwitch;
@property (weak, nonatomic) IBOutlet UITextField *duration;
@property (weak, nonatomic) IBOutlet UITextField *colorAlpha;

@property (nonatomic, strong) UIButton *showView;

@end

@implementation ViewController

- (UIView *)showView {
    if (!_showView) {
        _showView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        [_showView addTarget:self action:@selector(_showViewClick:) forControlEvents:UIControlEventTouchUpInside];
        _showView.backgroundColor = [UIColor purpleColor];
    }
    return _showView;
}

- (void)_showViewClick:(UIButton *)button {
    [[MGPopupTool shareInstance] hideTopView];
}

- (void)_setupPopup {
    [self.view endEditing:YES];
    [MGPopupTool shareInstance].hideAlertWhenClickBackground = self.hideSwitch.isOn;
    [MGPopupTool shareInstance].hideActionSheetWhenClickBackground = self.hideSwitch.isOn;
    [MGPopupTool shareInstance].alertDuration = [_duration.text floatValue];
    [MGPopupTool shareInstance].actionSheetDuration = [_duration.text floatValue];
    [MGPopupTool shareInstance].maskBackgroundColor = [self _colorWithHexValue:_colorHexTextField.text alpha:[_colorAlpha.text floatValue]];
}

- (UIColor *)_colorWithHexValue:(NSString *)hexStr alpha:(CGFloat)alpha {
    unsigned rgbValue = 0;
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

- (IBAction)_alertShow:(id)sender {
    [self _setupPopup];
    [[MGPopupTool shareInstance] alertShow:self.showView delegate:self];
}

- (IBAction)actionSheetShow:(id)sender {
    [self _setupPopup];
    [[MGPopupTool shareInstance] actionSheetShow:self.showView delegate:self];
}

- (void)willPopupShowView:(UIView *)showView {
    NSLog(@"willPopupShowView:%@", showView);
}

- (void)didPopupShowView:(UIView *)showView {
    NSLog(@"didPopupShowView:%@", showView);
}

- (void)willHideShowView:(UIView *)showView {
    NSLog(@"willHideShowView:%@", showView);
}

- (void)didHideShowView:(UIView *)showView {
    NSLog(@"didHideShowView:%@", showView);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
