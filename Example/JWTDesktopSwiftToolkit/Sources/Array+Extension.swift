//
//  Array+Extension.swift
//  JWTDesktopSwift
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWTIO. All rights reserved.
//

import Foundation
public extension Array {
    func safeObject(index: Array.Index) -> Element? {
        self.indices.contains(index) ? self[index] : nil
    }
}
