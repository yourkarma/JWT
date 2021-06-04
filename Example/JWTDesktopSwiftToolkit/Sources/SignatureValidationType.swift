//
//  SignatureValidationType.swift
//  JWTDesktopSwift
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWTIO. All rights reserved.
//

import Cocoa

public enum SignatureValidationType : Int {
    case unknown
    case valid
    case invalid
    public var color : NSColor {
        switch self {
        case .unknown:
            return .darkGray
        case .valid:
            return .init(calibratedRed: 0, green: 185/255.0, blue: 241/255.0, alpha: 1.0)
        case .invalid:
            return .red
        }
    }
    public var title : String {
        switch self {
        case .unknown:
            return "Signature unknown"
        case .valid:
            return "Signature valid"
        case .invalid:
            return "Signature invalid"
        }
    }
}
