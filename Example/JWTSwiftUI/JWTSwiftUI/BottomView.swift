//
//  BottomView.swift
//  JWTSwiftUI
//
//  Created by Dmitry Lobanov on 08/06/2019.
//  Copyright © 2019 Dmitry Lobanov. All rights reserved.
//

import SwiftUI

extension BottomView {
    struct EncryptedView : View {
        @Binding var textValue : String
        var appearance = TokenTextAppearance()
        var body1: some View {
            TextField($textValue, placeholder: Text("Input secret"), onEditingChanged: { (changed) in
                if (changed) {
                    // populate to something?
                }
            }, onCommit: {
                
            }).lineLimit(10).multilineTextAlignment(.center)//.truncationMode(.middle)
        }
        var body2: some View {
            Text(textValue).lineLimit(10).padding()
        }
        
        var body3: some View {
            Text("abc")
//            List {
////                ForEach(self.appearance.encodedAttributes(text: textValue)) { value in
////                    Text(part)
////                }
//            }
        }
        
        var body: some View {
            body1
        }
    }
}

extension BottomView {
    struct DecodedView : View {
        var a: [String] = []
        var decodedInformation: [String: [String: Any]]
        func information() -> [String: [String: CustomStringConvertible]?] {
            decodedInformation.mapValues { (value) -> [String : CustomStringConvertible]? in
                return value as? [String : CustomStringConvertible]
            }
        }
        var body: some View {
            VStack {
                ForEach(self.decodedInformation.keys.sorted().identified(by: \.self)) { value in
                    Text("\(value): \(String(describing: self.information()[value]))").lineLimit(10).multilineTextAlignment(.center)
                }
            }
        }
    }
}

extension BottomView {
    struct SignatureView : View {
        var validation: SignatureValidationType
        var body: some View {
            Text(validation.title)
            .background(validation.color)
        }
    }
}

struct BottomView : View {
    @Binding var encodedData : JWTModel.Storage.EncodedData
    var decodedData : JWTModel.Storage.DecodedData
//    @State var data2 : DynamicMember<JWTModel.Storage.JWT> =  DynamicMember(JWTModel(data: JWTModel.Storage.HS256()))
    var body: some View {
        VStack {
            EncryptedView(textValue: $encodedData.token)
            DecodedView(decodedInformation: decodedData.decodedInformation)
            SignatureView(validation: decodedData.verified)
        }.padding().padding()
    }
}

#if DEBUG
struct BottomView_Previews : PreviewProvider {
    static var previews: some View {
        Text("abc")//BottomView()
    }
}
#endif
