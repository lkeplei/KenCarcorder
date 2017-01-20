//
//  NSObject+JsonModel.h
//  JsonModel
//
//  Created by 徐鹏 on 15/11/5.
//  Copyright © 2015年 徐鹏. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (JsonModel)

/**
*  从 Json 创建对象
*
*  @param json 可以是 NSDictionary, NSString 或者 NSData
*
*  @return 对象实例 或 nil
*/
+ (instancetype)JsonModelWithJSON:(id)json;

/**
 *  从字典创建对象
 *
 *  @param dictionary 字典
 *
 *  @return 对象实例 或 nil
 */
+ (instancetype)JsonModelWithDictionary:(NSDictionary *)dictionary;

/**
 *  从 Json 更新对象
 *
 *  @param json 可以是 NSDictionary, NSString 或者 NSData
 *
 *  @return 是否更新成功
 */
- (BOOL)JsonModelUpdateWithJSON:(id)json;

/**
 *  从字典更新对象
 *
 *  @param dic 字典
 *
 *  @return 是否更新成功
 */
- (BOOL)JsonModelUpdateWithDictionary:(NSDictionary *)dic;

/**
 *  对象转为 Json
 *
 *  @return 可以是 NSDictionary, NSString 或者 NSData 或 nil
 */
- (id)JsonModelToJSONObject;

/**
 *  对象转为 Json
 *
 *  @return Json Data
 */
- (NSData *)JsonModelToJSONData;

/**
 *  对象转为 Json
 *
 *  @return Json String
 */
- (NSString *)JsonModelToJSONString;

/**
 *  对象拷贝
 *
 *  @return 一个新的拷贝或nil
 */
- (id)JsonModelCopy;


- (void)JsonModelEncodeWithCoder:(NSCoder *)aCoder;
- (id)JsonModelInitWithCoder:(NSCoder *)aDecoder;

- (NSUInteger)JsonModelHash;

/**
 *  对象比较(判等)
 *
 *  @param model 另一个对象
 *
 *  @return 两个对象是否相同
 */
- (BOOL)JsonModelIsEqual:(id)model;

@end



@interface NSArray (JsonModel)
/**
 *  从 Json 创建对象数组
 *
 *  @param cls  目标对象类型
 *  @param json 可以是 NSDictionary, NSString 或者 NSData
 *
 *  @return 对象数组
 */
+ (NSArray *)JsonModelArrayWithClass:(Class)cls json:(id)json;

@end


@interface NSDictionary (JsonModel)
/**
 *  从 Json 创建对象字典
 *
 *  @param cls  目标对象类型
 *  @param json 可以是 NSDictionary, NSString 或者 NSData
 *
 *  @return 对象字典
 */
+ (NSDictionary *)JsonModelDictionaryWithClass:(Class)cls json:(id)json;

@end


@protocol JsonModel <NSObject>
@optional
/**
 *  设置转换时Json节点属性与对象属性之间自定义的映射关系字典
 *  如要把Json节点 id 转为 对象的 userID 属性， 要把Json节点 name 转为 对象的 userName 属性时
 *  只需调用此方法设置 @{@"id":@"userID", @"name":@"userName"}即可
 *
 *  @return 自定义映射关系字典
 */
+ (NSDictionary *)modelCustomPropertyMapper;
/**
 *  设置转换时某些属性的默认值
 *
 *  @return 属性默认值字典
 */
+ (NSDictionary *)modelDefaultValuesMapper;
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
 *  只需调用此方法设置 @{@"studentList":[student class], @"teacherList":[teacher class]} 即可
 *
 *  @return 容器类属性中包含的对象类型映射关系字典
 */
+ (NSDictionary *)modelContainerPropertyGenericClass;
/**
 *  属性黑名单
 *
 *  @return 在进行转换时需要忽略的属性数组
 */
+ (NSArray *)modelPropertyBlacklist;
/**
 *  属性白名单
 *
 *  @return 在进行转换时将忽略数组之外的属性
 */
+ (NSArray *)modelPropertyWhitelist;
/**
 *  数据校验与自定义转换, 当 JSON 转为 Model 完成后，该方法会被调用。可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略
 *  可在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。也可以在这里做一些自动转换不能完成的工作
 *
 *  @param dic 字典
 *
 *  @return 返回 NO，该 Model 会被忽略
 */
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;
/**
 *  数据校验与自定义转换, 当 Model 转为 JSON 完成后，该方法会被调用。可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 JSON 会被忽略
 *
 *  @param dic 字典
 *
 *  @return 返回 NO，该 JSON 会被忽略
 */
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic;

@end
