//
//  JWTTokenDecoder.swift
//  JWTDesktopSwift
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWTIO. All rights reserved.
//

import Foundation
import JWT

public protocol TokenDecoderDataTransferObjectProtocol {
    var algorithmName: String {get}
    var secret: String? {get}
    var secretData: Data? {get}
    var isBase64EncodedSecret: Bool {get}
    var shouldSkipSignatureVerification: Bool {get}
}

private protocol TokenDecoderProtocol {
    func decode(token: String?, object: TokenDecoderDataTransferObjectProtocol) -> JWTCodingResultType?
}

public struct TokenDecoder: TokenDecoderProtocol {
    private let theDecoder: TokenDecoderProtocol = JWTTokenDecoder__V3()
    
    public func decode(token: String?, object: TokenDecoderDataTransferObjectProtocol?) -> JWTCodingResultType?  {
        guard let object = object else { return nil }
        return self.theDecoder.decode(token: token, object: object)
    }
    
    func decode(token: String?, object: TokenDecoderDataTransferObjectProtocol) -> JWTCodingResultType? {
        self.theDecoder.decode(token: token, object: object)
    }
    public init() {}
}

public extension TokenDecoder {
    struct DataTransferObject: TokenDecoderDataTransferObjectProtocol {
        public init(algorithmName: String, secret: String? = nil, secretData: Data? = nil, isBase64EncodedSecret: Bool, shouldSkipSignatureVerification: Bool) {
            self.algorithmName = algorithmName
            self.secret = secret
            self.secretData = secretData
            self.isBase64EncodedSecret = isBase64EncodedSecret
            self.shouldSkipSignatureVerification = shouldSkipSignatureVerification
        }
        
        public var algorithmName: String
        public var secret: String?
        public var secretData: Data?
        public var isBase64EncodedSecret: Bool
        public var shouldSkipSignatureVerification: Bool
        
    }
}

private struct JWTTokenDecoder__V2: TokenDecoderProtocol {
    func decode(token: String?, object: TokenDecoderDataTransferObjectProtocol) -> JWTCodingResultType? {
        // do work here.
        print("JWT ENCODED TOKEN \(String(describing: token))")
        let algorithmName = object.algorithmName
        let skipVerification = object.shouldSkipSignatureVerification
        print("JWT Algorithm NAME \(algorithmName)")
        let builder = JWTBuilder.decodeMessage(token).algorithmName(algorithmName)?.options(skipVerification as NSNumber)
        if (algorithmName != JWTAlgorithmNameNone) {
            if let secretData = object.secretData, object.isBase64EncodedSecret {
                _ = builder?.secretData(secretData)
            }
            else {
                _ = builder?.secret(object.secret)
            }
        }
        
        guard let decoded = builder?.decode else {
            print("JWT ERROR \(String(describing: builder?.jwtError))")
            if let error = builder?.jwtError {
                return .init(errorResult: .init(error: error))
            }
            else {
                return nil
            }
        }

        print("JWT DICTIONARY \(decoded)")
        return .init(successResult: .init(headersAndPayload: decoded))
    }
}

private struct JWTTokenDecoder__V3: TokenDecoderProtocol {
    func decode(token: String?, object: TokenDecoderDataTransferObjectProtocol) -> JWTCodingResultType? {
        print("JWT ENCODED TOKEN \(String(describing: token))")
        let algorithmName = object.algorithmName
        let skipVerification = object.shouldSkipSignatureVerification
        print("JWT Algorithm NAME \(algorithmName)")
        let secretData = object.secretData
        let secret = object.secret
        let isBase64EncodedSecret = object.isBase64EncodedSecret
        
        guard let algorithm = JWTAlgorithmFactory.algorithm(byName: algorithmName) else {
            return nil
        }
        
        var holder: JWTAlgorithmDataHolderProtocol? = nil
        switch algorithm {
        case is JWTAlgorithmRSBase, is JWTAlgorithmAsymmetricBase:
            var key: JWTCryptoKeyProtocol?
            do {
                key = try JWTCryptoKeyPublic(pemEncoded: secret, parameters: nil)
            }
            catch let error {
                // throw if needed
                print("JWT internalError: \(error.localizedDescription)")
                return .init(errorResult: .init(error: error))
            }
            
            // TODO: remove dependency.
            // Aware of last part.
            // DataHolder MUST have a secretData ( empty data is perfect, if you use verifyKey )
            holder = JWTAlgorithmRSFamilyDataHolder().verifyKey(key).algorithmName(algorithmName)
        case is JWTAlgorithmHSBase:
            let aHolder = JWTAlgorithmHSFamilyDataHolder()
            if let theSecretData = secretData, isBase64EncodedSecret {
                _ = aHolder.secretData(theSecretData)
            }
            else {
                _ = aHolder.secret(secret)
            }
            holder = aHolder.algorithmName(algorithmName)
        case is JWTAlgorithmNone:
            holder = JWTAlgorithmNoneDataHolder()
        default: break
        }
        
        let builder = JWTDecodingBuilder.decodeMessage(token).claimsSetCoordinator(JWTClaimsSetCoordinatorBase.init()).addHolder(holder)?.options(skipVerification as NSNumber)
        guard let result = builder?.result else {
            return nil
        }
        
        if let success = result.successResult {
            print("JWT RESULT: \(String(describing: success.debugDescription)) -> \(String(describing: success.headerAndPayloadDictionary?.debugDescription))")
            return result
        }
        else if let error = result.errorResult {
            print("JWT ERROR: \(String(describing: error.debugDescription)) -> \(String(describing: error.error?.localizedDescription))")
            return result
        }
        else {
            return nil
        }
    }
}
