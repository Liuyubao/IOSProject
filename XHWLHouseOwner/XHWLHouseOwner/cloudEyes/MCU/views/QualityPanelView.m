//
//  QualityPanelView.m
//  iVMS-8700-MCU
//
//  Created by apple on 15-3-19.
//  Copyright (c) 2015年 HikVision. All rights reserved.
//

#import "QualityPanelView.h"
#import "ToolBarButtonPositionReckoner.h"

#define UICOLORTORGB(rgbValue) [UIColor colorWithRed:((float)((strtol([rgbValue UTF8String], 0, 16) & 0xFF0000) >> 16))/255.0 green:((float)((strtol([rgbValue UTF8String], 0, 16) & 0xFF00) >> 8))/255.0 blue:((float)(strtol([rgbValue UTF8String], 0, 16) & 0xFF))/255.0 alpha:1.0]

static int PORTRAIT_BUTTON_SIZE_WIDTH = 64;
static int PORTRAIT_BUTTON_SIZE_HEIGHT = 49;

static int FULLSCREEN_BUTTON_SIZE_WIDTH = 44;
static int FULLSCREEN_BUTTON_SIZE_HEIGHT = 44;

@implementation QualityPanelView{
    UIButton *_fluencyButton;//流畅按钮
    UIButton *_clearButton;//标清按钮
    UIButton *_highDefinitionButton;//高清按钮
    
    UIView *_separateLine1;//分割线
    UIView *_separateLine2;
    
    NSArray *buttonArray;//存放按钮的数组
    NSInteger selectedIndex;//  当前选中的按钮
    BOOL isInterfaceOrientation;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _fluencyButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, PORTRAIT_BUTTON_SIZE_WIDTH, PORTRAIT_BUTTON_SIZE_HEIGHT)];
        [_fluencyButton setTitle:@"流畅" forState:UIControlStateNormal];
        _fluencyButton.tag = 2;
        [_fluencyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_fluencyButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [_fluencyButton addTarget:self action:@selector(fluencyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_fluencyButton];
        
        _clearButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, PORTRAIT_BUTTON_SIZE_WIDTH, PORTRAIT_BUTTON_SIZE_HEIGHT)];
        [_clearButton setTitle:@"标清" forState:UIControlStateNormal];
        _clearButton.tag = 1;
        [_clearButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [_clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(clearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_clearButton];
        
        _highDefinitionButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, PORTRAIT_BUTTON_SIZE_WIDTH, PORTRAIT_BUTTON_SIZE_HEIGHT)];
        [_highDefinitionButton setTitle:@"高清" forState:UIControlStateNormal];
        _highDefinitionButton.tag = 0;
        [_highDefinitionButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [_highDefinitionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_highDefinitionButton addTarget:self action:@selector(highDefinitionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_highDefinitionButton];
        
        _separateLine1 = [[UIView alloc] init];
        _separateLine1.bounds = CGRectMake(0, 0, 1, 51);
        _separateLine1.backgroundColor = UICOLORTORGB(@"0xE6E6E6");
        [self addSubview:_separateLine1];
        
        _separateLine2 = [[UIView alloc] init];
        _separateLine2.bounds = _separateLine1.bounds;
        _separateLine2.backgroundColor = UICOLORTORGB(@"0xE6E6E6");
        [self addSubview:_separateLine2];
        
        buttonArray = @[_fluencyButton,_clearButton,_highDefinitionButton];
        
        [self setFirstSelectedButton];
    }
    return self;
}

-(void)setFirstSelectedButton{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    selectedIndex = [defaults integerForKey:@"videoQuality"] - 1;
//    UIButton *selectedButton = (UIButton *)[buttonArray objectAtIndex:index];
//    [selectedButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
}

-(void)fluencyButtonClick:(UIButton *)btn{
    [self setSelectButton:btn];
    [self.delegate qualityChange:STREAM_MAG];
}

