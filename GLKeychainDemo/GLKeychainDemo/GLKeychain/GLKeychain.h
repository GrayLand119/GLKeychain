//
//  GLKeychain.h
//  GLKeychainDemo
//
//  Created by GrayLand on 2017/11/21.
//  Copyright © 2017年 BodyPlus. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GLKeychainKeyType) {
    GLKeychainKeyTypeItemLabel,
    GLKeychainKeyTypeItemDescription,
    GLKeychainKeyTypeAcctount,
    GLKeychainKeyTypeService,
    GLKeychainKeyTypeComment,
    GLKeychainKeyTypePassword
};

@interface GLKeychain : NSObject

@property (nonatomic, strong, readonly) NSString * _Nonnull currentAccount;
@property (nonatomic, strong, readonly) NSString * _Nonnull currentService;

+ (instancetype _Nonnull )defaultManager;

/**
 默认取当前App的Bundle Identifier
 */
- (void)setupKeyChain;

/**
 初始化Keychain的_NonnullIdentifier

 @param identifier 例如: com.apple.dts.KeychainUI,
 */
- (void)setupKeychainWithIdentifier:(NSString * _Nonnull)identifier;


/**
 切换账户

 @param account 账户
 */
- (void)changeToAccount:(NSString * _Nonnull)account;


/**
 切换服务

 @param service 服务
 */
- (void)changeToService:(NSString * _Nonnull)service;


/**
 读取密码

 @return 密码
 */
- (NSString * _Nullable)readPassword;

/**
 保存密码到当前账户当前服务中

 @param password 密码
 */
- (void)savePassword:(NSString * _Nonnull)password;


- (void)gl_setObject:(id _Nullable )object forKeyType:(GLKeychainKeyType)keyType;

- (id _Nullable)gl_objectForKeyType:(GLKeychainKeyType)keyType;

@end
