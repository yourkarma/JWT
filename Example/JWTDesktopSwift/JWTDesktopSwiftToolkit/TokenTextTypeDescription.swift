//
//  TokenTextTypeDescription.swift
//  JWTDesktopSwift
//
//  Created by Lobanov Dmitry on 01.10.16.
//  Copyright © 2016 JWTIO. All rights reserved.
//

import Cocoa

public enum TokenTextType : Int {
    case Default = 0
    case Header
    case Payload
    case Signature
    public var color : NSColor {
        var color = NSColor.black
        switch self {
        case .Default:
            color = NSColor.black
        case .Header:
            color = NSColor.red
        case .Payload:
            color = NSColor.magenta
        case .Signature:
            color = NSColor(calibratedRed: 0, green: 185/255.0, blue: 241/255.0, alpha: 1.0)
        }
        return color
    }
    
    var encodedTextAttributes: [NSAttributedString.Key: Any] {
        return encodedTextAttributes(type: self)
    }
    
    func encodedTextAttributes(type: TokenTextType) -> [NSAttributedString.Key: Any] {
        var attributes = self.defaultEncodedTextAttributes()
        attributes[NSAttributedString.Key.foregroundColor] = type.color
        return attributes
    }
    
    func defaultEncodedTextAttributes() -> [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font : NSFont.boldSystemFont(ofSize: 22)
            ]
    }
}

public class TokenTextSerialization {
    func textPart(parts: [String], type: TokenTextType) -> String? {
        switch type {
        case .Header:
            return parts.first
        case .Payload:
            return parts.safeObject(index: 1)
        case .Signature:
            if (parts.count > 2) {
                return parts[2..<parts.count].joined(separator: ".")
            }
        case .Default:
            return nil
        }
        return nil
    }
    public init() {}
}

public class TokenTextAppearance {
    let serialization = TokenTextSerialization()
    public func encodedAttributedString(text: String) -> NSAttributedString? {
        return self.encodedAttributedString(text: text, tokenSerialization: self.serialization)
    }
    func encodedAttributedString(text: String, tokenSerialization: TokenTextSerialization) -> NSAttributedString? {
        let parts = text.components(separatedBy: ".")
        // next step, determine text color!
        // add missing dots.
        // restore them like this:
        // color text if you can
        var resultParts: [NSAttributedString] = [];
        for typeNumber in TokenTextType.Header.rawValue ... TokenTextType.Signature.rawValue {
            guard let type = TokenTextType(rawValue: typeNumber) else {
                continue;
            }
            
            if let currentPart = tokenSerialization.textPart(parts: parts, type: type) {
                let attributes = type.encodedTextAttributes
                let currentAttributedString = NSAttributedString(string: currentPart, attributes: attributes)
                resultParts.append(currentAttributedString)
            }
        }
        
        let attributes = TokenTextType.Default.encodedTextAttributes
        
        let dot = NSAttributedString(string: ".", attributes: attributes)
        let result = self.attributesJoinedBy(resultParts, by: dot)
        return result
    }
    public init() {}
}

extension TokenTextAppearance {
    func attributesJoinedBy(_ attributes: [NSAttributedString], by: NSAttributedString) -> NSAttributedString? {
        var array = attributes
        //        return attributes.reduce(NSAttributedString(string: ""), { (result, string) -> NSAttributedString in
        //            let mutableResult = NSMutableAttributedString(attributedString: result)
        //            mutableResult.append(by)
        //            mutableResult.append(string)
        //            return mutableResult
        //        })
        
        if let first = array.first {
            array.removeFirst()
            return array.reduce(first, { (result, string) -> NSAttributedString in
                let mutableResult = NSMutableAttributedString(attributedString: result)
                mutableResult.append(by)
                mutableResult.append(string)
                return mutableResult
            })
        }
        return nil
    }
}
