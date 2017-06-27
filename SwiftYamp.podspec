Pod::Spec.new do |s|
  s.name         = "SwiftYamp"
  s.version      = "0.0.2"
  s.summary      = "SwiftYamp"

  s.homepage     = "https://github.com/andrewBatutin/SwiftYamp"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "andrewBatutin" => "abatutin@gmail.com" }

  s.source       = { :git => "https://github.com/andrewBatutin/SwiftYamp.git", :tag => s.version }
  s.source_files = 'SwiftYamp/**/*'
  s.framework    = 'Foundation'

  s.ios.deployment_target = '10.0'
  s.requires_arc = true

  s.dependency 'ByteBackpacker'
  s.dependency 'Starscream'
  s.dependency 'CocoaLumberjack/Swift'

end
