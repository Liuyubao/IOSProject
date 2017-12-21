//
//  PtzPresetPositionDialView.m
//  iVMS-4500
//
//  Created by gumingjun on 14-10-9.
//  Copyright (c) 2014年 HIKVISION. All rights reserved.
//

#import "PtzPresetPositionDialView.h"

static const int kLabelTag = 2011;

#define NUM_ROWS            500000
#define ROW_HEIGHT          40

#define DIAL_WIDTH                  37
#define DIAL_HEIGHT                 40

@interface PtzPresetPositionDialView()
{
    UITableView *_tableView;
    NSArray *_numArray;
    BOOL _isAnimating;
}

@end

@implementation PtzPresetPositionDialView

- (void)setIsSpinning:(BOOL)isSpinning
{
    _isSpinning = isSpinning;
    [self.delegate ptzPresetPositionDialView:self isSpinningChanged:isSpinning];
}

- (void)dealloc
{
    _tableView.delegate = nil;
}

// 初始化滚轮数字范围，设置初始化位置
- (id)initWithNumArray:(NSArray *)numArray
{
    if ([numArray count] == 0)
    {
        return nil;
    }
    self = [super init];
    if (self)
    {
        self.bounds = CGRectMake(0, 0, DIAL_WIDTH, DIAL_HEIGHT);
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ptz_preset_box.png"]];
        
        _isAnimating = NO;
        _numArray = numArray;
        _selectedString = [[NSString alloc] init];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.frame = self.bounds;
        _tableView.rowHeight = ROW_HEIGHT;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor clearColor];
        [self addSubview:_tableView];
        
        // 初始化默认显示的数字
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(int)(NUM_ROWS * .5) inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        [self snap];
    }
    return self;
}

/*  @fn     - (void)spinToString:(NSString *)string
 *  @brief  转到相应的位置
 *  @param  string 转到的位置
 *  @return nil
 */
- (void)spinToString:(NSString *)string
{
    _isAnimating = NO;
    self.isSpinning = NO;
    if ([[_tableView visibleCells] count] == 0)
    {
        return;
    }
    UITableViewCell *cell = [[_tableView visibleCells] objectAtIndex:0];
    UILabel *lable = (UILabel *)[cell viewWithTag:kLabelTag];
    long difference = [self indexOfString:string] - [self indexOfString:lable.text];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_tableView indexPathForCell:cell].row + difference inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

/*  @fn     - (void)snap
 *  @brief  计算旋转的位置
 *  @param  nil
 *  @return nil
 */
- (void)snap
{
    if (_isAnimating)
    {
        return;
    }
    
    _isAnimating = YES;
    self.isSpinning = NO;
    
    // 对于每个Cell，检查它是否在视图中，将它设置为相应的选择
    for (int i = 0; i < [[_tableView visibleCells] count]; i++)
    {
        UITableViewCell *cell = [[_tableView visibleCells] objectAtIndex:i];
        UILabel *label = (UILabel *)[cell viewWithTag:kLabelTag];
        BOOL selected = CGRectContainsPoint(CGRectMake(0, _tableView.contentOffset.y, _tableView.frame.size.width, _tableView.rowHeight), cell.center);
        if (selected)
        {
            _isAnimating = YES;
            self.isSpinning = NO;
            self.selectedString = label.text;
            [_tableView scrollToRowAtIndexPath:[_tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            
            // 检查结果不是从旋转未结束时获得的，因此在这里调用委托方法
            if ([_tableView rectForRowAtIndexPath:[_tableView indexPathForCell:cell]].origin.y ==
                _tableView.contentOffset.y + (_tableView.frame.size.height - ROW_HEIGHT) * .5)
            {
                [self.delegate ptzPresetPositionDialView:self didSnapToString:self.selectedString];
                _isAnimating = NO;
            }
        }
    }
}

/*  @fn     - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 *  @brief  获取行对象
 *  @param  (UITableView *)tableView    列表视图
 *          (NSIndexPath *)indexPath    索引
 *  @return (UITableViewCell *)         行对象
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    long cellNumber = indexPath.row % [_numArray count];
    
    static NSString *s_DialCellIdentifier = @"DialCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:s_DialCellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:s_DialCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, ROW_HEIGHT)];
        label.font = [UIFont systemFontOfSize:25.0f];
        label.text = [_numArray objectAtIndex:cellNumber];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.tag = kLabelTag;
        [cell addSubview:label];
    }
    else
    {
        // 如果cell已经移除，填充它的相关信息，并设置为未选中
        UILabel *label = (UILabel *)[cell viewWithTag:kLabelTag];
        label.text = [_numArray objectAtIndex:cellNumber];
    }
    return cell;
}

/*  @fn     - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 *  @brief  获取各段的行数
 *  @param  (UITableView *)tableView    列表视图
 *          (NSInteger)section          段
 *  @return (NSInteger)                 行数
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUM_ROWS;
}

#pragma mark UIScrollViewDelegate methods

/*  @fn     - (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
 *  @brief  滚动的时候回调
 *  @param  scrollView    滚动视图对象
 *  @return nil
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isSpinning = YES;
}

/*  @fn     - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
 *  @brief  停止拖拽的时候开始执行 如果需要scrollview在停止滑动后一定要执行某段代码的话应该搭配scrollViewDidEndDragging函数使用
 *  @param  scrollView    滚动视图对象
 *  @param  decelerate    是否正在减速
 *  @return nil
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        self.isSpinning = NO;
        _isAnimating = NO;
        [self snap];
    }
}

/*  @fn     - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
 *  @brief  减速停止的时候开始执行
 *  @param  scrollView    滚动视图对象
 *  @return nil
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isSpinning = NO;
    _isAnimating = NO;
    [self snap];
}

/*  @fn     - (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
 *  @brief  判断动画是否结束
 *  @param  scrollView    滚动视图对象
 *  @return nil
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_isAnimating)
    {
        _isAnimating = NO;
        self.isSpinning = NO;
        // 动画未结束时，也可能调用值
        [self.delegate ptzPresetPositionDialView:self didSnapToString:self.selectedString];
    }
    else
    {
        [self snap];
    }
}

/*  @fn     - (NSInteger)indexOfString:(NSString *)string
 *  @brief  获取字符的位置
 *  @param  string   字符对象
 *  @return 字符的位置
 */
- (NSInteger)indexOfString:(NSString *)string
{
    if (_numArray)
    {
        for (NSInteger i=0; i<[_numArray count]; i++)
        {
            if ([(NSString *)[_numArray objectAtIndex:i] isEqualToString:string])
            {
                return i;
            }
        }
    }
    return -1;
}

@end
