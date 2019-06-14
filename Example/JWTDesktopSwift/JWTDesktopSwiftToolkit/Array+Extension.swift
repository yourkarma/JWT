//
//  Array+Extension.swift
//  JWTDesktopSwift
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWTIO. All rights reserved.
//

import Foundation
extension Array {
    func safeObject(index: Array.Index) -> Element? {
        return index >= self.count ? nil : self[index]
    }
}
