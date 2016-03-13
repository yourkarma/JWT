def all
  pod 'Base64', '~> 1.1.2'
end

def tests
  #pod 'Kiwi'
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMockito'
  pod 'OCMock'
end

def ios_targets
  target 'JWT', exclusive: true do
    platform :ios, '9.2'
    all
  end

  target 'JWTTests', exclusive: true do
    platform :ios, '9.2'
    all
    tests
  end
end

def osx_targets
  target 'JWT_OSX', exclusive: true do
    platform :osx, '10.8'
    all
  end

  target 'JWTTests_OSX', exclusive: true do
    platform :osx, '10.8'
    all
    tests
  end
end

ios_targets
osx_targets