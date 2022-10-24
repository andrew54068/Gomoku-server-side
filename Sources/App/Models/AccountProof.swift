//
//  File.swift
//  
//
//  Created by Andrew Wang on 2022/10/4.
//

import Foundation
import Cadence
import FCL_SDK

struct VerifiableUser: Decodable {
    let telegramId: String
    let userAddress: Address
    let accountProofAppName: String
    let accountProof: AccountProof
}

public struct AccountProof: AccountProofVerifiable, Decodable {
    public let address: Cadence.Address
    public let nonce: String
    public let signatures: [CompositeSignatureVerifiable]
    
    private enum CodingKeys: String, CodingKey {
        case address
        case nonce
        case signatures
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.address = try container.decode(Address.self, forKey: .address)
        self.nonce = try container.decode(String.self, forKey: .nonce)
        self.signatures = try container.decode([Signature].self, forKey: .signatures)
    }
}

public struct Signature: CompositeSignatureVerifiable, Decodable {
    public let address: String
    public let keyId: Int
    // hex string
    public let signature: String
    
    enum CodingKeys: String, CodingKey {
        case address = "addr"
        case keyId
        case signature
    }
}
