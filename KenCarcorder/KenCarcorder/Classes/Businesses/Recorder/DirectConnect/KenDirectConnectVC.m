//
//  KenDirectConnectVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/3/4.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenDirectConnectVC.h"
#import "KenAlertView.h"

@interface KenDirectConnectVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *recordTable;
@property (nonatomic, strong) NSArray *recordList;

@end

@implementation KenDirectConnectVC
#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        self.screenType = kKenViewScreenFull;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"直连行车记录仪"];
    
    UIImageView *bgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorder_bg"]];
    bgV.size = self.contentView.size;
    [self.contentView addSubview:bgV];
    
    [self searchRecorders];
}

#pragma mark - Table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _recordList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bankCellIdentifier = @"mineCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bankCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bankCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
        
        cell.accessoryView = [self tableAccessoryV];
    }
    
    [cell.textLabel setText:_recordList[indexPath.row]];
    cell.textLabel.textColor = [UIColor appWhiteTextColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [KenAlertView showAlertViewWithTitle:@"" contentView:nil message:@"连接之前需要先设置手机WIFI为行车记录仪网络" buttonTitles:@[@"取消", @"确定"]
                      buttonClickedBlock:^(KenAlertView * _Nonnull alertView, NSInteger index) {
        if (index == 1) {
            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }];
}

#pragma mark - private method
- (void)searchRecorders {
    if (0) {
        [self initNoRecorder];
    } else {
        [self initRecorderList];
    }
}

- (void)initNoRecorder {
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dc_no_recorder"]];
    logo.centerX = self.contentView.centerX;
    logo.originY = kKenOffsetY(300);
    [self.contentView addSubview:logo];
    
    UILabel *label = [UILabel labelWithTxt:@"附近没有找到（七彩云）行车记录仪，请确认行车记录仪已经打开，并且蓝灯正在闪烁"
                                     frame:(CGRect){20, logo.maxY + kKenOffsetY(100), self.contentView.width - 40, 100}
                                      font:[UIFont appFontSize16] color:[UIColor appWhiteTextColor]];
    label.numberOfLines = 0;
    [self.contentView addSubview:label];
    
    //
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:label.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:kKenOffsetY(40)];//调整行间距
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, label.text.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#73B6FA"]
                             range:NSMakeRange(label.text.length - 6, 6)];
    label.attributedText = attributedString;
}

- (void)initRecorderList {
    _recordTable = [[UITableView alloc] initWithFrame:(CGRect){0, 64, self.contentView.width, self.contentView.height - 64}
                                                style:UITableViewStylePlain];
    _recordTable.delegate = self;
    _recordTable.dataSource = self;
    _recordTable.backgroundColor = [UIColor clearColor];
    _recordTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _recordTable.tableFooterView = [self tableFootV];
    [self.contentView addSubview:_recordTable];
    
    _recordList = @[@"行车记录仪- 1", @"行车记录仪- 2", @"行车记录仪- 3"];
    
    [_recordTable reloadData];
}

- (UIView *)tableFootV {
    UILabel *label = [UILabel labelWithTxt:@"说明：请选择其中一个七彩云行车记录仪进行连接，该连接不会产生任何流量费用。"
                                     frame:(CGRect){15, 0, self.contentView.width - 30, 80}
                                      font:[UIFont appFontSize15] color:[UIColor appWhiteTextColor]];
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    return label;
}

- (UIView *)tableAccessoryV {
    UIView *accessoryV = [[UIView alloc] initWithFrame:(CGRect){0,0, 50, 44}];
    accessoryV.backgroundColor = [UIColor clearColor];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dc_online"]];
    logo.center = CGPointMake(logo.width, accessoryV.height / 2);
    [accessoryV addSubview:logo];
    
    UILabel *label = [UILabel labelWithTxt:@" 在线 " frame:(CGRect){logo.maxX, 0, 80, 44}
                                      font:[UIFont appFontSize15] color:[UIColor appWhiteTextColor]];
    label.textAlignment = NSTextAlignmentLeft;
    [accessoryV addSubview:label];
    
    return accessoryV;
}

@end
