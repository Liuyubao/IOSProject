//
//  PtzPanelView.m
//  iVMS-8700-MCU
//
//  Created by apple on 15-3-19.
//  Copyright (c) 2015年 HikVision. All rights reserved.
//

#import "PtzPanelView.h"
#import "ToolBarButton.h"
#import "ToolBarButtonPositionReckoner.h"

#define UICOLORTORGB(rgbValue) [UIColor colorWithRed:((float)((strtol([rgbValue UTF8String], 0, 16) & 0xFF0000) >> 16))/255.0 green:((float)((strtol([rgbValue UTF8String], 0, 16) & 0xFF00) >> 8))/255.0 blue:((float)(strtol([rgbValue UTF8String], 0, 16) & 0xFF))/255.0 alpha:1.0]

static int PORTRAIT_BUTTON_SIZE_WIDTH = 64;
static int PORTRAIT_BUTTON_SIZE_HEIGHT = 49;


@implementation PtzPanelView
{
    ToolBarButton *_panAutoButton;               // 自动巡航
    ToolBarButton *_zoomButton;                  // 焦距按钮
    ToolBarButton *_focusButton;                 // 聚焦按钮
    ToolBarButton *_irisButton;                  // 光圈按钮
    ToolBarButton *_presetPositionButton;        // 预置点按钮
    
    UIView *_separateLine1;//分割线
    UIView *_separateLine2;
    UIView *_separateLine3;
    UIView *_separateLine4;
    
}

- (void)setIsPanAutoState:(BOOL)isPanAutoState
{
    _panAutoButton.isStateOn = isPanAutoState;
    _isPanAutoState = isPanAutoState;
}

- (void)setIsZoomState:(BOOL)isZoomState
{
    _zoomButton.isStateOn = isZoomState;
    _isZoomState = isZoomState;
}

- (void)setIsFocusState:(BOOL)isFocusState
{
    _focusButton.isStateOn = isFocusState;
    _isFocusState = isFocusState;
}

- (void)setIsIrisState:(BOOL)isIrisState
{
    _irisButton.isStateOn = isIrisState;
    _isIrisState = isIrisState;
}

