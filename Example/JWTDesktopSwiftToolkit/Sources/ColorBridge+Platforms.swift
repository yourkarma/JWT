//
//  ColorBridge+Platforms.swift
//  JWTDesktopSwiftToolkit
//
//  Created by Dmitry Lobanov on 04.06.2021.
//

import Foundation

#if canImport(UIKit)
import UIKit
public typealias ColorBridge = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias ColorBridge = NSColor
#endif

public extension SignatureValidationType {
    var color: ColorBridge {
        switch self {
        case .unknown: return .darkGray
        case .valid: return .init(red: 0, green: 185/255.0, blue: 241/255.0, alpha: 1.0)
        case .invalid: return .red
        }
    }
}

public extension TokenTextType {
    var color: ColorBridge {
        switch self {
        case .unknown: return .black
        case .header: return .red
        case .payload: return .magenta
        case .signature: return .init(red: 0, green: 185/255.0, blue: 241/255.0, alpha: 1.0)
        case .dot: return .blue
        }
    }
}
