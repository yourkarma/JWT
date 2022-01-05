//
//  String+Extension.swift
//  JWTDesktopSwift
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWTIO. All rights reserved.
//

import Foundation
public extension String {
    static func json(_ object: Any?) -> String {
        guard let jsonObject = object else {
            return ""
        }
        
        if !JSONSerialization.isValidJSONObject(jsonObject) {
            print("object is not valid JSONObject: \(jsonObject)")
            return ""
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
            return ""
        }

        guard let string = String(data: data, encoding: .utf8) else {
            return ""
        }
        return string
    }
}