-(void)clearButtonClick:(UIButton *)btn{
    [self setSelectButton:btn];
    [self.delegate qualityChange:STREAM_SUB];
}

-(void)highDefinitionButtonClick:(UIButton *)btn{
    [self setSelectButton:btn];
    [self.delegate qualityChange:STREAM_MAIN];
}

-(void)setSelectButton:(UIButton *)btn{
    for (int i = 0; i<buttonArray.count; i++) {
        if (btn.tag == ((UIButton *)buttonArray[i]).tag) {
            selectedIndex = ((UIButton *)buttonArray[i]).tag;
            [((UIButton *)buttonArray[i])setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }else{
            [((UIButton *)buttonArray[i])setTitleColor:isInterfaceOrientation?[UIColor blackColor]:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

- (void)selectButton:(NSInteger)index {
    for (UIButton *btn in buttonArray) {
        if (btn.tag == index) {
            selectedIndex = index;
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        } else {
            [btn setTitleColor:isInterfaceOrientation?[UIColor blackColor]:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

-(void)layoutSubviews{
    isInterfaceOrientation = ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait);
    NSArray *buttonCenterArray = [[ToolBarButtonPositionReckoner sharedInstance] getButtonCentersWithSuperViewBound:self.bounds buttonCount:3 perPageButtonCount:3 isHorizontal:isInterfaceOrientation];
    
    
    _separateLine1.center = CGPointMake(([[buttonCenterArray objectAtIndex:0] CGPointValue].x + [[buttonCenterArray objectAtIndex:1] CGPointValue].x) / 2, CGRectGetHeight(self.bounds) / 2);
    _separateLine2.center = CGPointMake(([[buttonCenterArray objectAtIndex:1] CGPointValue].x + [[buttonCenterArray objectAtIndex:2] CGPointValue].x) / 2, CGRectGetHeight(self.bounds) / 2);
    if (isInterfaceOrientation) {
        
        
        _fluencyButton.center = [[buttonCenterArray objectAtIndex:0] CGPointValue];
        _clearButton.center = [[buttonCenterArray objectAtIndex:1] CGPointValue];
        _highDefinitionButton.center = [[buttonCenterArray objectAtIndex:2] CGPointValue];
        _separateLine1.hidden = NO;
        _separateLine2.hidden = NO;
        [_fluencyButton setTitleColor:selectedIndex == 2?[UIColor redColor]:[UIColor blackColor] forState:UIControlStateNormal];
        [_clearButton setTitleColor:selectedIndex == 1?[UIColor redColor]:[UIColor blackColor] forState:UIControlStateNormal];
        [_highDefinitionButton setTitleColor:selectedIndex == 0?[UIColor redColor]:[UIColor blackColor] forState:UIControlStateNormal];
        
    }else{
        _fluencyButton.frame= CGRectMake(0, 20, FULLSCREEN_BUTTON_SIZE_WIDTH, FULLSCREEN_BUTTON_SIZE_HEIGHT);
        _clearButton.frame= CGRectMake(0, 30+FULLSCREEN_BUTTON_SIZE_HEIGHT, FULLSCREEN_BUTTON_SIZE_WIDTH, FULLSCREEN_BUTTON_SIZE_HEIGHT);
        _highDefinitionButton.frame= CGRectMake(0, 40+FULLSCREEN_BUTTON_SIZE_WIDTH*2, FULLSCREEN_BUTTON_SIZE_WIDTH, FULLSCREEN_BUTTON_SIZE_HEIGHT);
        _separateLine1.hidden = YES;
        _separateLine2.hidden = YES;
        [_fluencyButton setTitleColor:selectedIndex == 2?[UIColor redColor]:[UIColor whiteColor] forState:UIControlStateNormal];
        [_clearButton setTitleColor:selectedIndex == 1?[UIColor redColor]:[UIColor whiteColor] forState:UIControlStateNormal];
        [_highDefinitionButton setTitleColor:selectedIndex == 0?[UIColor redColor]:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
