//
//  KenAccountS.h
//  KenCarcorder
//
//  Created by Ken.Liu on 2017/2/6.
//  Copyright © 2017年 Ken.Liu. All rights reserved.
//

#import "KenHttpBaseService.h"

@interface KenAccountS : KenHttpBaseService

- (void)accountloginWithName:(NSString *)name pwd:(NSString *)pwd verCode:(NSString *)verCode
                       start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success failedBlock:(RequestFailureBlock)failed;

- (void)accountGetVerCode:(NSString *)phone start:(RequestStartBlock)start successBlock:(ResponsedSuccessBlock)success
              failedBlock:(RequestFailureBlock)failed;
@end
