//
//  ToolBarButton.h
//  iVMS-4500
//
//  Created by gumingjun on 14-9-26.
//  Copyright (c) 2014年 HIKVISION. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToolBarButton : UIButton

@property (nonatomic, assign) BOOL isOrientationPortrait;
@property (nonatomic, assign) BOOL isStateOn;

- (id)initWithPortraitStateOffImage:(NSString *)portraitStateOffImage
           portraitStateOffSelImage:(NSString *)portraitStateOffSelImage
               portraitStateOnImage:(NSString *)portraitStateOnImage
            portraitStateOnSelImage:(NSString *)portraitStateOnSelImage
            horizontalStateOffImage:(NSString *)horizontalStateOffImage
         horizontalStateOffSelImage:(NSString *)horizontalStateOffSelImage
             horizontalStateOnImage:(NSString *)horizontalStateOnImage
          horizontalStateOnSelImage:(NSString *)horizontalStateOnSelImage;

- (void)resetWithPortraitStateOffImage:(NSString *)portraitStateOffImage
          portraitStateOffSelImage:(NSString *)portraitStateOffSelImage
              portraitStateOnImage:(NSString *)portraitStateOnImage
           portraitStateOnSelImage:(NSString *)portraitStateOnSelImage
           horizontalStateOffImage:(NSString *)horizontalStateOffImage
        horizontalStateOffSelImage:(NSString *)horizontalStateOffSelImage
            horizontalStateOnImage:(NSString *)horizontalStateOnImage
             horizontalStateOnSelImage:(NSString *)horizontalStateOnSelImage;

@end
