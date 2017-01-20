//
//  NSMutableArray+KenArray.m
//  achr
//
//  Created by Ken.Liu on 16/6/30.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "NSMutableArray+KenArray.h"
#import "NSObject+KenObject.h"

@implementation NSMutableArray (KenArray)

#pragma mark - safe
- (void)KenAddObject:(id)anObject {
    if (!anObject) {
        [self logWarning:@"addObject: ==> object is nil"];
        return;
    }
    [self KenAddObject:anObject];
}

- (void)KenInsertObject:(id)anObject atIndex:(NSUInteger)index {
    if (index > [self count]) {
        [self logWarning:[@"insertObject:atIndex: array bounds ==>" stringByAppendingFormat:@"index[%ld] >= count[%ld]",(long)index ,
                          (long)[self count]]];
        return;
    }
    
    if (!anObject) {
        [self logWarning:@"insertObject:atIndex: ==> object is nil"];
        return;
    }
    
    [self KenInsertObject:anObject atIndex:index];
}

- (void)KenRemoveObjectAtIndex:(NSUInteger)index {
    if (index >= [self count]) {
        [self logWarning:[@"removeObjectAtIndex: array bounds ==>" stringByAppendingFormat:@"index[%ld] >= count[%ld]",(long)index ,
                          (long)[self count]]];
        return;
    }
    
    return [self KenRemoveObjectAtIndex:index];
}

- (void)KenReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (index >= [self count]) {
        [self logWarning:[@"replaceObjectAtIndex:withObject: array bounds ==>" stringByAppendingFormat:@"index[%ld] >= count[%ld]",
                          (long)index ,(long)[self count]]];
        return;
    }
    
    if (!anObject) {
        [self logWarning:@"replaceObjectAtIndex:withObject: ==> object is nil"];
        return;
    }
    
    [self KenReplaceObjectAtIndex:index withObject:anObject];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        @autoreleasepool {
            [self swizzleMethod:@selector(KenAddObject:) tarClass:@"__NSArrayM" tarSel:@selector(addObject:)];
            [self swizzleMethod:@selector(KenInsertObject:atIndex:) tarClass:@"__NSArrayM" tarSel:@selector(insertObject:atIndex:)];
            [self swizzleMethod:@selector(KenRemoveObjectAtIndex:) tarClass:@"__NSArrayM" tarSel:@selector(removeObjectAtIndex:)];
            [self swizzleMethod:@selector(KenReplaceObjectAtIndex:withObject:) tarClass:@"__NSArrayM" tarSel:@selector(replaceObjectAtIndex:withObject:)];
        }
    });
}

@end
