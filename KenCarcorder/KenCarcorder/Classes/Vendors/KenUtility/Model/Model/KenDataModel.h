//
//  KenDataModel.h
//
//  Created by Ken.Liu on 16/1/14.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KenDataModel : NSObject
#pragma mark - Json -> Model
/**
 *  从Json字符串创建对象
 *
 *  @param jsonStr Json字符串
 *
 *  @return 对象实例
 */
+ (instancetype)initWithJsonString:(NSString *)jsonStr;
/**
 *  从Json字典创建对象
 *
 *  @param jsonDict Json字典
 *
 *  @return 对象实例
 */
+ (instancetype)initWithJsonDictionary:(NSDictionary *)jsonDict;
/**
 *  从JsonData创建对象
 *
 *  @param jsonData JsonData
 *
 *  @return 对象实例
 */
+ (instancetype)initWithJsonData:(NSData *)jsonData;

#pragma mark - Update Model with Json
/**
 *  从Json字符串更新对象
 *
 *  @param jsonStr Json字符串
 *
 *  @return 是否成功
 */
- (BOOL)updateWithJsonString:(NSString *)jsonStr;
/**
 *  从Json字典更新对象
 *
 *  @param jsonDict Json字典
 *
 *  @return 是否成功
 */
- (BOOL)updateWithJsonDictionary:(NSDictionary *)jsonDict;
/**
 *  从JsonData更新对象
 *
 *  @param jsonData JsonData
 *
 *  @return 是否成功
 */
- (BOOL)updateWithJsonData:(NSData *)jsonData;

#pragma mark - Model -> Json
/**
 *  对象转成Json字符串
 *
 *  @return Json字符串
 */
- (NSString *)transformToJson;

/**
 *  对象转成Json对象
 *
 *  @return Json对象,可能为 NSArray 或者 NSDictionry
 */
- (id)transformToObject;

#pragma mark - 配置各种转换规则，提供给子类继承
/**
 *  属性黑名单
 *  实现此方法返回属性黑名单
 *
 *  @return 在进行转换时需要忽略的属性数组
 */
+ (NSArray *)setPropertyBlacklist;
/**
 *  属性白名单
 *  实现此方法返回属性白名单
 *
 *  @return 在进行转换时将忽略数组之外的属性
 */
+ (NSArray *)setPropertyWhitelist;
/**
 *  设置转换时某些属性的默认值
 *  如 实现此方法返回 @{@"title":@"默认标题"}，则当 Json 数据没有 title 节点或 title 节点值为 null 时，转换时
 *  对象 title 属性将设为给定的默认值 @"默认标题"
 *
 *  @return 属性默认值字典
 */
+ (NSDictionary *)setDefaultValueMap;
/**
 *  设置转换时Json节点属性与对象属性之间自定义的映射关系字典
 *  如要把Json节点 id 转为 对象的 userID 属性， 要把Json节点 name 转为 对象的 userName 属性时
 *  只需实现此方法设置 @{@"userId":@"id", @"userName":@"name"}即可
 *
 *  @return 自定义映射关系字典
 */
+ (NSDictionary *)setCustomPropertyMap;
/**
 *  当对象属性为容器类型（如 NSArray、NSSet）时, 可调用此方法返回容器类属性中包含的对象类型映射关系字典即可完成自动转换
 *  如 @student, teacher;
 *
 *    @school
 *     @property NSArray *studentList;
 *     @property NSArray *teacherList;
 *     ...
 *    @end
 *
 *  只需实现此方法设置 @{@"studentList":[student class], @"teacherList":[teacher class]} 即可
 *
 *  @return 容器类属性中包含的对象类型映射关系字典
 */
+ (NSDictionary *)setContainerPropertyClassMap;
/**
 *  数据校验与自定义转换, 当 JSON 转为 Model 完成后，该方法会被调用。可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略
 *  可在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。也可以在这里做一些自动转换不能完成的工作
 *
 *  @param jsonDict Json字典
 *
 *  @return 返回 NO，该 Model 会被忽略
 */
- (BOOL)handleCustomTransformFromDictionary:(NSDictionary *)jsonDict;
/**
 *  数据校验与自定义转换, 当 Model 转为 JSON 完成后，该方法会被调用。可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 JSON 会被忽略
 *
 *  @param modelDict 对象字典
 *
 *  @return 返回 NO，该 JSON 会被忽略
 */
- (BOOL)handleCustomTransformToDictionary:(NSMutableDictionary *)modelDict;

#pragma mark - 缓存对象
/**
 *  缓存对象
 *
 *  @param instance 对象实例
 *
 *  @return 是否成功
 */
+ (BOOL)setInstance:(id)instance;
/**
 *  缓存对象
 *
 *  @return 是否成功
 */
- (BOOL)setInstance;
/**
 *  从缓存中取出对象
 *
 *  @return 对象实例
 */
+ (instancetype)getInstance;
/**
 *从缓存中移除对象
 */
+ (void)removeInstance;

/**
 *  获取缓存对象的关键字
 *
 *  @return 返回关键字，默认以类名作为关键字
 */
+ (NSString *)getInstanceKey;

@end
