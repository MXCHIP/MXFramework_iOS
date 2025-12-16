Pod::Spec.new do |s|

  s.name         = "MeshSDK"
  s.version      = "1.0.0"
  s.summary      = "A short description of MeshSDK."

  s.description  = "mxchip mesh sdk"
  s.homepage     = "https://rd.mxchip.com/mx/mx_sdk_ios"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "huafeng" => "zhanghf@mxchip.com" }
  s.source       = { :git => "https://github.com/MXCHIP/MXFrameworks_IOS.git" }
  
  s.ios.deployment_target  = '12.0'
  
  s.static_framework = true
  s.vendored_frameworks = 'MXFrameworks/MeshSDK.framework'
  
  s.dependency 'CryptoSwift'

end
