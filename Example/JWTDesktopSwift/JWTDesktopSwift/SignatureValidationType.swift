//
//  SignatureValidationType.swift
//  JWTDesktopSwift
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWTIO. All rights reserved.
//

import Cocoa

enum SignatureValidationType : Int {
    case Unknown
    case Valid
    case Invalid
    var color : NSColor {
        switch self {
        case .Unknown:
            return NSColor.darkGray
        case .Valid:
            return NSColor(calibratedRed: 0, green: 185/255.0, blue: 241/255.0, alpha: 1.0)
        case .Invalid:
            return NSColor.red
        }
    }
    var title : String {
        switch self {
        case .Unknown:
            return "Signature Unknown"
        case .Valid:
            return "Signature Valid"
        case .Invalid:
            return "Signature Invalid"
        }
    }
}
