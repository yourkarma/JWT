class VersionFile
  class << self
    def version
      File.new(self.filepath).gets.rstrip
    end
    def filepath
      './VERSION'
    end
  end
end

Pod::Spec.new do |s|
  s.name         = 'JWT'
  s.version      = "#{VersionFile.version}"
  s.summary      = 'A JSON Web Token implementation in Objective-C.'
  s.homepage     = "https://github.com/yourkarma/#{s.name}"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Klaas Pieter Annema' => 'klaaspieter@annema.me' }
  s.source       = { :git => "https://github.com/yourkarma/#{s.name}.git", :tag => s.version.to_s }


  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.source_files = 'Core/**/*.{h,m}'
  s.module_name = s.name
  s.module_map  = "Core/FrameworkSupplement/Map.modulemap"
  #s.osx.exclude_files = 'JWT/**/*JWTAlgorithmRS*.{h,m}'
  s.requires_arc = true
  s.framework    = 'Security'
  s.dependency 'Base64', '~> 1.1.2'
end
