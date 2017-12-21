//
//  PtzPresetPositionPopView.m
//  iVMS-4500
//
//  Created by gumingjun on 14-10-9.
//  Copyright (c) 2014年 HIKVISION. All rights reserved.
//

#import "PtzPresetPositionPopView.h"


#define PTZ_PRESET_BUTTON_1_WIDTH                         89.0f
#define PTZ_PRESET_BUTTON_1_HEIGHT                        33.0f

#define PTZ_PRESET_BUTTON_2_WIDTH                         183.5f
#define PTZ_PRESET_BUTTON_2_HEIGHT                        33.0f

#define PTZ_PRESET_POSITION_MIN     1
#define PTZ_PRESET_POSITION_MAX     256

#define PTZ_COMMAND_PRESET_SET          8       //设置预置点
#define PTZ_COMMAND_PRESET_CLEAN        9       //清除预置点
#define PTZ_COMMAND_PRESET_GOTO         39      //调用预置点

@interface PtzPresetPositionPopView()
<
PtzPresetPositionMultiDialViewDelegate
>

{
    PtzPresetPositionMultiDialView *_ptzPresetPositionMultiDialView;
    NSString *_selectedString;
}

@end

@implementation PtzPresetPositionPopView

#pragma mark - Override

- (id)init
{
    self = [super init];
    if (self)
    {
        self.alpha = 0;
        self.bounds = CGRectMake(0, 0, 192, 124);
        
        _selectedString = @"1";
        
        UIImageView *backGroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ptz_presetpanelbg.png"]];
        [self addSubview:backGroundImageView];
        
        _ptzPresetPositionMultiDialView = [[PtzPresetPositionMultiDialView alloc] init];
        _ptzPresetPositionMultiDialView.delegate = self;
        _ptzPresetPositionMultiDialView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(_ptzPresetPositionMultiDialView.frame) / 2);
        [self addSubview:_ptzPresetPositionMultiDialView];
    
        UIButton *presetGotoButton = [[UIButton alloc] init];
        presetGotoButton.bounds = CGRectMake(0, 0, PTZ_PRESET_BUTTON_2_WIDTH, PTZ_PRESET_BUTTON_2_HEIGHT);
        presetGotoButton.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) - CGRectGetHeight(presetGotoButton.frame) / 2 - 5);
        [presetGotoButton setTitle:@"调用" forState:UIControlStateNormal];
        presetGotoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [presetGotoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [presetGotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [presetGotoButton setBackgroundImage:[UIImage imageNamed:@"ptz_del_btn.png"] forState:UIControlStateNormal];
        [presetGotoButton setBackgroundImage:[UIImage imageNamed:@"ptz_del_btnsel.png"] forState:UIControlStateHighlighted];
        [presetGotoButton addTarget:self action:@selector(presetGotoButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:presetGotoButton];
        
        UIButton *presetSetButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(presetGotoButton.frame), 50, PTZ_PRESET_BUTTON_1_WIDTH, PTZ_PRESET_BUTTON_1_HEIGHT)];
        [presetSetButton setTitle:@"设置" forState:UIControlStateNormal];
        presetSetButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [presetSetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [presetSetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [presetSetButton setBackgroundImage:[UIImage imageNamed:@"ptz_presetbtn.png"] forState:UIControlStateNormal];
        [presetSetButton setBackgroundImage:[UIImage imageNamed:@"ptz_presetbtnsel.png"] forState:UIControlStateHighlighted];
        [presetSetButton addTarget:self action:@selector(presetSetButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:presetSetButton];
        
        UIButton *presetDelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(presetGotoButton.frame) - PTZ_PRESET_BUTTON_1_WIDTH, CGRectGetMinY(presetSetButton.frame), PTZ_PRESET_BUTTON_1_WIDTH, PTZ_PRESET_BUTTON_1_HEIGHT)];
        [presetDelButton setTitle:@"删除" forState:UIControlStateNormal];
        presetDelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [presetDelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [presetDelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [presetDelButton setBackgroundImage:[UIImage imageNamed:@"ptz_presetbtn.png"] forState:UIControlStateNormal];
        [presetDelButton setBackgroundImage:[UIImage imageNamed:@"ptz_presetbtnsel.png"] forState:UIControlStateHighlighted];
        [presetDelButton addTarget:self action:@selector(presetDelButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:presetDelButton];
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1.0;
        }];
    }
    return self;
}

#pragma mark - UIButtonTouchUpInside
//点击设置按钮
- (void)presetSetButtonTouchUpInside:(UIButton *)button
{
    [self.delegate ptzPresetPositionPopViewButtonTouchUpInside];
    [self ptzPresetPositionOperation:PTZ_COMMAND_PRESET_SET];
}

//点击删除按钮
- (void)presetDelButtonTouchUpInside:(UIButton *)button
{
    [self.delegate ptzPresetPositionPopViewButtonTouchUpInside];
    [self ptzPresetPositionOperation:PTZ_COMMAND_PRESET_CLEAN];
}

//点击调用按钮
- (void)presetGotoButtonTouchUpInside:(UIButton *)button
{
    [self.delegate ptzPresetPositionPopViewButtonTouchUpInside];
    [self ptzPresetPositionOperation:PTZ_COMMAND_PRESET_GOTO];
}

//发送云台命令
- (void)ptzPresetPositionOperation:(int)command
{
    int index = [_selectedString intValue];
    if (index < PTZ_PRESET_POSITION_MIN || index > PTZ_PRESET_POSITION_MAX)
    {
        
//#error 预置点调用范围1-256
//        [SVProgressHUD showErrorWithStatus:@"预置点调用范围1-256"];
        
        return;
    }
    [self.delegate ptzPresetPositionOperation:command index:index];
}

#pragma mark - PtzPresetPositionMultiDialViewDelegate
- (void)ptzPresetPositionMultiDialView:(PtzPresetPositionMultiDialView *)ptzPresetPositionMultiDialView didSelectString:(NSString *)string
{
    _selectedString = string;
}


- (void)ptzPresetPositionMultiDialView:(PtzPresetPositionMultiDialView *)ptzPresetPositionMultiDialView isSpinningChanged:(BOOL)isSpinning
{
    [self.delegate ptzPresetPositionPopViewDialIsSpinningChanged:isSpinning];
}

@end
