//
//  KenRecorderVC.m
//  KenCarcorder
//
//  Created by hzyouda on 2017/2/18.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenRecorderVC.h"
#import "Masonry.h"

@interface KenRecorderVC ()

@end

@implementation KenRecorderVC
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
    [self setNavTitle:@"记录仪"];
    
    [self pushViewControllerString:@"KenLoginVC" animated:NO];
    
    [self initView];
}

#pragma mark - private mthod
- (void)initView {
    UIImageView *bgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_recorder_bg"]];
    bgV.size = self.contentView.size;
    [self.contentView addSubview:bgV];
    
    //远程连接
    UIImageView *item1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_recorder_item1"]];
    [self.contentView addSubview:item1];
    
    UILabel *label1 = [UILabel labelWithTxt:@"远程连接行车记录仪" frame:(CGRect){0,0,item1.size}
                                       font:[UIFont appFontSize17] color:[UIColor colorWithHexString:@"#F77278"]];
    [item1 addSubview:label1];
    
    [item1 clicked:^(UIView * _Nonnull view) {
        [self pushViewControllerString:@"KenSelectVC" animated:YES];
    }];
    
    //直接连接
    UIImageView *item2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_recorder_item1"]];
    [self.contentView addSubview:item2];
    
    UILabel *label2 = [UILabel labelWithTxt:@"直接连接行车记录仪" frame:(CGRect){0,0,item2.size}
                                       font:[UIFont appFontSize17] color:[UIColor colorWithHexString:@"#22C486"]];
    [item2 addSubview:label2];
    
    [item2 clicked:^(UIView * _Nonnull view) {
        [self pushViewControllerString:@"KenDirectConnectVC" animated:YES];
    }];
    
    //autolayout
    [item1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(164);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];

    [item2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(item1.mas_bottom).offset(28);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
}

@end
