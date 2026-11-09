#
# Be sure to run `pod lib lint BLEProvisioning.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RTKOTA'
  s.version          = '1.0.0'
  s.summary          = 'A short description of Mesh OTA.'

  s.description      = "mxchip mesh OTA sdk"

  s.homepage         = 'https://rd.mxchip.com/mx/mx_sdk_ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MXBleProvision' => 'zhanghf@mxchip.com' }
  s.source           = { :git => "https://rd.mxchip.com/mx/mx_sdk_ios.git" }

  s.ios.deployment_target = '12.0'

  s.static_framework = false
  s.vendored_frameworks = 'MXFrameworks/RTKOTA/*.framework'
  
  
end
