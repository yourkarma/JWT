source 'https://github.com/CocoaPods/Specs.git'

def target_name
  'JWT'
end

def test_name
  target_name + 'Tests'
end

def utilities
  pod 'Base64', '~> 1.1.2'
end

target target_name do
  utilities
end

target test_name do
  utilities
  pod 'Kiwi'
end
