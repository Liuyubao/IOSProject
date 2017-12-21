//
//  ToolBarScrollView.m
//  iVMS-4500
//
//  Created by gumingjun on 14-9-25.
//  Copyright (c) 2014年 HIKVISION. All rights reserved.
//

#import "ToolBarScrollView.h"
#import "ToolBarButton.h"

@implementation ToolBarScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if ([view isMemberOfClass:[ToolBarButton class]])
    {
        return YES;
    }
    return NO;
}

@end
