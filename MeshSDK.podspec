Pod::Spec.new do |s|

  s.name         = "MeshSDK"
  s.version      = "1.0.0"
  s.summary      = "A short description of MeshSDK."

  s.description  = "mxchip mesh sdk"
  s.homepage     = "https://rd.mxchip.com/mx/mx_sdk_ios"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "huafeng" => "zhanghf@mxchip.com" }
  s.source       = { :git => "https://github.com/MXCHIP/MXFrameworks_IOS.git" }
  
  s.ios.deployment_target  = '13.0'
  
  s.static_framework = false
  s.vendored_frameworks = 'MXFrameworks/MeshSDK.xcframework'
  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  
  s.dependency 'CryptoSwift'

end
