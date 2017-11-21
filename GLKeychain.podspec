
Pod::Spec.new do |s|
  s.name         = "GLKeychain"
  s.version      = "0.0.1"
  s.summary      = "iOS 下快捷使用 KeyChain 服务来管理您的代码"
  s.license      = { :type => 'Apache', :file => "LICENSE.md" }
  s.homepage     = "https://github.com/GrayLand119/GLKeychain"
  s.screenshots  = "https://github.com/GrayLand119/GLKeychain/blob/master/GLKeychainDemo01.png"
  s.author       = { "GrayLand" => "languilin1109@vip.qq.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/GrayLand119/GLKeychain.git", :tag => s.version.to_s }
  s.source_files  = "GLKeychainDemo/GLKeychainDemo/GLKeychain/**/*.{h,m}"
  s.ios.framework  = 'Security'
  s.requires_arc = true
end
