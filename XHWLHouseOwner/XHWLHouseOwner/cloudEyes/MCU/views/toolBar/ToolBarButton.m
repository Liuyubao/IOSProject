//
//  ToolBarButton.m
//  iVMS-4500
//
//  Created by gumingjun on 14-9-26.
//  Copyright (c) 2014年 HIKVISION. All rights reserved.
//

#import "ToolBarButton.h"

@interface ToolBarButton()
{
    NSString *_portraitStateOffImage;
    NSString *_portraitStateOffSelImage;
    NSString *_portraitStateOnImage;
    NSString *_portraitStateOnSelImage;
    
    NSString *_horizontalStateOffImage;
    NSString *_horizontalStateOffSelImage;
    NSString *_horizontalStateOnImage;
    NSString *_horizontalStateOnSelImage;
}

@end

@implementation ToolBarButton

- (void)setIsOrientationPortrait:(BOOL)isOrientationPortrait
{
    _isOrientationPortrait = isOrientationPortrait;
    
    if (isOrientationPortrait)
    {
        [self setImage:(_isStateOn ? [UIImage imageNamed:_portraitStateOnImage] : [UIImage imageNamed:_portraitStateOffImage]) forState:UIControlStateNormal];
        [self setImage:(_isStateOn ? [UIImage imageNamed:_portraitStateOnSelImage] : [UIImage imageNamed:_portraitStateOffSelImage]) forState:UIControlStateHighlighted];
    }
    else
    {
        [self setImage:(_isStateOn ? [UIImage imageNamed:_horizontalStateOnImage] : [UIImage imageNamed:_horizontalStateOffImage]) forState:UIControlStateNormal];
        [self setImage:(_isStateOn ? [UIImage imageNamed:_horizontalStateOnSelImage] : [UIImage imageNamed:_horizontalStateOffSelImage]) forState:UIControlStateHighlighted];
    }
}

- (void)setIsStateOn:(BOOL)isStateOn
{
    BOOL isOrientationPortrait = ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait);
    _isStateOn = isStateOn;
    if (isStateOn)
    {
        [self setImage:(isOrientationPortrait ? [UIImage imageNamed:_portraitStateOnImage] : [UIImage imageNamed:_horizontalStateOnImage]) forState:UIControlStateNormal];
        [self setImage:(isOrientationPortrait ? [UIImage imageNamed:_portraitStateOnSelImage] : [UIImage imageNamed:_horizontalStateOnSelImage]) forState:UIControlStateHighlighted];
    }
    else
    {
        [self setImage:(isOrientationPortrait ? [UIImage imageNamed:_portraitStateOffImage] : [UIImage imageNamed:_horizontalStateOffImage]) forState:UIControlStateNormal];
        [self setImage:(isOrientationPortrait ? [UIImage imageNamed:_portraitStateOffSelImage] : [UIImage imageNamed:_horizontalStateOffSelImage]) forState:UIControlStateHighlighted];
    }
}

- (id)initWithPortraitStateOffImage:(NSString *)portraitStateOffImage
           portraitStateOffSelImage:(NSString *)portraitStateOffSelImage
               portraitStateOnImage:(NSString *)portraitStateOnImage
            portraitStateOnSelImage:(NSString *)portraitStateOnSelImage
            horizontalStateOffImage:(NSString *)horizontalStateOffImage
         horizontalStateOffSelImage:(NSString *)horizontalStateOffSelImage
             horizontalStateOnImage:(NSString *)horizontalStateOnImage
          horizontalStateOnSelImage:(NSString *)horizontalStateOnSelImage
{
    self = [super init];
    if (self)
    {
        _portraitStateOffImage = portraitStateOffImage;
        _portraitStateOffSelImage = portraitStateOffSelImage;
        _portraitStateOnImage = portraitStateOnImage;
        _portraitStateOnSelImage = portraitStateOnSelImage;
        
        _horizontalStateOffImage = horizontalStateOffImage;
        _horizontalStateOffSelImage = horizontalStateOffSelImage;
        _horizontalStateOnImage = horizontalStateOnImage;
        _horizontalStateOnSelImage = horizontalStateOnSelImage;
        
        [self setImage:[UIImage imageNamed:_portraitStateOffImage] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:_portraitStateOffSelImage] forState:UIControlStateHighlighted];
    }
    return self;
}

- (void)resetWithPortraitStateOffImage:(NSString *)portraitStateOffImage
              portraitStateOffSelImage:(NSString *)portraitStateOffSelImage
                  portraitStateOnImage:(NSString *)portraitStateOnImage
               portraitStateOnSelImage:(NSString *)portraitStateOnSelImage
               horizontalStateOffImage:(NSString *)horizontalStateOffImage
            horizontalStateOffSelImage:(NSString *)horizontalStateOffSelImage
                horizontalStateOnImage:(NSString *)horizontalStateOnImage
             horizontalStateOnSelImage:(NSString *)horizontalStateOnSelImage
{
    _portraitStateOffImage = portraitStateOffImage;
    _portraitStateOffSelImage = portraitStateOffSelImage;
    _portraitStateOnImage = portraitStateOnImage;
    _portraitStateOnSelImage = portraitStateOnSelImage;
    
    _horizontalStateOffImage = horizontalStateOffImage;
    _horizontalStateOffSelImage = horizontalStateOffSelImage;
    _horizontalStateOnImage = horizontalStateOnImage;
    _horizontalStateOnSelImage = horizontalStateOnSelImage;
    
    if (self.isOrientationPortrait)
    {
        [self setImage:[UIImage imageNamed:_portraitStateOffImage] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:_portraitStateOffSelImage] forState:UIControlStateHighlighted];
    }
    else
    {
        [self setImage:[UIImage imageNamed:_horizontalStateOffImage] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:_horizontalStateOffSelImage] forState:UIControlStateHighlighted];
    }
}

@end
