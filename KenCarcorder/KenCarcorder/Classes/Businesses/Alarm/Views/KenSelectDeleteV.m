//
//  KenSelectDeleteV.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenSelectDeleteV.h"
#import "KenAlertView.h"

@interface KenSelectDeleteV ()<UITableViewDataSource, UITableViewDelegate>

@property (assign) NSInteger selectedIndex;
@property (nonatomic, strong) UITableView *selectTable;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation KenSelectDeleteV

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5]];
        
        _selectedIndex = -1;
        
        [self initView:frame];
    }
    return self;
}

- (void)initView:(CGRect)frame {
    _dataArray = @[@"所有", @"一天前", @"两天前", @"三天前"];
    
    CGRect rect = CGRectMake(0, 0, MainScreenWidth, 44 * [_dataArray count]);
    _selectTable = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _selectTable.delegate = self;
    _selectTable.dataSource = self;
    [_selectTable setScrollEnabled:NO];
    _selectTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self addSubview:_selectTable];
    
    //
    UIView *deleteView = [[UIView alloc] initWithFrame:(CGRect){0, frame.size.height - 90, MainScreenWidth, 90}];
    deleteView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:deleteView];
    
    UIButton *delete = [UIButton buttonWithImg:@"删除" zoomIn:NO image:nil imagesec:nil target:self action:@selector(deleteConfirm)];
    delete.frame = (CGRect){0, 0, deleteView.width, 40};
    [delete.titleLabel setFont:[UIFont appFontSize16]];
    [delete setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [delete setBackgroundColor:[UIColor whiteColor]];
    [deleteView addSubview:delete];
    
    UIButton *cancel = [UIButton buttonWithImg:@"取消" zoomIn:NO image:nil imagesec:nil target:self action:@selector(cancelBtn)];
    cancel.frame = (CGRect){0, deleteView.height - 40, deleteView.width, 40};
    [cancel.titleLabel setFont:[UIFont appFontSize16]];
    [cancel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cancel setBackgroundColor:[UIColor whiteColor]];
    [deleteView addSubview:cancel];
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bankCellIdentifier = @"videoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bankCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bankCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    
    [cell.textLabel setText:[_dataArray objectAtIndex:indexPath.row]];
    cell.accessoryView = [[UIImageView alloc] initWithImage:
                          [UIImage imageNamed:indexPath.row == _selectedIndex ? @"alarm_select_green" : @"alarm_select_none"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedIndex = indexPath.row;
    [tableView reloadData];
}

#pragma mark - button
- (void)deleteConfirm {
    if (_selectedIndex < 0) return;
    
    [KenAlertView showAlertViewWithTitle:nil contentView:nil message:@"将永久删除这些信息，是否继续？" buttonTitles:@[@"取消", @"确定"]
                      buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
                          if (index == 1 && _selectedIndex >= 0) {
                              //all:所有; onedaybefore:一天前; twodaybefore:两天前; threedaybefore:三天前
                              NSString *type = @"";
                              switch (_selectedIndex) {
                                  case 0:
                                      type = @"all";
                                      break;
                                  case 1:
                                      type = @"onedaybefore";
                                      break;
                                  case 2:
                                      type = @"twodaybefore";
                                      break;
                                  case 3:
                                      type = @"threedaybefore";
                                      break;
                                  default:
                                      break;
                              }
                              
                              @weakify(self)
                              [[KenServiceManager sharedServiceManager] alarmDeleteWithType:type success:^{
                                  
                              } successBlock:^(BOOL successful, NSString * _Nullable errMsg, id  _Nullable responseData) {
                                  @strongify(self)
                                  [self cancelBtn];
                                  
                                  [[KenServiceManager sharedServiceManager] getAarmStat];
                              } failedBlock:^(NSInteger status, NSString * _Nullable errMsg) {
                                  
                              }];
                          }
                      }];
}

- (void)cancelBtn {
    [self removeFromSuperview];
}

@end
