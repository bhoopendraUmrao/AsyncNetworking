Pod::Spec.new do |s|
  s.name             = 'AsyncNetworking'
  s.version          = '0.0.2'
  s.summary          = 'URLSession Wrapper with async await' 

  s.description      = <<-DESC
URLSession Wrapper with async await
- Minimal implementation
- Super easy friendly API
- No Singletons
- No external dependencies
- Simple request cancellation
- Optimized for unit testing
- Free
                       DESC

  s.homepage         = 'https://github.com/bhoopendraUmrao/AsyncNetworking'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Bhoopendra Umrao' => 'umro16091994@gmail.com' }
  s.source           = { :git => 'https://github.com/bhoopendraUmrao/AsyncNetworking.git', :tag => s.version.to_s }

  s.swift_version = '5.0'

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  s.watchos.deployment_target = '8.0'
  s.tvos.deployment_target = '15.0'

  s.source_files = 'AsyncNetworking/**/*.{swift}'

end
