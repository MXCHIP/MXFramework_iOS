#
# Be sure to run `pod lib lint MXAPIManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MXAPIManager'
  s.version          = '1.0.0'
  s.summary          = 'A short description of MXAPIManager.'
  
  s.description      = "mxchip request sdk"
  s.homepage     = "https://rd.mxchip.com/mx/mx_sdk_ios"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "huafeng" => "zhanghf@mxchip.com" }
  s.source       = { :git => "https://github.com/MXCHIP/MXFrameworks_IOS.git" }

  s.ios.deployment_target = '12.0'

  s.vendored_frameworks = 'MXFrameworks/MXAPIManager.framework'
  s.static_framework = true
  
  s.dependency 'Alamofire'
   
end
