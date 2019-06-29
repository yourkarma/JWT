//
//  JWTTokenDecoder.swift
//  JWTDesktopSwift
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWTIO. All rights reserved.
//

import Foundation
import JWT
public protocol TokenDecoderNecessaryDataObject__Protocol {
    var algorithmName: String {get}
    var secret: String? {get}
    var secretData: Data? {get}
    var isBase64EncodedSecret: Bool {get}
    var shouldSkipSignatureVerification: Bool {get}
}

public class TokenDecoder {
    private lazy var theDecoder: TokenDecoder = {
        return JWTTokenDecoder__V3()
    }()
    
    fileprivate var builder: JWTBuilder?
    fileprivate var resultType: JWTCodingResultType?
    
    // MARK: Subclass
    fileprivate func _decode(token: String?, object: TokenDecoderNecessaryDataObject__Protocol) throws -> [AnyHashable : Any]?  {
        return nil
    }
    
    public init() {}
}

public extension TokenDecoder {
    struct TokenDecoderObject : TokenDecoderNecessaryDataObject__Protocol {
        public var algorithmName: String
        public var secret: String?
        public var secretData: Data?
        public var isBase64EncodedSecret: Bool
        public var shouldSkipSignatureVerification: Bool
    }
}

public extension TokenDecoder {
    func decode(token: String?, object: TokenDecoderNecessaryDataObject__Protocol?) throws -> [AnyHashable : Any]?  {
        guard let theObject = object else {
            return nil
        }
        return try self.theDecoder._decode(token: token, object: theObject)
    }
}

fileprivate class JWTTokenDecoder__V2: TokenDecoder {
    override func _decode(token: String?, object: TokenDecoderNecessaryDataObject__Protocol) throws -> [AnyHashable : Any]? {
        // do work here.
        print("JWT ENCODED TOKEN \(String(describing: token))")
        let algorithmName = object.algorithmName
        let skipVerification = object.shouldSkipSignatureVerification
        print("JWT Algorithm NAME \(algorithmName)")
        let builder = JWTBuilder.decodeMessage(token).algorithmName(algorithmName)!.options(skipVerification as NSNumber)
        if (algorithmName != JWTAlgorithmNameNone) {
            if let secretData = object.secretData, object.isBase64EncodedSecret {
                _ = builder?.secretData(secretData)
            }
            else {
                _ = builder?.secret(object.secret)
            }
        }
        
        self.builder = builder
        
        guard let decoded = builder?.decode else {
            print("JWT ERROR \(String(describing: builder?.jwtError))")
            return nil
        }
        
        print("JWT DICTIONARY \(decoded)")
        return decoded
    }
}

fileprivate class JWTTokenDecoder__V3: TokenDecoder {
    override func _decode(token: String?, object: TokenDecoderNecessaryDataObject__Protocol) throws -> [AnyHashable : Any]? {
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
        
//        let a = Bundle.main.infoDictionary?["DEPLOYMENT_RUNTIME_SWIFT"]
//
//        print("deployment swift: \(a!)")
        
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
                throw error
            }
            
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

        let builder = JWTDecodingBuilder.decodeMessage(token).addHolder(holder)?.options(skipVerification as NSNumber)
        guard let result = builder?.result else {
            return nil
        }
        
        if let success = result.successResult {
            print("JWT RESULT: \(String(describing: success.debugDescription)) -> \(String(describing: success.headerAndPayloadDictionary?.debugDescription))")
            return success.headerAndPayloadDictionary
        }
        else if let error = result.errorResult {
            print("JWT ERROR: \(String(describing: error.debugDescription)) -> \(String(describing: error.error?.localizedDescription))")
            throw error.error
        }
        
        return nil
    }
}
