//
//  SignatureValidationType.swift
//  JWTDesktopSwift
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWTIO. All rights reserved.
//

import SwiftUI

public enum SignatureValidationType : Int {
    case unknown
    case valid
    case invalid
}

fileprivate extension SignatureValidationType {
    var titleComponent : String {
        switch self {
        case .unknown:
            return "unknown"
        case .valid:
            return "valid"
        case .invalid:
            return "invalid"
        }
    }
}

public extension SignatureValidationType {
    var color : Color {
        switch self {
        case .unknown:
            return Color.gray
        case .valid:
            return Color(red: 0, green: 185/255.0, blue: 241/255.0, opacity: 1.0)
        case .invalid:
            return Color.red
        }
    }
    
    var title : String {
        return "Signature \(titleComponent)"
    }
}
