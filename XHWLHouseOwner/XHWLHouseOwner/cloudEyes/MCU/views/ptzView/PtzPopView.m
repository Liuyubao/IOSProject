//
//  PtzPopView.m
//  iVMS-4500
//
//  Created by gumingjun on 14-10-8.
//  Copyright (c) 2014年 HIKVISION. All rights reserved.
//



#import "PtzPopView.h"

//云台控制
#define PTZ_COMMAND_ZOOM_IN             11      //焦距增大
#define PTZ_COMMAND_ZOOM_OUT            12      //焦距减小
#define PTZ_COMMAND_FOCUS_NEAR          13      //聚焦增大
#define PTZ_COMMAND_FOCUS_FAR           14      //聚焦减小
#define PTZ_COMMAND_IRIS_OPEN           15      //光圈增大
#define PTZ_COMMAND_IRIS_CLOSE          16      //光圈减小

@interface PtzPopView()
{
    UIButton *_leftButton;
    UIButton *_rightButton;
    UILabel *_titleLabel;
}

@end

@implementation PtzPopView

- (void)setPtzPopInterface:(PtzPopInterface)ptzPopInterface
{
    if (self.ptzPopInterface == ptzPopInterface)
    {
        return;
    }
    self.alpha = 0;
    switch (ptzPopInterface)
    {
        case PtzPopZoomInterface:
            [_leftButton setImage:[UIImage imageNamed:@"ptz_narrow.png"] forState:UIControlStateNormal];
            [_leftButton setImage:[UIImage imageNamed:@"ptz_narrow_sel.png"] forState:UIControlStateHighlighted];
            [_rightButton setImage:[UIImage imageNamed:@"ptz_amplification.png"] forState:UIControlStateNormal];
            [_rightButton setImage:[UIImage imageNamed:@"ptz_amplification_sel.png"] forState:UIControlStateHighlighted];
            _titleLabel.text = @"焦距";
            break;
            
        case PtzPopFocusInterface:
            [_leftButton setImage:[UIImage imageNamed:@"ptz_focus_front.png"] forState:UIControlStateNormal];
            [_leftButton setImage:[UIImage imageNamed:@"ptz_focus_front_sel.png"] forState:UIControlStateHighlighted];
            [_rightButton setImage:[UIImage imageNamed:@"ptz_focus_behind.png"] forState:UIControlStateNormal];
            [_rightButton setImage:[UIImage imageNamed:@"ptz_focus_behind_sel.png"] forState:UIControlStateHighlighted];
            _titleLabel.text = @"聚焦";
            break;
            
        case PtzPopIrisInterface:
            [_leftButton setImage:[UIImage imageNamed:@"ptz_aperture_big.png"] forState:UIControlStateNormal];
            [_leftButton setImage:[UIImage imageNamed:@"ptz_aperture_big_sel.png"] forState:UIControlStateHighlighted];
            [_rightButton setImage:[UIImage imageNamed:@"ptz_aperture_small.png"] forState:UIControlStateNormal];
            [_rightButton setImage:[UIImage imageNamed:@"ptz_aperture_small_sel.png"] forState:UIControlStateHighlighted];
            _titleLabel.text = @"光圈";
            break;
            
        default:
            break;
    }
    
    _ptzPopInterface = ptzPopInterface;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0f;
    }];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
        self.bounds = CGRectMake(0, 0, 192, 60);
        
        UIImageView *backGroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ptz_up_box_bg.png"]];
        [self addSubview:backGroundImageView];
        
        _leftButton = [[UIButton alloc] init];
        _leftButton.bounds = CGRectMake(0, 0, 44, 44);
        _leftButton.center = CGPointMake(22, CGRectGetHeight(self.frame) / 2);
        [_leftButton addTarget:self action:@selector(leftButtonTouchDown:)
                    forControlEvents:UIControlEventTouchDown];
        [_leftButton addTarget:self action:@selector(leftButtonTouchUp:)
                    forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [self addSubview:_leftButton];
        
        _rightButton = [[UIButton alloc] init];
        _rightButton.bounds = CGRectMake(0, 0, 44, 44);
        _rightButton.center = CGPointMake(CGRectGetWidth(self.frame) - 22, CGRectGetHeight(self.frame) / 2);
        [_rightButton addTarget:self action:@selector(rightButtonTouchDown:)
                    forControlEvents:UIControlEventTouchDown];
        [_rightButton addTarget:self action:@selector(rightButtonTouchUp:)
                    forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [self addSubview:_rightButton];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.bounds = CGRectMake(0, 0, 70, 44);
        _titleLabel.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)leftButtonTouchDown:(UIButton *)button
{
    int command = [self commandOfCurrentInterface:YES];
    if (command > 0)
    {
        [self.delegate ptzPopViewOperation:command stop:NO end:NO];
    }
}

- (void)leftButtonTouchUp:(UIButton *)button
{
    int command = [self commandOfCurrentInterface:YES];
    if (command > 0)
    {
        [self.delegate ptzPopViewOperation:command stop:YES end:YES];
    }
}

- (void)rightButtonTouchDown:(UIButton *)button
{
    int command = [self commandOfCurrentInterface:NO];
    if (command > 0)
    {
        [self.delegate ptzPopViewOperation:command stop:NO end:NO];
    }
}

- (void)rightButtonTouchUp:(UIButton *)button
{
    int command = [self commandOfCurrentInterface:NO];
    if (command > 0)
    {
        [self.delegate ptzPopViewOperation:command stop:YES end:YES];
    }
}

- (int)commandOfCurrentInterface:(BOOL)isLeftButton
{
    int command = 0;
    switch (self.ptzPopInterface)
    {
        case PtzPopZoomInterface:
            command = isLeftButton ? PTZ_COMMAND_ZOOM_IN : PTZ_COMMAND_ZOOM_OUT;
            break;
            
        case PtzPopFocusInterface:
            command = isLeftButton ? PTZ_COMMAND_FOCUS_NEAR : PTZ_COMMAND_FOCUS_FAR;
            break;
            
        case PtzPopIrisInterface:
            command = isLeftButton ? PTZ_COMMAND_IRIS_OPEN : PTZ_COMMAND_IRIS_CLOSE;
            break;
            
        default:
            break;
    }
    return  command;
}

@end
