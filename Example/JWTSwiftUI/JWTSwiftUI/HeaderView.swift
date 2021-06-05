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
    struct AlgorithmView: View {
        @Binding var chosenAlgorithm: String
        var values: [String] = []
        var currentBody: some View {
            Picker(selection: $chosenAlgorithm, label: Text("Choose algorithm")) {
                ForEach(self.values, id: \.self) { value in
                    Text(value).tag(value)
                }
            }
        }
        var body: some View {
            HStack {
                self.currentBody
            }
        }
    }
}

extension HeaderView {
    struct SecretView: View {
        @Binding var textValue: String
        @Binding var isToogled: Bool
        var settings: JWTModel.Storage
        var body: some View {
            VStack {
//                Text("Secret")
                TextField("secret", text: $textValue)
                Toggle(isOn: $isToogled, label: {
                    Text("Secret is base64")
                })//.disabled(!settings.isBase64Available)
            }
        }
    }
}

extension HeaderView {
    struct SignatureView: View {
        @Binding var isToogled: Bool
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

struct HeaderView: View {
    @Binding var settings: JWTModel.Storage.Settings
    @Binding var encodedData: JWTModel.Storage.EncodedData
    var storage: JWTModel.Storage
    var body: some View {
        Form {
            Section(header: Text("Algorithm")) {
                AlgorithmView(chosenAlgorithm: $encodedData.algorithmName, values: $encodedData.wrappedValue.availableAlgorithmsNames)
            }
            Section(header: Text("Input secret")) {
                SecretView(textValue: $encodedData.secret, isToogled: $settings.isBase64, settings: storage)
            }
            Section(header: Text("Signature")) {
                SignatureView(isToogled: $settings.skipSignatureVerification)
            }
        }
    }
}
