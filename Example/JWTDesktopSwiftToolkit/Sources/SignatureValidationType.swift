//
//  SignatureValidationType.swift
//  JWTDesktopSwift
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWTIO. All rights reserved.
//

public enum SignatureValidationType: Int {
    case unknown
    case valid
    case invalid
    public var title: String {
        switch self {
        case .unknown: return "Signature unknown"
        case .valid: return "Signature valid"
        case .invalid: return "Signature invalid"
        }
    }
}
