//
//  TalkChannelView.m
//  iVMS-8700-MCU
//
//  Created by apple on 16/6/24.
//  Copyright © 2016年 HikVision. All rights reserved.
//

#import "TalkChannelView.h"
#import "Masonry.h"
//本地化
#define MyLocal(x) NSLocalizedString(x,nil)
//16进制颜色转换成rgb
#define UICOLORTORGB(rgbValue) [UIColor colorWithRed:((float)((strtol([rgbValue UTF8String], 0, 16) & 0xFF0000) >> 16))/255.0 green:((float)((strtol([rgbValue UTF8String], 0, 16) & 0xFF00) >> 8))/255.0 blue:((float)(strtol([rgbValue UTF8String], 0, 16) & 0xFF))/255.0 alpha:1.0]
#define CELL_DEFAULT_HEIGHT 44.0f//默认cell的高度
#define MINHEIGHT 0.0001f//tableview的header和footer高度设为0


const static NSInteger channelViewWith = 250;/**< view的宽*/
const static NSInteger channelViewHeight = 280;/**< view的高*/
const static NSInteger titleLabelHeight = 40;/**< 标题label的高度*/
const static NSInteger confirmButtonHeight = 30;/**< 确定取消按钮的高度*/
const static NSInteger confirmButtonwith = 100;/**< 确定取消按钮的宽度*/

@implementation TalkChannelView {
    UIView      *g_backGroundView;/**< 底部view*/
    UILabel     *g_titleLabel;/**< 显示标题*/
    UITableView *g_tableView;/**< 对讲通道列表*/
    NSInteger   selectedIndex;/**< 选择的通道下标*/
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.8f]];
        selectedIndex = -1;
        g_backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, channelViewWith, channelViewHeight)];
        [g_backGroundView setBackgroundColor:[UIColor colorWithWhite:0.961 alpha:1.000]];
        g_backGroundView.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2);
        [self addSubview:g_backGroundView];
        
        g_titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, channelViewWith, titleLabelHeight)];
        [g_titleLabel setBackgroundColor:UICOLORTORGB(@"0xCA2C32")];
        [g_titleLabel setTextColor:[UIColor whiteColor]];
        [g_titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [g_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [g_titleLabel setText:MyLocal(@"请选择对讲通道")];
        [g_backGroundView addSubview:g_titleLabel];
        
        g_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, titleLabelHeight, channelViewWith, channelViewHeight - titleLabelHeight - confirmButtonHeight - 10) style:UITableViewStyleGrouped];
        [g_tableView setBackgroundColor:[UIColor whiteColor]];
        g_tableView.delegate = self;
        g_tableView.dataSource = self;
        [g_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        [g_backGroundView addSubview:g_tableView];
        
        UIButton *confirmButton = [[UIButton alloc]initWithFrame:CGRectZero];
        [confirmButton setBackgroundColor:[UIColor grayColor]];
        [confirmButton setTitle:MyLocal(@"OK") forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmChoose) forControlEvents:UIControlEventTouchUpInside];
        [confirmButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [g_backGroundView addSubview:confirmButton];
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(g_backGroundView).with.offset(-5);
            make.centerX.mas_equalTo(CGRectGetWidth(g_backGroundView.frame) / 4);
            make.size.mas_equalTo(CGSizeMake(confirmButtonwith, confirmButtonHeight));
        }];
        
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, confirmButtonwith, confirmButtonHeight)];
        [cancelButton setBackgroundColor:[UIColor grayColor]];
        [cancelButton setTitle:MyLocal(@"取消") forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelChoose) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [g_backGroundView addSubview:cancelButton];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(g_backGroundView).with.offset(-5);
            make.centerX.mas_equalTo(-CGRectGetWidth(g_backGroundView.frame) / 4);
            make.size.mas_equalTo(CGSizeMake(confirmButtonwith, confirmButtonHeight));
        }];
        
        CGAffineTransform transform = CGAffineTransformMakeScale(0, 0);
        g_backGroundView.transform = transform;
        transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        [UIView animateWithDuration:0.2 animations:^{
            g_backGroundView.transform = transform;
        }];
    }
    return  self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    g_backGroundView.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _simulateCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (selectedIndex == indexPath.row) {
        [cell.imageView setImage:[UIImage imageNamed:@"visitor_identity_choose"]];
    }
    else {
        [cell.imageView setImage:[UIImage imageNamed:@"visitor_identity_unchoose"]];
    }
    [cell.textLabel setFont:[UIFont systemFontOfSize:15.0]];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@%@",MyLocal(@"对讲通道"),@(indexPath.row + 1)]];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_DEFAULT_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return MINHEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return MINHEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.imageView setImage:[UIImage imageNamed:@"visitor_identity_choose"]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex = -1;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.imageView setImage:[UIImage imageNamed:@"visitor_identity_unchoose"]];
}

#pragma mark - event response
/**
 *  确定按钮点击
 */
- (void)confirmChoose {
    NSInteger talkChannel = 0;
    NSIndexPath *indexPath = [g_tableView indexPathForSelectedRow];
    if (!indexPath) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请选择对讲通道" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    [self removeFromSuperview];
    //对讲通道分为模拟通道和数字通道.模拟通道号请直接按照模拟通道总个数,直接传入从1到通道总个数的任一数字.即为模拟通道号
    //数字通道号,请按照数字通道总个数,直接传入从1到通道总个数的任一数字的值再加上500,即为数字通道号
    //现在的SDK只支持模拟通道，数字通道无意义
    //模拟通道号的个数,请在视频正常预览之后在预览管理类RealPlayManager中,根据deviceInfo属性获取.
    talkChannel = indexPath.row + 1;
    [self.delegate talkChannelChoose:talkChannel];
}

/**
 *  取消按钮点击
 */
- (void)cancelChoose {
    [UIView animateWithDuration:0.2 animations:^{
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformMakeRotation(M_PI / 18);
        g_backGroundView.transform = transform;
    } completion:^(BOOL finish) {
        
    }];
    [UIView animateWithDuration:0.4 animations:^{
        g_backGroundView.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) * 3 / 2);
    } completion:^(BOOL finish) {
        [self removeFromSuperview];
    }];
    [self.delegate cancelTalkChannel];
}

@end
