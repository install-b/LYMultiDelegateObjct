
Pod::Spec.new do |s|

  s.name         = "LYMultiDelegateObjct"
  s.version      = "1.1.0"
  s.summary      = "An object that can add multiple delegates."
  s.description  = "An object that can add multiple delegates. 一个可以添加多个代理的对象。"

  s.homepage     = "https://github.com/install-b/LYMultiDelegateObjct"
  s.license      = "MIT"
  s.author       = { "ShangenZhang" => "645256685@qq.com" }


  s.platform     = :os
  s.platform     = :ios, "8.0"


  s.source       = { :git => "https://github.com/install-b/LYMultiDelegateObjct.git", :tag => s.version }
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.public_header_files = "Classes/**/*.h"


  s.framework  = "Foundation"
  s.requires_arc = true

end
