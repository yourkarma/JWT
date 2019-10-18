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
            TextField("Input secret", text: $textValue).lineLimit(10).multilineTextAlignment(.center)
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
        var decodedInformation: JWTModel.Storage.DecodedData.DecodedInfoType
        var body: some View {
            VStack {
                ForEach(self.decodedInformation, id: \.0) { value in
                    Text("\(value.0): \(String(describing: value.1))").lineLimit(10).multilineTextAlignment(.center)
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

struct QqView : View {
//    @State var width: Length = 1
    static var bigText = "This is a test of the emergency broadcast system. This is only a test. If this were a real emergency, then you'd be up the creek without a paddle. But it's not so you're safe for the time being."
    @State var text: String = QqView.bigText
    var body: some View {
        GeometryReader {
            geometry in
//            ScrollView(isScrollEnabled: true, alwaysBounceHorizontal: false, alwaysBounceVertical: true, showsHorizontalIndicator: false, showsVerticalIndicator: true) {
                VStack {
                    TextField("", text: self.$text).background(Color.red)
                        .lineLimit(nil)
                        .frame(
                            minWidth: geometry.size.width,
                            idealWidth: geometry.size.width,
                            maxWidth: geometry.size.width,
                            minHeight: geometry.size.height,
                            idealHeight: geometry.size.height,
                            maxHeight: .infinity,
                            alignment: .topLeading)
                }
                
//            }
        }
    }
}

struct BottomView : View {
    @Binding var encodedData : JWTModel.Storage.EncodedData
    var decodedData : JWTModel.Storage.DecodedData
//    @State var data2 : DynamicMember<JWTModel.Storage.JWT> =  DynamicMember(JWTModel(data: JWTModel.Storage.HS256()))
    var body: some View {
        VStack {
//            QqView()
            EncryptedView(textValue: $encodedData.token)
            DecodedView(decodedInformation: decodedData.decodedInformation)
            SignatureView(validation: decodedData.verified)
        }
    }
}

#if DEBUG
struct BottomView_Previews : PreviewProvider {
    static var previews: some View {
        Text("abc")//BottomView()
    }
}
#endif
