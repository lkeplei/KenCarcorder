//
//  UIDevice+KenDevice.m
//  将 IOS7 后获取各种UUID的方法封装成一个类
//
//  Created by Ken.Liu on 16/5/31.
//  Copyright © 2016年 Hangzhou Ai Cai Network Technology Co., Ltd. All rights reserved.
//

#import "UIDevice+KenDevice.h"
#import "KenKeyChainStore.h"

#include <sys/sysctl.h>
#import <objc/runtime.h>

@interface UIDevice ()

@property (nonatomic, strong) NSMutableDictionary *uuidForKey;
@property (nonatomic, strong) NSString *uuidForSession;
@property (nonatomic, strong) NSString *uuidForInstallation;
@property (nonatomic, strong) NSString *uuidForDevice;
@property (nonatomic, strong) NSString *uuidsOfUserDevices;
@property (nonatomic, strong) NSMutableOrderedSet *uuidsOfUserDevicesSet;

@end

@implementation UIDevice (KenDevice)

NSString *const UUIDsOfUserDevicesDidChangeNotification = @"XPSuperKitUUIDsOfUserDevicesDidChangeNotification";

NSString *const _uuidForInstallationPriKey = @"xp_uuidForInstallation";
NSString *const _uuidForDevicePriKey = @"xp_uuidForDevice";
NSString *const _uuidsOfUserDevicesPriKey = @"xp_uuidsOfUserDevices";
NSString *const _uuidsOfUserDevicesTogglePriKey = @"xp_uuidsOfUserDevicesToggle";

+ (UIDevice *)sharedInstance {
    static UIDevice *instance = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
        [instance uuidsOfUserDevicesICloudInit];
    });
    
    return instance;
}

#pragma mark - 对外接口
+ (float)iOSVersion {
    return [[UIDevice currentDevice].systemVersion floatValue];
}

+ (NSString *)uuid {
    return [[self sharedInstance] uuid];
}

+ (NSString *)uuidWithKey:(id<NSCopying>)key {
    return [[self sharedInstance] uuidWithKey:key];
}

+ (NSString *)uuidWithSession {
    return [[self sharedInstance] uuidWithSession];
}

+ (NSString *)uuidWithInstallation {
    return [[self sharedInstance] uuidWithInstallation];
}

