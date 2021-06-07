//
//  MacJWTSwiftUIApp.swift
//  MacJWTSwiftUI
//
//  Created by Dmitry Lobanov on 07.06.2021.
//  Copyright © 2021 Dmitry Lobanov. All rights reserved.
//

import SwiftUI

@main
struct MacJWTSwiftUIApp: App {
    @StateObject private var model: JWTModel = .init(data: .RS256())

    var body: some Scene {
        WindowGroup {
            ContentView.init(model: self.model)
        }
    }
}
