//
//  TokenTextTypeDescription.swift
//  JWTDesktopSwift
//
//  Created by Lobanov Dmitry on 01.10.16.
//  Copyright © 2016 JWTIO. All rights reserved.
//

import Cocoa

enum TokenTextType : Int {
    case Default = 0
    case Header
    case Payload
    case Signature
    var color : NSColor {
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
    
    var encodedTextAttributes: [NSAttributedStringKey: Any] {
        return encodedTextAttributes(type: self)
    }
    
    func encodedTextAttributes(type: TokenTextType) -> [NSAttributedStringKey: Any] {
        var attributes = self.defaultEncodedTextAttributes()
        attributes[NSAttributedStringKey.foregroundColor] = type.color
        return attributes
    }
    
    func defaultEncodedTextAttributes() -> [NSAttributedStringKey: Any] {
        return [
            NSAttributedStringKey.font : NSFont.boldSystemFont(ofSize: 22)
            ]
    }
}

class TokenTextSerialization {
    func textPart(parts: [String], type: TokenTextType) -> String? {
        var result: String? = nil
        switch type {
        case .Header:
            result = parts.first
        case .Payload:
            result = parts.safeObject(index: 1)
        case .Signature:
            if (parts.count > 2) {
                result = parts[2..<parts.count].joined(separator: ".")
            }
        default: result = nil
        }
        return result
    }
}

class TokenTextAppearance {
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
}