+ (NSString *)uuidWithVendor {
    return [[[[[UIDevice currentDevice] identifierForVendor] UUIDString] lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

+ (NSString *)uuidWithDevice {
    return [[self sharedInstance] uuidWithDevice];
}

+ (NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key commitMigration:(BOOL)commitMigration {
    return [[self sharedInstance] uuidForDeviceMigratingValueForKey:key service:nil accessGroup:nil commitMigration:commitMigration];
}

+ (NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service commitMigration:(BOOL)commitMigration {
    return [[self sharedInstance] uuidForDeviceMigratingValueForKey:key service:service accessGroup:nil commitMigration:commitMigration];
}

+ (NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
                               commitMigration:(BOOL)commitMigration {
    return [[self sharedInstance] uuidForDeviceMigratingValueForKey:key service:service accessGroup:accessGroup commitMigration:commitMigration];
}

+ (NSArray *)uuidsWithUserDevices {
    return [[self sharedInstance] uuidsWithUserDevices];
}

+ (BOOL)uuidValueIsValid:(NSString *)uuidValue {
    return [[self sharedInstance] uuidValueIsValid:uuidValue];
}

+ (NSString *)getCurrentDeviceModelDescription {
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

#pragma mark - private method
- (NSString *)uuid {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    
    NSString *uuidValue = (__bridge_transfer NSString *)uuidStringRef;
    uuidValue = [uuidValue lowercaseString];
    uuidValue = [uuidValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return uuidValue;
}

- (NSString *)uuidWithKey:(id<NSCopying>)key {
    if( self.uuidForKey == nil ){
        self.uuidForKey = [[NSMutableDictionary alloc] init];
    }
    
    NSString *uuidValue = [self.uuidForKey objectForKey:key];
    
    if( uuidValue == nil ){
        uuidValue = [self uuid];
        
        [self.uuidForKey setObject:uuidValue forKey:key];
    }
    
    return uuidValue;
}

- (NSString *)uuidWithSession {
    if(self.uuidForSession == nil){
        self.uuidForSession = [self uuid];
    }
    
    return self.uuidForSession;
}

- (NSString *)uuidWithInstallation {
    if(self.uuidForInstallation == nil) {
        self.uuidForInstallation = [[NSUserDefaults standardUserDefaults] stringForKey:_uuidForInstallationPriKey];
        
        if(self.uuidForInstallation == nil){
            self.uuidForInstallation = [self uuid];
            
            [[NSUserDefaults standardUserDefaults] setObject:self.uuidForInstallation forKey:_uuidForInstallationPriKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    return self.uuidForInstallation;
}

- (NSString *)uuidForDeviceUsingValue:(NSString *)uuidValue {
    NSString *uuidForDeviceInMemory = self.uuidForDevice;
    
    if (self.uuidForDevice == nil) {
        self.uuidForDevice = [KenKeyChainStore stringForKey:_uuidForDevicePriKey];
        
        if(self.uuidForDevice == nil){
            self.uuidForDevice = [[NSUserDefaults standardUserDefaults] stringForKey:_uuidForDevicePriKey];
            
            if(self.uuidForDevice == nil ) {
                if([self uuidValueIsValid:uuidValue]) {
                    self.uuidForDevice = uuidValue;
                } else {
                    self.uuidForDevice = [self uuid];
                }
            }
        }
    }
    
    if ([self uuidValueIsValid:uuidValue] && ![self.uuidForDevice isEqualToString:uuidValue]) {
        [NSException raise:@"不能覆盖 uuidForDevice" format:@"uuidForDevice 已存在，不能被覆盖."];
    }
    
    if (![uuidForDeviceInMemory isEqualToString:self.uuidForDevice]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.uuidForDevice forKey:_uuidForDevicePriKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [KenKeyChainStore setString:self.uuidForDevice forKey:_uuidForDevicePriKey];
    }
    
    return self.uuidForDevice;
}

- (NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key commitMigration:(BOOL)commitMigration {
    return [self uuidForDeviceMigratingValueForKey:key service:nil accessGroup:nil commitMigration:commitMigration];
}

- (NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service commitMigration:(BOOL)commitMigration {
    return [self uuidForDeviceMigratingValueForKey:key service:service accessGroup:nil commitMigration:commitMigration];
}

- (NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
                                commitMigration:(BOOL)commitMigration {
    NSString *uuidToMigrate = nil;
    
    uuidToMigrate = [KenKeyChainStore stringForKey:key service:service accessGroup:accessGroup];
    
    if (uuidToMigrate == nil) {
        uuidToMigrate = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }
    
    if (commitMigration) {
        if([self uuidValueIsValid:uuidToMigrate]) {
            return [self uuidForDeviceUsingValue:uuidToMigrate];
        } else {
            return nil;
        }
    } else {
        return uuidToMigrate;
    }
}

- (void)uuidsOfUserDevicesICloudInit {
    if (NSClassFromString(@"NSUbiquitousKeyValueStore")) {
        NSUbiquitousKeyValueStore *iCloud = [NSUbiquitousKeyValueStore defaultStore];
        
        if (iCloud) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uuidsOfUserDevices_iCloudChange:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil];
            for (NSString *uuidOfUserDevice in [self uuidsWithUserDevices] ) {
                NSString *uuidOfUserDeviceAsKey = [NSString stringWithFormat:@"%@_%@", _uuidForDevicePriKey, uuidOfUserDevice];
                
                if (![[iCloud stringForKey:uuidOfUserDeviceAsKey] isEqualToString:uuidOfUserDevice]){
                    [iCloud setString:uuidOfUserDevice forKey:uuidOfUserDeviceAsKey];
                }
            }
            
            [iCloud setBool:![iCloud boolForKey:_uuidsOfUserDevicesTogglePriKey] forKey:_uuidsOfUserDevicesTogglePriKey];
            
            [iCloud synchronize];
        } else {
            //NSLog(@"iCloud 无效");
        }
    } else {
        //NSLog(@"iOS < 5");
    }
}

- (void)uuidsOfUserDevices_iCloudChange:(NSNotification *)notification {
    @synchronized(self) {
        NSMutableOrderedSet *uuidsSet = [[NSMutableOrderedSet alloc] initWithArray:[self uuidsWithUserDevices]];
        NSInteger uuidsCount = [uuidsSet count];
        
        NSUbiquitousKeyValueStore *iCloud = [NSUbiquitousKeyValueStore defaultStore];
        NSDictionary *iCloudDict = [iCloud dictionaryRepresentation];
        
        [iCloudDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            NSString *uuidKey = (NSString *)key;
            
            if ([uuidKey rangeOfString:_uuidForDevicePriKey].location == 0) {
                if ([obj isKindOfClass:[NSString class]]) {
                    NSString *uuidValue = (NSString *)obj;
                    
                    if ([uuidKey rangeOfString:uuidValue].location != NSNotFound && [self uuidValueIsValid:uuidValue]) {
                        [uuidsSet addObject:uuidValue];
                    } else {
                        //NSLog(@"无效的UUID");
                    }
                }
            }
        }];
        
        if ([uuidsSet count] != uuidsCount) {
            self.uuidsOfUserDevices = [[uuidsSet array] componentsJoinedByString:@"|"];
            
            [[NSUserDefaults standardUserDefaults] setObject:self.uuidsOfUserDevices forKey:_uuidsOfUserDevicesPriKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [KenKeyChainStore setString:self.uuidsOfUserDevices forKey:_uuidsOfUserDevicesPriKey];
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[self uuidsOfUserDevices] forKey:@"uuidsOfUserDevices"];
            [[NSNotificationCenter defaultCenter] postNotificationName:UUIDsOfUserDevicesDidChangeNotification object:self userInfo:userInfo];
        }
    }
}

- (NSString *)uuidWithDevice {
    return [self uuidForDeviceUsingValue:nil];
}

- (NSArray *)uuidsWithUserDevices {
    NSString *uuidsOfUserDevicesInMemory = self.uuidsOfUserDevices;
    
    if (self.uuidsOfUserDevices == nil) {
        self.uuidsOfUserDevices = [KenKeyChainStore stringForKey:_uuidsOfUserDevicesPriKey];
        
        if (self.uuidsOfUserDevices == nil) {
            self.uuidsOfUserDevices = [[NSUserDefaults standardUserDefaults] stringForKey:_uuidsOfUserDevicesPriKey];
            
            if(self.uuidsOfUserDevices == nil) {
                self.uuidsOfUserDevices = [self uuidWithDevice];
            }
        }
    }
    
    if (![uuidsOfUserDevicesInMemory isEqualToString:self.uuidsOfUserDevices]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.uuidsOfUserDevices forKey:_uuidsOfUserDevicesPriKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [KenKeyChainStore setString:self.uuidsOfUserDevices forKey:_uuidsOfUserDevicesPriKey];
    }
    
    return [self.uuidsOfUserDevices componentsSeparatedByString:@"|"];
}

- (BOOL)uuidValueIsValid:(NSString *)uuidValue {
    return (uuidValue != nil && (uuidValue.length == 32 || uuidValue.length == 36));
}

#pragma mark - 扩展属性
NSString const *UIDevice_uuidForKey  = @"UIDevice_uuidForKey";
NSString const *UIDevice_uuidForSession  = @"UIDevice_uuidForSession";
NSString const *UIDevice_uuidForInstallation  = @"UIDevice_uuidForInstallation";
NSString const *UIDevice_uuidForDevice  = @"UIDevice_uuidForDevice";
NSString const *UIDevice_uuidsOfUserDevices  = @"UIDevice_uuidsOfUserDevices";
NSString const *UIDevice_uuidsOfUserDevicesSet  = @"UIDevice_uuidsOfUserDevicesSet";

- (NSMutableDictionary *)uuidForKey {
    return objc_getAssociatedObject(self, &UIDevice_uuidForKey);
}

- (void)setUuidForKey:(NSMutableDictionary *)uuidForKey {
    objc_setAssociatedObject(self, &UIDevice_uuidForKey, uuidForKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)uuidForSession {
    return objc_getAssociatedObject(self, &UIDevice_uuidForSession);
}

- (void)setUuidForSession:(NSString *)uuidForSession {
    objc_setAssociatedObject(self, &UIDevice_uuidForSession, uuidForSession, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)uuidForInstallation {
    return objc_getAssociatedObject(self, &UIDevice_uuidForInstallation);
}

- (void)setUuidForInstallation:(NSString *)uuidForInstallation {
    objc_setAssociatedObject(self, &UIDevice_uuidForInstallation, uuidForInstallation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)uuidForDevice {
    return objc_getAssociatedObject(self, &UIDevice_uuidForDevice);
}

- (void)setUuidForDevice:(NSString *)uuidForDevice {
    objc_setAssociatedObject(self, &UIDevice_uuidForDevice, uuidForDevice, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)uuidsOfUserDevices {
    return objc_getAssociatedObject(self, &UIDevice_uuidsOfUserDevices);
}

- (void)setUuidsOfUserDevices:(NSString *)uuidsOfUserDevices {
    objc_setAssociatedObject(self, &UIDevice_uuidsOfUserDevices, uuidsOfUserDevices, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableOrderedSet *)uuidsOfUserDevicesSet {
    return objc_getAssociatedObject(self, &UIDevice_uuidsOfUserDevicesSet);
}

- (void)setUuidsOfUserDevicesSet:(NSMutableOrderedSet *)uuidsOfUserDevicesSet {
    objc_setAssociatedObject(self, &UIDevice_uuidsOfUserDevicesSet, uuidsOfUserDevicesSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
