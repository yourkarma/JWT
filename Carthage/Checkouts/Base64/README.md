[![CI Status](https://travis-ci.org/ekscrypto/Base64.svg?branch=master)](https://github.com/ekscrypto/Base64)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Base64.svg)](https://img.shields.io/cocoapods/v/Base64.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Base64 Additions for Objective-C on Mac OS X and iOS
=======


Installation
----
### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Firebase into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "ekscrypto/Base64" 
```

Run `carthage update` to build the framework and drag the built `Firebase.framework` into your Xcode project.


### Cococapods

Add the following line to your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'Base64'
end
```

Usage
----
Open the Xcode project file, and drag MF_Base64Additions.m/.h into your project.

In files where you want to use Base64 encoding/decoding, simply include the header file and use one of the provided NSData or NSString additions.
    
Example use:
    #import "MF_Base64Additions.h"
    
    NSString *helloWorld = @"Hello World";
    NSString *helloInBase64 = [helloWorld base64String];
    NSString *helloDecoded = [NSString stringFromBase64String:helloInBase64];




Performance
----
* Encoding: Approximately 4 to 5 times faster than using the equivalent SecTransform.
* Encoding: 30% faster than https://github.com/l4u/NSData-Base64
* Decoding: 5% faster than using the equivalent SecTransform.
* Decoding: 5% faster than https://github.com/l4u/NSData-Base64



Requirements
-----
* Compile with Automatic Reference Counting
* Compatible with Mac OSX 10.6+ and iOS 4.0+



Implementation
----
* Implemented as per RFC 4648, see http://www.ietf.org/rfc/rfc4648.txt for more details.



Licensing
----
* Public Domain
