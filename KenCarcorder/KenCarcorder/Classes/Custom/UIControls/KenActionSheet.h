//
//  KenActionSheet.h
//
//
//  Created by Ken.Liu on 2016/12/1.
//  Copyright © 2016年 Ken.Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KenActionSheet;

/**
 *  actionSheet的点击回调
 *
 *  @param actionSheetV 自定义的actionSheet
 *  @param index 点击按钮的索引 （index从上往下由0递增，注意：取消按钮的索引为-1）
 */
typedef void(^ActionSheetDidSelectSheetBlock)(KenActionSheet *actionSheetV, NSInteger index);

@interface KenActionSheet : UIView
/**
 *  展示自定义actionSheet，如果按钮个数大于5个，用列表来展示按钮

 *  @param title                                第一行标题(可为空，即无标题)
 *  @param cancelButtonTitle                    取消按钮选项(可为空，为空时默认为“取消”)
 *  @param otherButtonTitles                    其它选项(传数组)
 *  @param selectSheetBlock                     选项点击回调
 */
+ (void)showActionSheetViewWithTitle:(nullable NSString *)title
                   cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                   otherButtonTitles:(nullable NSArray<__kindof NSString *> *)otherButtonTitles
                    selectSheetBlock:(ActionSheetDidSelectSheetBlock)selectSheetBlock;

@end
