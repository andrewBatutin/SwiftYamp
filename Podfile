# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'SwiftYamp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SwiftYamp
  pod 'ByteBackpacker'
  pod 'Starscream'
  pod 'CocoaLumberjack/Swift'
  
  target 'SwiftYampTester' do
      pod 'Starscream'
  end

  target 'SwiftYampTests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end

end
