//
//  TokenTextTypeDescription.swift
//  JWTDesktopSwift
//
//  Created by Lobanov Dmitry on 01.10.16.
//  Copyright © 2016 JWTIO. All rights reserved.
//

import SwiftUI

// MARK: Token text type.
public enum TokenTextType : Int {
    case unknown = 0
    case header
    case payload
    case signature
    case dot
    public var color : Color {
        switch self {
        case .unknown: return .black
        case .header: return .red
        case .payload: return .purple
        case .signature: return .init(red: 0, green: 185/255.0, blue: 241/255.0, opacity: 1.0)
        case .dot: return .black
        }
    }
    public var font : Font {
        Font.system(size: 22, design: .rounded)
    }
    
    static var typicalSchemeComponents : [Self] {
        return [.header, .dot, .payload, .dot, .signature]
    }
}

// MARK: NSAttributes.
extension TokenTextType {
    fileprivate var encodedTextAttributes: [NSAttributedString.Key: Any] {
        return encodedTextAttributes(type: self)
    }
    
    fileprivate func encodedTextAttributes(type: TokenTextType) -> [NSAttributedString.Key: Any] {
        var attributes = self.defaultEncodedTextAttributes()
        attributes[NSAttributedString.Key.foregroundColor] = type.color
        return attributes
    }
    
    fileprivate func defaultEncodedTextAttributes() -> [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font : Font.system(size: 22, design: .rounded)
        ]
    }
}

// MARK: Serialization
fileprivate class TokenTextSerialization {
    public init() {}
    fileprivate func textPart(parts: [String], type: TokenTextType) -> String? {
        switch type {
        case .unknown: return nil
        case .header:
            return parts.first
        case .payload:
            guard parts.count > 1 else { return nil }
            return parts[1]
        case .signature: if parts.count > 2 { return parts[2..<parts.count].joined(separator: ".") } else { return nil }
        case .dot: return "."
        }
    }
}

// MARK: Appearance.
public class TokenTextAppearance {
    private let serialization = TokenTextSerialization()
    fileprivate func encodedAttributes(text: String, tokenSerialization: TokenTextSerialization) -> [(String, Attributes)] {
        let parts = text.components(separatedBy: ".")
        
        return TokenTextType.typicalSchemeComponents.flatMap { (type) -> [(String, Attributes)] in
            if let part = tokenSerialization.textPart(parts: parts, type: type) {
                let color = type.color
                let font = type.font
                return [(part, Attributes(color: color, font: font))]
            }
            return []
        }
    }
    public init() {}
}


// MARK: Appearance.Public.
public extension TokenTextAppearance {
    struct Attributes {
        public let color: Color
        public let font: Font
    }

    func encodedAttributes(text: String) -> [(String, Attributes)] {
        return self.encodedAttributes(text: text, tokenSerialization: self.serialization)
    }
    
    func encodedAttributedString(text: String) -> NSAttributedString? {
        return self.encodedAttributes(text: text, tokenSerialization: self.serialization).reduce(NSMutableAttributedString()) { (result, pair) in
            let (part, attributes) = pair
            let string = NSAttributedString(string: part, attributes: [
                .foregroundColor : attributes.color,
                .font : attributes.font
                ])
            result.append(string)
            return result
        }
    }
}
