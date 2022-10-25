#
# Be sure to run `pod lib lint CJGNavigationController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CJGNavigationController'
  s.version          = '1.0.7'
  s.summary          = '自定义导航栏，可以修改颜色、透明度'
  s.description      = '自定义导航栏，可以在单个Controller修改颜色、透明度'
  s.homepage         = 'https://github.com/MackolChen/CJGNavigationController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MackolChen' => 'engineer_macchen@163.com' }
  s.source           = { :git => 'https://github.com/MackolChen/CJGNavigationController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.ios.deployment_target = '10.0'
  s.source_files = 'CJGNavigationController/Classes/**/*'
  s.resources    = 'CJGNavigationController/Assets/CJGNavigationController-source.bundle'
#  s.resource_bundles = {
#     'CJGNavigationController-source' => ['CJGNavigationController/Assets/*']
#  }
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
