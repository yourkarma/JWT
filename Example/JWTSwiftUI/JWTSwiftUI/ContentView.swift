//
//  ContentView.swift
//  JWTSwiftUI
//
//  Created by Dmitry Lobanov on 08/06/2019.
//  Copyright © 2019 Dmitry Lobanov. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    @State var model: JWTModel
    func getBottomView () -> some View {
        BottomView(encodedData: $model.data.encodedData, decodedData: model.decodedData)
    }
    func getHeaderView () -> some View {
        HeaderView(settings: $model.data.settings, encodedData: $model.data.encodedData, storage: model.data)
    }
    var headerBody: some View {
        self.getHeaderView().tabItemLabel(
            Text("Settings")
        )
    }
    var bottomBody: some View {
        self.getBottomView().tabItemLabel(
            Text("Decoding")
        )
    }
    
    var body1: some View {
        TabbedView {
            getBottomView().tabItemLabel(
                Text("Decoding")
            )
            getHeaderView().tabItemLabel(
                Text("Settings")
            )
        }
    }
    var body2: some View {
        VStack {
            getHeaderView()
            getBottomView()
        }
    }
    var body: some View {
        body2
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        //ContentView()
        Text("abc")
    }
}
#endif
