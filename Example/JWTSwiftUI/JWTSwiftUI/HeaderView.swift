//
//  HeaderView.swift
//  JWTSwiftUI
//
//  Created by Dmitry Lobanov on 08/06/2019.
//  Copyright © 2019 Dmitry Lobanov. All rights reserved.
//

import Foundation
import SwiftUI

extension HeaderView {
    struct AlgorithmView : View {
        @Binding var chosenAlgorithm: String
        var values: [String] = []
        func v() -> [(Int, String)] {
            return Array(zip(Array(self.values.indices), self.values))
        }
        var body1: some View {
            Picker(selection: $chosenAlgorithm, label: Text("Choose algorithm")) {
                Text("HS256").tag("HS256")
                Text("RS256").tag("RS256")
//                ForEach(self.values) { value in
//                    Text(value)
//                }
            }
        }
        var body2: some View {
            Picker(selection: $chosenAlgorithm, label: Text("Choose algorithm")) {
                ForEach(self.v().identified(by: \.0)) { value in
                    Text(value.1).tag(value.1)
                }
            }
        }
        var body: some View {
            HStack {
                self.body1
            }
        }
    }
}

extension HeaderView {
    struct SecretView : View {
        @Binding var textValue : String
        @Binding var isToogled : Bool
        var settings : JWTModel.Storage
        var body: some View {
            VStack {
//                Text("Secret")
                TextField($textValue, placeholder: Text("secret"), onEditingChanged: { (changed) in
                }, onCommit: {})
                
                Toggle(isOn: $isToogled, label: {
                    Text("Secret is base64")
                })//.disabled(!settings.isBase64Available)
            }
        }
    }
}

extension HeaderView {
    struct SignatureView : View {
        @Binding var isToogled : Bool
        var body: some View {
            HStack {
//                Text("Signature")
                Toggle(isOn: $isToogled, label: {
                    Text("Skip signature verification")
                })
            }
        }
    }
}

struct HeaderView : View {
    @Binding var settings: JWTModel.Storage.Settings
    @Binding var encodedData: JWTModel.Storage.EncodedData
    var storage: JWTModel.Storage
    var body: some View {
        List {
            Section(header: Text("Algorithm")) {
                AlgorithmView(chosenAlgorithm: $encodedData.algorithmName, values: $encodedData.value.availableAlgorithmsNames)
            }
            Section(header: Text("Input secret")) {
                SecretView(textValue: $encodedData.secret, isToogled: $settings.isBase64, settings: storage)
            }
            Section(header: Text("Signature")) {
                SignatureView(isToogled: $settings.skipSignatureVerification)
            }
        }.listStyle(.grouped)
    }
}

#if DEBUG
struct HeaderView_Previews : PreviewProvider {
    static var previews: some View {
        Text("abc")
//        HeaderView()
    }
}
#endif
