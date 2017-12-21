//
//  ToolBarButtonPositionReckoner.h
//  iVMS-4500
//
//  Created by gumingjun on 14-9-17.
//  Copyright (c) 2014年 HIKVISION. All rights reserved.
//

#import "Singleton.h"
#import "UIKit/UIKit.h"

@interface ToolBarButtonPositionReckoner : Singleton

- (NSArray *)getButtonCentersWithSuperViewBound:(CGRect)superViewBound buttonCount:(int)buttonCount perPageButtonCount:(int)perPageButtonCount isHorizontal:(BOOL)isHorizontal;
- (NSArray *)getFullScreenButtonCentersWithSuperViewBound:(CGRect)superViewBound buttonCount:(int)buttonCount buttonWidth:(int)buttonWidth space:(int)space;

@end
