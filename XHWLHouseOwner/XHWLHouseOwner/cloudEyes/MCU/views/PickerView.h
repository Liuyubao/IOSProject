//
//  PickerView.h
//  AnyVision
//
//  Created by apple on 15-1-15.
//  Copyright (c) 2015年 HikVision. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PickerView ;

@protocol PickerViewDelegate<NSObject>

- (void)pickerView:(PickerView *)picker forDate:(NSDate*)date forPos:(NSString*) pos;

@end



@interface PickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>


@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *posPicker;

@property (strong, nonatomic) NSDate *curDate;
@property (strong, nonatomic) NSDate *preDate;
@property (strong, nonatomic) NSMutableArray  *recordPos;
@property (strong, nonatomic) NSString *curPos;
@property (assign, nonatomic) NSInteger nPrePos;
@property (assign, nonatomic) NSInteger nCurPos;

@property (nonatomic, assign)   id <PickerViewDelegate>   delegate;


- (id)initWithFrame:(CGRect)frame andPos:(NSArray *)recordPos;
- (void)preDateAndPos;
@end
