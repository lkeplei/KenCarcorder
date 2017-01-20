//
//  XPSuperClassInfo.h
//  JsonModel
//
//  Created by 徐鹏 on 15/11/5.
//  Copyright © 2015年 徐鹏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_OPTIONS(NSUInteger, XPSEncodingType) {
    XPSEncodingTypeMask       = 0x1F, ///< mask of type value
    XPSEncodingTypeUnknown    = 0, ///< unknown
    XPSEncodingTypeVoid       = 1, ///< void
    XPSEncodingTypeBool       = 2, ///< bool
    XPSEncodingTypeInt8       = 3, ///< char / BOOL
    XPSEncodingTypeUInt8      = 4, ///< unsigned char
    XPSEncodingTypeInt16      = 5, ///< short
    XPSEncodingTypeUInt16     = 6, ///< unsigned short
    XPSEncodingTypeInt32      = 7, ///< int
    XPSEncodingTypeUInt32     = 8, ///< unsigned int
    XPSEncodingTypeInt64      = 9, ///< long long
    XPSEncodingTypeUInt64     = 10, ///< unsigned long long
    XPSEncodingTypeFloat      = 11, ///< float
    XPSEncodingTypeDouble     = 12, ///< double
    XPSEncodingTypeLongDouble = 13, ///< long double
    XPSEncodingTypeObject     = 14, ///< id
    XPSEncodingTypeClass      = 15, ///< Class
    XPSEncodingTypeSEL        = 16, ///< SEL
    XPSEncodingTypeBlock      = 17, ///< block
    XPSEncodingTypePointer    = 18, ///< void*
    XPSEncodingTypeStruct     = 19, ///< struct
    XPSEncodingTypeUnion      = 20, ///< union
    XPSEncodingTypeCString    = 21, ///< char*
    XPSEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    XPSEncodingTypeQualifierMask   = 0xFE0,  ///< mask of qualifier
    XPSEncodingTypeQualifierConst  = 1 << 5, ///< const
    XPSEncodingTypeQualifierIn     = 1 << 6, ///< in
    XPSEncodingTypeQualifierInout  = 1 << 7, ///< inout
    XPSEncodingTypeQualifierOut    = 1 << 8, ///< out
    XPSEncodingTypeQualifierBycopy = 1 << 9, ///< bycopy
    XPSEncodingTypeQualifierByref  = 1 << 10, ///< byref
    XPSEncodingTypeQualifierOneway = 1 << 11, ///< oneway
    
    XPSEncodingTypePropertyMask         = 0x1FF000, ///< mask of property
    XPSEncodingTypePropertyReadonly     = 1 << 12, ///< readonly
    XPSEncodingTypePropertyCopy         = 1 << 13, ///< copy
    XPSEncodingTypePropertyRetain       = 1 << 14, ///< retain
    XPSEncodingTypePropertyNonatomic    = 1 << 15, ///< nonatomic
    XPSEncodingTypePropertyWeak         = 1 << 16, ///< weak
    XPSEncodingTypePropertyCustomGetter = 1 << 17, ///< getter=
    XPSEncodingTypePropertyCustomSetter = 1 << 18, ///< setter=
    XPSEncodingTypePropertyDynamic      = 1 << 19, ///< @dynamic
    XPSEncodingTypePropertyGarbage      = 1 << 20,
};


XPSEncodingType XPSEncodingGetType(const char *typeEncoding);


@interface XPSClassIvarInfo : NSObject

@property (nonatomic, assign, readonly) Ivar ivar;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) ptrdiff_t offset;
@property (nonatomic, strong, readonly) NSString *typeEncoding;
@property (nonatomic, assign, readonly) XPSEncodingType type;

- (instancetype)initWithIvar:(Ivar)ivar;

@end


@interface XPSClassMethodInfo : NSObject
@property (nonatomic, assign, readonly) Method method;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) SEL sel;
@property (nonatomic, assign, readonly) IMP imp;
@property (nonatomic, strong, readonly) NSString *typeEncoding;
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;
@property (nonatomic, strong, readonly) NSArray *argumentTypeEncodings;

- (instancetype)initWithMethod:(Method)method;

@end


@interface XPSClassPropertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) XPSEncodingType type;
@property (nonatomic, strong, readonly) NSString *typeEncoding;
@property (nonatomic, strong, readonly) NSString *ivarName;
@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, strong, readonly) NSString *getter;
@property (nonatomic, strong, readonly) NSString *setter;

- (instancetype)initWithProperty:(objc_property_t)property;

@end


@interface XPSClassInfo : NSObject

@property (nonatomic, assign, readonly) Class cls;
@property (nonatomic, strong, readonly) Class superCls;
@property (nonatomic, assign, readonly) Class metaCls;
@property (nonatomic, assign, readonly) BOOL isMeta;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) XPSClassInfo *superClassInfo;

@property (nonatomic, strong, readonly) NSDictionary *ivarInfos;
@property (nonatomic, strong, readonly) NSDictionary *methodInfos;
@property (nonatomic, strong, readonly) NSDictionary *propertyInfos;

- (void)setNeedUpdate;

+ (instancetype)classInfoWithClass:(Class)cls;
+ (instancetype)classInfoWithClassName:(NSString *)className;

@end