- (void)setIsPresetPositionState:(BOOL)isPresetPositionState
{
    _presetPositionButton.isStateOn = isPresetPositionState;
    _isPresetPositionState = isPresetPositionState;
}


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _isFocusState = NO;
        _isIrisState = NO;
        _isPanAutoState= NO;
        _isPresetPositionState = NO;
        _isZoomState = NO;
        _panAutoButton = [[ToolBarButton alloc] initWithPortraitStateOffImage:@"ptz_auto.png"
                                                     portraitStateOffSelImage:@"ptz_auto_sel.png"
                                                         portraitStateOnImage:@"ptz_auto_stay.png"
                                                      portraitStateOnSelImage:@"ptz_auto_sel.png"
                                                      horizontalStateOffImage:@"fullscreen_ptz_auto.png"
                                                   horizontalStateOffSelImage:@"fullscreen_ptz_auto_sel.png"
                                                       horizontalStateOnImage:@"fullscreen_ptz_auto_stay.png"
                                                    horizontalStateOnSelImage:@"fullscreen_ptz_auto_sel.png"];
        _panAutoButton.bounds = CGRectMake(0, 0, PORTRAIT_BUTTON_SIZE_WIDTH, PORTRAIT_BUTTON_SIZE_HEIGHT);
        [_panAutoButton addTarget:self action:@selector(panAutoButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        _panAutoButton.tag = 0;
        [self addSubview:_panAutoButton];
        
        _zoomButton = [[ToolBarButton alloc] initWithPortraitStateOffImage:@"ptz_focal_length.png"
                                                  portraitStateOffSelImage:@"ptz_focal_length_sel.png"
                                                      portraitStateOnImage:@"ptz_focal_length_stay.png"
                                                   portraitStateOnSelImage:@"ptz_focal_length_sel.png"
                                                   horizontalStateOffImage:@"fullscreen_ptz_focal_length.png"
                                                horizontalStateOffSelImage:@"fullscreen_ptz_focal_length_sel.png"
                                                    horizontalStateOnImage:@"fullscreen_ptz_focal_length_stay.png"
                                                 horizontalStateOnSelImage:@"fullscreen_ptz_focal_length_sel.png"];
        _zoomButton.bounds = CGRectMake(0, 0, PORTRAIT_BUTTON_SIZE_WIDTH, PORTRAIT_BUTTON_SIZE_HEIGHT);
        [_zoomButton addTarget:self action:@selector(zoomButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        _zoomButton.tag = 1;
        [self addSubview:_zoomButton];
        
        _focusButton = [[ToolBarButton alloc] initWithPortraitStateOffImage:@"ptz_focus.png"
                                                   portraitStateOffSelImage:@"ptz_focus_sel.png"
                                                       portraitStateOnImage:@"ptz_focus_stay.png"
                                                    portraitStateOnSelImage:@"ptz_focus_sel.png"
                                                    horizontalStateOffImage:@"fullscreen_ptz_focus.png"
                                                 horizontalStateOffSelImage:@"fullscreen_ptz_focus_sel.png"
                                                     horizontalStateOnImage:@"fullscreen_ptz_focus_stay.png"
                                                  horizontalStateOnSelImage:@"fullscreen_ptz_focus_sel.png"];
        _focusButton.bounds = CGRectMake(0, 0, PORTRAIT_BUTTON_SIZE_WIDTH, PORTRAIT_BUTTON_SIZE_HEIGHT);
        [_focusButton addTarget:self action:@selector(focusButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        _focusButton.tag = 2;
        [self addSubview:_focusButton];
        
        _irisButton = [[ToolBarButton alloc] initWithPortraitStateOffImage:@"ptz_aperture.png"
                                                  portraitStateOffSelImage:@"ptz_aperture_sel.png"
                                                      portraitStateOnImage:@"ptz_aperture_stay.png"
                                                   portraitStateOnSelImage:@"ptz_aperture_sel.png"
                                                   horizontalStateOffImage:@"fullscreen_ptz_aperture.png"
                                                horizontalStateOffSelImage:@"fullscreen_ptz_aperture_sel.png"
                                                    horizontalStateOnImage:@"fullscreen_ptz_aperture_stay.png"
                                                 horizontalStateOnSelImage:@"fullscreen_ptz_aperture_sel.png"];
        _irisButton.bounds = CGRectMake(0, 0, PORTRAIT_BUTTON_SIZE_WIDTH, PORTRAIT_BUTTON_SIZE_HEIGHT);
        [_irisButton addTarget:self action:@selector(irisButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        _irisButton.tag = 3;
        [self addSubview:_irisButton];
        
        _presetPositionButton = [[ToolBarButton alloc] initWithPortraitStateOffImage:@"ptz_preset_point.png"
                                                            portraitStateOffSelImage:@"ptz_preset_point_sel.png"
                                                                portraitStateOnImage:@"ptz_preset_point_stay.png"
                                                             portraitStateOnSelImage:@"ptz_preset_point_sel.png"
                                                             horizontalStateOffImage:@"fullscreen_ptz_preset_point.png"
                                                          horizontalStateOffSelImage:@"fullscreen_ptz_preset_point_sel.png"
                                                              horizontalStateOnImage:@"fullscreen_ptz_preset_point_stay.png"
                                                           horizontalStateOnSelImage:@"fullscreen_ptz_preset_point_sel.png"];
        _presetPositionButton.bounds = CGRectMake(0, 0, PORTRAIT_BUTTON_SIZE_WIDTH, PORTRAIT_BUTTON_SIZE_HEIGHT);
        _presetPositionButton.tag = 4;
        [_presetPositionButton addTarget:self action:@selector(presetPositionButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_presetPositionButton];
        
        _separateLine1 = [[UIView alloc] init];
        _separateLine1.bounds = CGRectMake(0, 0, 1, 51);
        _separateLine1.backgroundColor = UICOLORTORGB(@"0xE6E6E6");
        [self addSubview:_separateLine1];
        
        _separateLine2 = [[UIView alloc] init];
        _separateLine2.bounds = _separateLine1.bounds;
        _separateLine2.backgroundColor = UICOLORTORGB(@"0xE6E6E6");
        [self addSubview:_separateLine2];
        
        _separateLine3 = [[UIView alloc] init];
        _separateLine3.bounds = _separateLine1.bounds;
        _separateLine3.backgroundColor = UICOLORTORGB(@"0xE6E6E6");
        [self addSubview:_separateLine3];
        
        _separateLine4 = [[UIView alloc] init];
        _separateLine4.bounds = _separateLine1.bounds;
        _separateLine4.backgroundColor = UICOLORTORGB(@"0xE6E6E6");
        [self addSubview:_separateLine4];
    }
    return self;
}

-(void)layoutSubviews{
    BOOL isOrientationPortrait = ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait);
    NSArray *buttonCenterArray = [[ToolBarButtonPositionReckoner sharedInstance] getButtonCentersWithSuperViewBound:self.bounds buttonCount:5 perPageButtonCount:5 isHorizontal:isOrientationPortrait];
    _panAutoButton.center = [[buttonCenterArray objectAtIndex:0] CGPointValue];
    _zoomButton.center = [[buttonCenterArray objectAtIndex:1] CGPointValue];
    _focusButton.center = [[buttonCenterArray objectAtIndex:2] CGPointValue];
    _irisButton.center = [[buttonCenterArray objectAtIndex:3] CGPointValue];
    _presetPositionButton.center = [[buttonCenterArray objectAtIndex:4] CGPointValue];
    _panAutoButton.isOrientationPortrait = isOrientationPortrait;
    _zoomButton.isOrientationPortrait = isOrientationPortrait;
    _focusButton.isOrientationPortrait = isOrientationPortrait;
    _irisButton.isOrientationPortrait = isOrientationPortrait;
    _presetPositionButton.isOrientationPortrait = isOrientationPortrait;
    if (isOrientationPortrait)
    {
        _separateLine1.center = CGPointMake(([[buttonCenterArray objectAtIndex:0] CGPointValue].x + [[buttonCenterArray objectAtIndex:1] CGPointValue].x) / 2, CGRectGetHeight(self.bounds) / 2);
        _separateLine2.center = CGPointMake(([[buttonCenterArray objectAtIndex:1] CGPointValue].x + [[buttonCenterArray objectAtIndex:2] CGPointValue].x) / 2, CGRectGetHeight(self.bounds) / 2);
        _separateLine3.center = CGPointMake(([[buttonCenterArray objectAtIndex:2] CGPointValue].x + [[buttonCenterArray objectAtIndex:3] CGPointValue].x) / 2, CGRectGetHeight(self.bounds) / 2);
        _separateLine4.center = CGPointMake(([[buttonCenterArray objectAtIndex:3] CGPointValue].x + [[buttonCenterArray objectAtIndex:4] CGPointValue].x) / 2, CGRectGetHeight(self.bounds) / 2);
    }
}

// 自动巡航
- (void)panAutoButtonTouchUpInside:(UIButton *)button
{
    [self.delegate ptzPanelViewPanAutoButtonTouchUpInside];
}

// 焦距按钮
- (void)zoomButtonTouchUpInside:(UIButton *)button
{
    
    [self.delegate ptzPanelViewZoomButtonTouchUpInside];
}

// 聚焦按钮
- (void)focusButtonTouchUpInside:(UIButton *)button
{
    [self.delegate ptzPanelViewFocusButtonTouchUpInside];
}

// 光圈按钮
- (void)irisButtonTouchUpInside:(UIButton *)button
{
    [self.delegate ptzPanelViewIrisButtonTouchUpInside];
}

// 预置点按钮
- (void)presetPositionButtonTouchUpInside:(UIButton *)button
{
    [self.delegate ptzPanelViewPresetPositionButtonTouchUpInside];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
