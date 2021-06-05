//
//  JWTData.swift
//  JWTSwiftUI
//
//  Created by Dmitry Lobanov on 11/06/2019.
//  Copyright © 2019 Dmitry Lobanov. All rights reserved.
//

import SwiftUI
import Combine
import JWT
import JWTDesktopSwiftToolkit

class JWTModel: ObservableObject {
    @Published var data: Storage {
        didSet {
            self.computeDecoding()
        }
    }

    @Published var decodedData: Storage.DecodedData = .init()

    var decoder: TokenDecoder = .init()
    var appearance: TokenTextAppearance = .init()
    public init(data: Storage) {
        self.data = data
        // update data right after init or in stored property setter?

        // we need somehow look after values of storage.
        self.computeDecoding()
    }

    func getObject() -> TokenDecoder.DataTransferObject {
        let settings = self.data.settings
        let encodedData = self.data.encodedData
        let algorithmName = encodedData.algorithmName
        let secret = encodedData.secret
        let secretData: Data? = self.data.getSecretData()
        let isBase64EncodedSecret = settings.isBase64
        let shouldSkipSignatureVerification = settings.skipSignatureVerification

        return .init(algorithmName: algorithmName, secret: secret, secretData: secretData, isBase64EncodedSecret: isBase64EncodedSecret, shouldSkipSignatureVerification: shouldSkipSignatureVerification)
    }

    func computeEncoding() {
        // let object = self.getObject()
    }

    func computeDecoding() {
        let object = self.getObject()
        let token = self.data.encodedData.token
        // and we should also populate data after decoding.
        // check it in another JWT project.
        // where you should update data.
        var forSignatureObject = object
        forSignatureObject.shouldSkipSignatureVerification = false

        self.decodedData.verified = (self.decoder.decode(token: token, object: forSignatureObject)?.errorResult != nil) ? .invalid : .valid

        if let decoded = self.decoder.decode(token: token, object: object) {
            if let successResult = decoded.successResult {
                self.decodedData.result = .success(successResult.headerAndPayloadDictionary as! [String: Any])
            }
            else if let errorResult = decoded.errorResult {
                self.decodedData.result = .failure(errorResult.error)
            }
        }
    }
}

// MARK: Data.
extension JWTModel {
    struct Storage {
        var settings: Settings = .init()
        var encodedData: EncodedData = .init()
        var isBase64Available: Bool {
            self.settings.isBase64 && self.getSecretData() != nil
        }
        fileprivate func getSecretData() -> Data? {
            let secret = encodedData.secret
            let isBase64Encoded = settings.isBase64
            guard let result = Data(base64Encoded: secret), isBase64Encoded else {
                return nil
            }
            return result
        }
    }
}

// MARK: Settings structure.
extension JWTModel.Storage {
    struct Settings {
        var isBase64 = false // HeaderView.SecretView
        var skipSignatureVerification = false // HeaderView.SignatureView
    }
}

// MARK: EncodedData structure.
extension JWTModel.Storage {
    struct EncodedData {
        var algorithmName = "" // HeaderView.AlgorithmView
        var secret = "" // HeaderView.SecretView
        var token = "" // BottomView.EncryptedTextView
    }
}

// MARK: DecodedData structure.
extension JWTModel.Storage {
    struct DecodedData {
        var result: Result<[String: Any], Error> = .success([:])
        var verified: SignatureValidationType = .unknown
        var decoded: [String: Any] {
            guard case let .success(value) = self.result else {
                return [:]
            }
            return value
        }
        var error: Error? {
            guard case let .failure(value) = self.result else {
                return nil
            }
            return value
        }
    }
}

