//
//  FontBridge+Platforms.swift
//  JWTDesktopSwiftToolkit
//
//  Created by Dmitry Lobanov on 04.06.2021.
//

import Foundation

#if canImport(UIKit)
import UIKit
public typealias FontBridge = UIFont
#elseif canImport(AppKit)
import AppKit
public typealias FontBridge = NSFont
#endif

public extension TokenTextType {
    func defaultEncodedTextAttributes() -> [NSAttributedString.Key: Any] {
        [.font: FontBridge.boldSystemFont(ofSize: 22)]
    }
    var font: FontBridge {
        .boldSystemFont(ofSize: 22)
    }
}

public extension TokenTextAppearance {
    struct Attributes {
        public let color: ColorBridge
        public let font: FontBridge
    }
}
