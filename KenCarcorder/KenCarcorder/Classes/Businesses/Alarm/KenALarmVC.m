//
//  KenALarmVC.m
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenALarmVC.h"
#import "KenUserInfoDM.h"

@interface KenALarmVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) NSUInteger selectTab;
@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) NSMutableArray *tabBtnList;
@property (nonatomic, strong) UITableView *alarmTable;
@property (nonatomic, strong) UIView *groupV;

@end

@implementation KenALarmVC
#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _tabBtnList = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"报警信息"];
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#051A28"];
    
    //右上角按钮
    UIButton *button1 = [UIButton buttonWithImg:nil zoomIn:NO image:[UIImage imageNamed:@"alarm_edit"]
                                       imagesec:nil target:self action:@selector(editBtn)];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
    
    UIButton *button2 = [UIButton buttonWithImg:nil zoomIn:NO image:[UIImage imageNamed:@"alarm_filte"]
                                       imagesec:nil target:self action:@selector(filteBtn)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:button2];
    
    self.navigationItem.rightBarButtonItems = @[item1, item2];
    
    //视图
    [self.contentView addSubview:self.groupV];
    [self.contentView addSubview:self.alarmTable];
    
    self.selectTab = 0;
}

#pragma mark - event
- (void)editBtn {
    
}

- (void)filteBtn {
    
}

- (void)tabClicked:(UIButton *)button {
    if (_selectTab == button.tag - 1000 || _isEditing) return;
    
    self.selectTab = button.tag - 1000;
    
    [self loadAlarmData];
}

#pragma mark - Table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bankCellIdentifier = @"mineCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bankCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bankCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - private method
- (void)loadAlarmData {
    
}

#pragma mark - getter setter
- (void)setSelectTab:(NSUInteger)selectTab {
    _selectTab = selectTab;
    
    for (UIButton *button in _tabBtnList){
        if (button.tag - 1000 == _selectTab) {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            [button setTitleColor:[UIColor colorWithHexString:@"#94C6E8"] forState:UIControlStateNormal];
        }
    }
}

- (UIView *)groupV {
    if (_groupV == nil) {
        _groupV = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.contentView.width, kKenOffsetY(78)}];
        _groupV.backgroundColor = [UIColor colorWithHexString:@"#084AAB"];

        NSArray *group = [KenUserInfoDM getInstance].deviceGroups;
        float width = self.view.width / [group count];
        for (NSInteger i = 0; i < [group count]; i++) {
            NSString *name = [group objectAtIndex:i];
            UIButton *button = [UIButton buttonWithImg:name zoomIn:NO image:nil imagesec:nil
                                                target:self action:@selector(tabClicked:)];
            button.tag = 1000 + i;
            button.frame = (CGRect){width * i, 0, width, _groupV.height};
            [button setTitleColor:[UIColor colorWithHexString:@"#94C6E8"] forState:UIControlStateNormal];
            
            [_groupV addSubview:button];
            
            [_tabBtnList addObject:button];
        }
    }
    return _groupV;
}

- (UITableView *)alarmTable {
    if (_alarmTable == nil) {
        _alarmTable = [[UITableView alloc] initWithFrame:(CGRect){0, self.groupV.maxY, self.contentView.width,
                                                                self.contentView.height - self.groupV.height}
                                                   style:UITableViewStylePlain];
        _alarmTable.delegate = self;
        _alarmTable.dataSource = self;
        _alarmTable.rowHeight = kKenOffsetY(216);
        _alarmTable.backgroundColor = [UIColor clearColor];
        _alarmTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _alarmTable;
}
@end