// MARK: decodedInformation
extension JWTModel.Storage.DecodedData {
    typealias DecodedInfoType = [(DecodedInformation, String)]
    private func decodedInfo() -> DecodedInfoType {
        if let error = self.error {
            return [
                (.error, String.json(["error": error.localizedDescription]))
            ]
        }
        else if let headers = decoded[JWTCodingResultComponents.headers!] as? [String: Any], let payload = decoded[JWTCodingResultComponents.payload!] as? [String: Any] {
            return [
                (.header, String.json(headers)),
                (.payload, String.json(payload))
            ]
        }
        else {
            return [
                (.unknown, String.json(["unknown": "unknown"]))
            ]
        }
    }
    var decodedInformation: DecodedInfoType {
        self.decodedInfo()
    }
}

// MARK: Algorithms.
extension JWTModel.Storage.EncodedData {
    var availableAlgorithms: [JWTAlgorithm] {
        JWTAlgorithmFactory.algorithms()
    }
    var availableAlgorithmsNames: [String] {
        self.availableAlgorithms.map(\.name)
    }
}

// MARK: DecodedInformation
extension JWTModel.Storage.DecodedData {
    enum DecodedInformation: String {
        case error
        case header
        case payload
        case unknown
        var uiColor: UIColor {
            switch self {
            case .error: return SignatureValidationType.invalid.color
            case .header: return TokenTextType.header.color
            case .payload: return TokenTextType.payload.color
            case .unknown: return TokenTextType.unknown.color
            }
        }
        var color: Color {
            .init(self.uiColor)
        }
    }
}

//MARK: Data Seed
extension JWTModel.Storage {
    static func create(algorithmName: String, secret: String, token: String) -> Self {
        let encodedData: EncodedData = .init(algorithmName: algorithmName, secret: secret, token: token)
        let settings: Settings = .init(isBase64: true, skipSignatureVerification: false)
        return .init(settings: settings, encodedData: encodedData)
    }
    static func HS256() -> Self {
        let algorithmName = JWTAlgorithmNameHS256
        let secret = "c2VjcmV0"
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ"
        return self.create(algorithmName: algorithmName, secret: secret, token: token)
    }

    static func RS256() -> Self {
        let algorithmName = JWTAlgorithmNameRS256
        let secret = "-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoPryo3IisfK3a028bwgso/CW5kB84mk6Y7rO76FxJRTWnOAla0Uf0OpIID7go4Qck66yT4/uPpiOQIR0oW0plTekkDP75EG3d/2mtzhiCtELV4F1r9b/InCN5dYYK8USNkKXgjbeVyatdUvCtokz10/ibNZ9qikgKf58qXnn2anGvpE6ded5FOUEukOjr7KSAfD0KDNYWgZcG7HZBxn/3N7ND9D0ATu2vxlJsNGOkH6WL1EmObo/QygBXzuZm5o0N0W15EXpWVbl4Ye7xqPnvc1i2DTKxNUcyhXfDbLw1ee2d9T/WU5895Ko2bQ/O/zPwUSobM3m+fPMW8kp5914kwIDAQAB-----END PUBLIC KEY-----"
        let token = "eyJraWQiOiJqd3RfdWF0X2tleXMiLCJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiI1MDAxIiwiaXNzIjoiQ0xNIiwiZXhwIjoxNTA4MjQ5NTU3LCJqdGkiOiI2MjcyM2E4Yi0zOTZmLTQxYmYtOTljMi02NWRkMzk2MDNiNjQifQ.Cej8RJ6e2HEU27rh_TyHZBoMI1jErmhOfSFY4SRzRoijSP628hM82XxjDX24HsKqIsK1xeeGI1yg1bed4RPhnmDGt4jAY73nqguZ1oqZ2DTcfZ5olxCXyLLaytl2XH7-62M_mFUcGj7I2mwts1DQkHWnFky2i4uJXlksHFkUg2xZoGEjVHo0bxCxgQ5yQiOpxC5VodN5rAPM3A5yMG6EijOp-dvUThjoJ4RFTGKozw_x_Qg6RLGDusNcmLIMbHasTsyZAZle6RFkwO0Sij1k6z6_xssbOl-Q57m7CeYgVHMORdzy4Smkmh-0gzeiLsGbCL4fhgdHydpIFajW-eOXMw"
        return self.create(algorithmName: algorithmName, secret: secret, token: token)
    }
}
