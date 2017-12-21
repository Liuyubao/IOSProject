//
//  PtzPresetPositionMultiDialView.m
//  iVMS-4500
//
//  Created by gumingjun on 14-10-9.
//  Copyright (c) 2014年 HIKVISION. All rights reserved.
//

#import "PtzPresetPositionMultiDialView.h"
#import "ToolBarButtonPositionReckoner.h"

#define NUM_ROWS            500000

#define PTZ_MULTIDIAL_VIEW_WIDTH                        135.0f
#define PTZ_MULTIDIAL_VIEW_HEIGHT                       48.0f

@interface PtzPresetPositionMultiDialView()
{
    NSArray *_numArray;
    NSArray *_firstNumArray;
}

@end

@implementation PtzPresetPositionMultiDialView

- (id)init
{
    self = [super init];
    if (self)
    {
        _numArray = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
        _firstNumArray = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", nil];
        
        self.bounds = CGRectMake(0, 0, PTZ_MULTIDIAL_VIEW_WIDTH, PTZ_MULTIDIAL_VIEW_HEIGHT);
        
        NSArray *array = [[ToolBarButtonPositionReckoner sharedInstance] getButtonCentersWithSuperViewBound:self.bounds buttonCount:3 perPageButtonCount:3 isHorizontal:YES];
        
        _ptzPresetPositionDialView1 = [[PtzPresetPositionDialView alloc] initWithNumArray:_firstNumArray];
        _ptzPresetPositionDialView1.center = [[array objectAtIndex:0] CGPointValue];
        _ptzPresetPositionDialView1.delegate = self;
        [_ptzPresetPositionDialView1 spinToString:@"0"];
        [self addSubview:_ptzPresetPositionDialView1];
        
        _ptzPresetPositionDialView2 = [[PtzPresetPositionDialView alloc] initWithNumArray:_numArray];
        _ptzPresetPositionDialView2.center = [[array objectAtIndex:1] CGPointValue];
        _ptzPresetPositionDialView2.delegate = self;
        [_ptzPresetPositionDialView2 spinToString:@"0"];
        [self addSubview:_ptzPresetPositionDialView2];
        
        _ptzPresetPositionDialView3 = [[PtzPresetPositionDialView alloc] initWithNumArray:_numArray];
        _ptzPresetPositionDialView3.center = [[array objectAtIndex:2] CGPointValue];
        _ptzPresetPositionDialView3.delegate = self;
        [_ptzPresetPositionDialView3 spinToString:@"1"];
        [self addSubview:_ptzPresetPositionDialView3];
    }
    return self;
}

- (void)ptzPresetPositionDialView:(PtzPresetPositionDialView *)ptzPresetPositionDialView didSnapToString:(NSString *)string
{
    if (!_ptzPresetPositionDialView1.isSpinning && !_ptzPresetPositionDialView2.isSpinning && !_ptzPresetPositionDialView3.isSpinning)
    {
        NSString *selectedString = [NSString stringWithFormat:@"%@%@%@", _ptzPresetPositionDialView1.selectedString, _ptzPresetPositionDialView2.selectedString, _ptzPresetPositionDialView3.selectedString];
        int selectedIntValue = [selectedString intValue];
        if (selectedIntValue > 256)
        {
            [_ptzPresetPositionDialView1 spinToString:@"2"];
            [_ptzPresetPositionDialView2 spinToString:@"5"];
            [_ptzPresetPositionDialView3 spinToString:@"6"];
        }
        else if (selectedIntValue == 0)
        {
            [_ptzPresetPositionDialView1 spinToString:@"0"];
            [_ptzPresetPositionDialView2 spinToString:@"0"];
            [_ptzPresetPositionDialView3 spinToString:@"1"];
        }
        else
        {
            [self.delegate ptzPresetPositionMultiDialView:self didSelectString:selectedString];
        }
    }
}

- (void)ptzPresetPositionDialView:(PtzPresetPositionDialView *)ptzPresetPositionDialView isSpinningChanged:(BOOL)isSpinning;
{
    if (isSpinning)
    {// 开始转动
        [self.delegate ptzPresetPositionMultiDialView:self isSpinningChanged:YES];
    }
    else
    {
        if (!_ptzPresetPositionDialView1.isSpinning && !_ptzPresetPositionDialView2.isSpinning && !_ptzPresetPositionDialView3.isSpinning)
        {
            [self.delegate ptzPresetPositionMultiDialView:self isSpinningChanged:NO];
        }
    }
}

// 初始化转动盘数字
- (void)initDialNum
{
    [_ptzPresetPositionDialView1 spinToString:@"0"];
    [_ptzPresetPositionDialView2 spinToString:@"0"];
    [_ptzPresetPositionDialView3 spinToString:@"1"];
}

@end
