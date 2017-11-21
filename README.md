
# Keychain 有哪些功能

[Keychain - Apple文档](https://developer.apple.com/library/content/documentation/Security/Conceptual/keychainServConcepts/01introduction/introduction.html#//apple_ref/doc/uid/TP30000897-CH203-TP1)

Apple 提供的 Keychain 服务 主要用来存取密码, 总的来说有以下功能:

* 在多用户之间管理密码
* 在多端之间管理密码
* 在网页中代替输入密码

# GLKeychain 使用

快捷使用 Keychain 来管理您的密码. 目前只支持 `iOS`.

## 1 初始化

```objc
[[GLKeychain defaultManager] setupKeyChain]; // 初始化
[[GLKeychain defaultManager] changeToAccount:@"FakerUser10001"]; // 切换账户, 请自定义
[[GLKeychain defaultManager] changeToService:@"MyLoginService"]; // 切换服务, 请自定义
```

## 2 读/写密码

```objc
[[GLKeychain defaultManager] savePassword:@"新密码"]; // 写密码
NSString *pwd = [[GLKeychain defaultManager] readPassword]; // 读密码
```

# 安装

```
pod ‘GLKeychain’, ‘~> 0.0.1’

或

pod 'GLKeychain', :git => 'https://github.com/GrayLand119/GLKeychain.git'

```

# License

GLKeychain is released under the Apache license. See [LICENSE](/LICENSE) for details.
