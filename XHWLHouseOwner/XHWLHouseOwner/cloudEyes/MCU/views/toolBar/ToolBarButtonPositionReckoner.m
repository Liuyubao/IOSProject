//
//  ToolBarButtonPositionReckoner.m
//  iVMS-4500
//
//  Created by gumingjun on 14-9-17.
//  Copyright (c) 2014年 HIKVISION. All rights reserved.
//

#import "ToolBarButtonPositionReckoner.h"
#import <UIKit/UIKit.h>
@implementation ToolBarButtonPositionReckoner

// superViewBound: 父视图大小；buttonCount:按钮数量；perPageButtonCount:每页按钮的数量
- (NSArray *)getButtonCentersWithSuperViewBound:(CGRect)superViewBound buttonCount:(int)buttonCount perPageButtonCount:(int)perPageButtonCount isHorizontal:(BOOL)isHorizontal
{
    __autoreleasing NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:buttonCount];
    
    if (isHorizontal)
    {
        float preWidth = CGRectGetWidth(superViewBound) / perPageButtonCount;
        
        for (int i = 0; i < buttonCount; i++)
        {
            float centerX = preWidth * i + preWidth / 2;
            NSValue *centerValue = [NSValue valueWithCGPoint:CGPointMake(centerX, CGRectGetHeight(superViewBound) / 2)];
            [array addObject:centerValue];
        }
    }
    else
    {
        float preHeight = CGRectGetHeight(superViewBound) / perPageButtonCount;
        
        for (int i = 0; i < buttonCount; i++)
        {
            float centerY = preHeight * i + preHeight / 2;
            NSValue *centerValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(superViewBound) / 2, centerY)];
            [array addObject:centerValue];
        }
    }
    
    return array;
}

// 获取横屏时工具栏按钮位置，按钮间距固定
- (NSArray *)getFullScreenButtonCentersWithSuperViewBound:(CGRect)superViewBound buttonCount:(int)buttonCount buttonWidth:(int)buttonWidth space:(int)space
{
    int totalButtonWidth = buttonWidth * buttonCount + space * (buttonCount - 1);
    
    if (totalButtonWidth > CGRectGetWidth(superViewBound))
    {// 使用上一种布局方式
        return [self getButtonCentersWithSuperViewBound:superViewBound buttonCount:buttonCount perPageButtonCount:buttonCount isHorizontal:YES];
    }
    
    __autoreleasing NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:buttonCount];
    
    int leftSpace = (CGRectGetWidth(superViewBound) - totalButtonWidth) / 2;
    for (int i = 0; i < buttonCount; i++)
    {
        float centerX = leftSpace + (buttonWidth + space) * i + buttonWidth / 2;
        NSValue *centerValue = [NSValue valueWithCGPoint:CGPointMake(centerX, CGRectGetHeight(superViewBound) / 2)];
        [array addObject:centerValue];
    }
    
    return array;
}

@end
