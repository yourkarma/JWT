//
//  ContentView.swift
//  JWTSwiftUI
//
//  Created by Dmitry Lobanov on 08/06/2019.
//  Copyright © 2019 Dmitry Lobanov. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    @ObservedObject var model: JWTModel
    func getBottomView () -> some View {
        BottomView(encodedData: self.$model.data.encodedData, decodedData: model.decodedData)
    }
    func getHeaderView () -> some View {
        HeaderView(settings: self.$model.data.settings, encodedData: self.$model.data.encodedData, storage: self.model.data)
    }
    var headerBody: some View {
        TabView {
            self.getHeaderView().tabItem {
                Text("Settings")
            }
            self.getHeaderView().tabItem {
                Text("Settings")
            }
        }
    }
    var bottomBody: some View {
        self.getBottomView().tabItem {
            Text("Decoding")
        }
    }
    
    var body1: some View {
        TabView {
            getBottomView().tabItem {
                Text("Decoding")
            }
            getHeaderView().tabItem {
                Text("Settings")
            }
        }
    }
    var body2: some View {
        VStack {
            getHeaderView()
            getBottomView()
        }
    }
    var body3: some View {
        NavigationView {
            getBottomView()
            getHeaderView()
        }
    }
    var body4: some View {
        NavigationView {
            VStack {
                getBottomView()
                getHeaderView()
            }
        }
    }
    var body: some View {
        body4
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
