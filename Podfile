platform :ios, '16.0'
use_frameworks!

install! 'cocoapods', :disable_input_output_paths => true

target 'Coffeeman2' do
  pod 'GoogleMaps', '~> 10.0'
  pod 'GooglePlaces', '~> 10.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.name == 'Debug'
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      end
    end
  end
end