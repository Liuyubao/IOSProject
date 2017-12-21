//
//  PickerView.m
//  AnyVision
//
//  Created by apple on 15-1-15.
//  Copyright (c) 2015年 HikVision. All rights reserved.
//

#import "PickerView.h"

#define PVToobarHeight 40

@implementation PickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        _toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, PVToobarHeight)];
        
        UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        
        UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, PVToobarHeight)];
        [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
        [leftBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [leftBtn setTitleColor:[UIColor colorWithRed:10.0/255 green:150.0/255 blue:255.0/255 alpha:1.0f] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *lefttem=[[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        
        UIButton* dateSpaceCustomView = [UIButton buttonWithType:UIButtonTypeCustom];
        dateSpaceCustomView.backgroundColor = [UIColor darkGrayColor];
        dateSpaceCustomView.layer.cornerRadius = 5;
        dateSpaceCustomView.layer.masksToBounds = YES;
        [dateSpaceCustomView setTitle:@"回放日期" forState:UIControlStateNormal];
        [dateSpaceCustomView setFrame:CGRectMake(0, 0, 100, 30)];
        [dateSpaceCustomView addTarget:self action:@selector(datePickerButton:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *dateSpace=[[UIBarButtonItem alloc] initWithCustomView:dateSpaceCustomView];

        
        UIButton* posSpaceCustomView = [UIButton buttonWithType:UIButtonTypeCustom];
        posSpaceCustomView.backgroundColor = [UIColor darkGrayColor];
        posSpaceCustomView.layer.cornerRadius = 5;
        posSpaceCustomView.layer.masksToBounds = YES;
        [posSpaceCustomView setTitle:@"存储介质" forState:UIControlStateNormal];
        [posSpaceCustomView setFrame:CGRectMake(0, 0, 100, 30)];
        [posSpaceCustomView addTarget:self action:@selector(posPickerButton:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *posSpace=[[UIBarButtonItem alloc] initWithCustomView:posSpaceCustomView];
   
        UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, PVToobarHeight)];
        [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
        [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [rightBtn setTitleColor:[UIColor colorWithRed:10.0/255 green:150.0/255 blue:255.0/255 alpha:1.0f] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *right=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        _toolbar.items=@[lefttem,centerSpace,dateSpace,posSpace,centerSpace,right];
        [self addSubview:_toolbar];
 
        
        _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, PVToobarHeight, frame.size.width, frame.size.height - PVToobarHeight)];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.hidden = NO;
        [self addSubview:_datePicker];
        
        _posPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, PVToobarHeight, frame.size.width, frame.size.height - PVToobarHeight)];
        _posPicker.dataSource = self;
        _posPicker.delegate = self;
        _posPicker.backgroundColor = [UIColor whiteColor];
        _posPicker.hidden = YES;
        [self addSubview:_posPicker];
        
    }
    return self;
}

- (void)preDateAndPos
{
    _preDate = _datePicker.date;
    _curDate = _datePicker.date;
    
    _nPrePos = [_posPicker selectedRowInComponent:0];
    _nCurPos = [_posPicker selectedRowInComponent:0];
}

- (id)initWithFrame:(CGRect)frame andPos:(NSArray *)recordPos
{
    self = [self initWithFrame:frame];
    if (self)
    {
        _curDate = [NSDate date];
        _recordPos = [recordPos mutableCopy];
    }
    return self;
}

#pragma mark - dateChanged

- (void)cancelButton:(id)sender
{
    [_datePicker setDate:_preDate animated:NO];
    [_posPicker selectRow:_nPrePos inComponent:0 animated:NO];
    self.hidden = YES;
}

- (void)datePickerButton:(id)sender
{
    _datePicker.hidden = NO;
    _posPicker.hidden = YES;
    
}

- (void)posPickerButton:(id)sender
{
    _datePicker.hidden = YES;
    _posPicker.hidden = NO;
    
}

- (void)doneButton:(id)sender
{
    self.hidden = YES;
 
    [_delegate pickerView:self forDate:_curDate forPos:_curPos];
}

#pragma mark - dateChanged
- (void)dateChanged:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    _curDate = datePicker.date;
}

#pragma mark piackView 数据源方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
   
    return _recordPos.count;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

#pragma mark UIPickerViewdelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{

    if ([@"1" isEqual:[_recordPos objectAtIndex:row]])
    {
        return @"设备存储";
    }
    if ([@"2" isEqual:[_recordPos objectAtIndex:row]])
    {
        return @"PCNVR存储";
    }
    if ([@"3" isEqual:[_recordPos objectAtIndex:row]])
    {
        return @"CVR存储";
    }
    if ([@"4" isEqual:[_recordPos objectAtIndex:row]])
    {
        return @"CVM存储";
    }
    else
    {
        return nil;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _curPos = [_recordPos objectAtIndex:row];
}

@end
