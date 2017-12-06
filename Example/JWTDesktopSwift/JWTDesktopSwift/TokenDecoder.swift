//
//  JWTTokenDecoder.swift
//  JWTDesktopSwift
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWTIO. All rights reserved.
//

import Foundation
import JWT
protocol TokenDecoderNecessaryDataObject__Protocol {
    var chosenAlgorithmName: String {get}
    var chosenSecret: String? {get}
    var chosenSecretData: Data? {get}
    var isBase64EncodedSecret: Bool {get}
}

class TokenDecoder {
    private lazy var theDecoder: TokenDecoder = {
        return JWTTokenDecoder__V3()
    }()
    var builder: JWTBuilder?
    var resultType: JWTCodingResultType?
    
    func decode(token: String?, skipVerification: Bool, object: TokenDecoderNecessaryDataObject__Protocol?) throws -> [AnyHashable : Any]?  {
        guard let theObject = object else {
            return nil
        }
        return try self.theDecoder._decode(token: token, skipVerification: skipVerification, object: theObject)
    }
    
    // MARK: Subclass
    func _decode(token: String?, skipVerification: Bool, object: TokenDecoderNecessaryDataObject__Protocol) throws -> [AnyHashable : Any]?  {
        return nil
    }
}

class JWTTokenDecoder__V2: TokenDecoder {
    override func _decode(token: String?, skipVerification: Bool, object: TokenDecoderNecessaryDataObject__Protocol) throws -> [AnyHashable : Any]? {
        // do work here.
        print("JWT ENCODED TOKEN \(String(describing: token))")
        let algorithmName = object.chosenAlgorithmName
        print("JWT Algorithm NAME \(algorithmName)")
        let builder = JWTBuilder.decodeMessage(token).algorithmName(algorithmName)!.options(skipVerification as NSNumber)
        if (algorithmName != JWTAlgorithmNameNone) {
            if let secretData = object.chosenSecretData, object.isBase64EncodedSecret {
                _ = builder?.secretData(secretData)
            }
            else {
                _ = builder?.secret(object.chosenSecret)
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

class JWTTokenDecoder__V3: TokenDecoder {
    override func _decode(token: String?, skipVerification: Bool, object: TokenDecoderNecessaryDataObject__Protocol) throws -> [AnyHashable : Any]? {
        print("JWT ENCODED TOKEN \(String(describing: token))")
        let algorithmName = object.chosenAlgorithmName
        print("JWT Algorithm NAME \(algorithmName)")
        let secretData = object.chosenSecretData
        let secret = object.chosenSecret
        let isBase64EncodedSecret = object.isBase64EncodedSecret
        
        guard let algorithm = JWTAlgorithmFactory.algorithm(byName: algorithmName) else {
            return nil
        }
        
        var holder: JWTAlgorithmDataHolderProtocol? = nil
        switch algorithm {
        case is JWTAlgorithmRSBase:
            var key: JWTCryptoKeyProtocol?
            do {
                key = try JWTCryptoKeyPublic(pemEncoded: secret, parameters: nil)
            }
            catch let error {
                // throw if needed
                print("JWT internalError: \(error.localizedDescription)")
                throw error
            }
            
            // TODO: remove dependency.
            // Aware of last part.
            // DataHolder MUST have a secretData ( empty data is perfect, if you use verifyKey )
            holder = JWTAlgorithmRSFamilyDataHolder().verifyKey(key)?.algorithmName(algorithmName)?.secretData(Data())
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
        let result = builder?.result
        print("JWT ERROR: \(String(describing: result?.errorResult?.debugDescription)) -> \(String(describing: result?.errorResult?.error?.localizedDescription))")
        print("JWT RESULT: \(String(describing: result?.successResult?.debugDescription)) -> \(String(describing: result?.successResult?.headerAndPayloadDictionary?.debugDescription))")
        return result?.successResult?.headerAndPayloadDictionary
    }
}
