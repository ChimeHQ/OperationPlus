Pod::Spec.new do |s|
  s.name         = 'OperationPlus'
  s.version      = '1.5.2'
  s.summary      = 'NSOperation\'s missing pieces'

  s.homepage     = 'https://github.com/ChimeHQ/OperationPlus'
  s.license      = { :type => 'BSD-3-Clause', :file => 'LICENSE' }
  s.author       = { 'Matt Massicotte' => 'support@chimehq.com' }
  s.social_media_url = 'https://twitter.com/chimehq'
  
  s.source        = { :git => 'https://github.com/ChimeHQ/OperationPlus.git', :tag => s.version }

  s.source_files  = 'OperationPlus/**/*.swift'

  s.osx.deployment_target = '10.10'
  s.ios.deployment_target = '10'
  s.tvos.deployment_target = '10'
  s.watchos.deployment_target = '3.0'

  s.cocoapods_version = '>= 1.4.0'
  s.swift_version = '5.0'
end
