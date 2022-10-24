//
//  GomokuComposition.swift
//
//
//  Created by Andrew Wang on 2022/10/2.
//

import Foundation
import Cadence

enum Role: UInt8, Decodable {
    case host
    case challenger
    
    private enum CodingKeys: String, CodingKey {
        case rawValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(UInt8.self, forKey: .rawValue)
        switch value {
        case Role.host.rawValue:
            self = .host
        case Role.challenger.rawValue:
            self = .challenger
        default:
            self = .challenger
        }
    }
}

enum StoneColor: UInt8, Decodable {
    case black
    case white

    private enum CodingKeys: String, CodingKey {
        case rawValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(UInt8.self, forKey: .rawValue)
        switch value {
        case StoneColor.black.rawValue:
            self = .black
        case StoneColor.white.rawValue:
            self = .white
        default:
            self = .white
        }
    }
}

enum GomokuResult: UInt8, Decodable {
    case hostWins
    case challengerWins
    case draw

    private enum CodingKeys: String, CodingKey {
        case rawValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(UInt8.self, forKey: .rawValue)
        switch value {
        case GomokuResult.hostWins.rawValue:
            self = .hostWins
        case GomokuResult.challengerWins.rawValue:
            self = .challengerWins
        case GomokuResult.challengerWins.rawValue:
            self = .draw
        default:
            self = .draw
        }
    }
}

struct StoneLocation: Decodable {
    let x: Int8
    let y: Int8

    var key: String {
        "\(x),\(y)"
    }
}

struct GomokuStone: Decodable {
    let color: StoneColor
    let location: StoneLocation
}

public struct GomokuComposition: Decodable {
    let uuid: Int
    let id: UInt32
    let boardSize: UInt8
    let totalRound: UInt8
    let currentRound: UInt8
    let latestBlockHeight: UInt64
    let blockHeightTimeout: UInt64
    let winner: Role?
    let host: Address
    let challenger: Address?
    let roundWinners: [GomokuResult]
    let steps: [[GomokuStone]]
    let locationStoneMaps: [[String: StoneColor]]
    let destroyable: Bool

    enum CodingKeys: CodingKey {
        case uuid
        case id
        case boardSize
        case totalRound
        case currentRound
        case latestBlockHeight
        case blockHeightTimeout
        case winner
        case host
        case challenger
        case roundWinners
        case steps
        case locationStoneMaps
        case destroyable
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(Int.self, forKey: .uuid)
        self.id = try container.decode(UInt32.self, forKey: .id)
        self.boardSize = try container.decode(UInt8.self, forKey: .boardSize)
        self.totalRound = try container.decode(UInt8.self, forKey: .totalRound)
        self.currentRound = try container.decode(UInt8.self, forKey: .currentRound)
        self.latestBlockHeight = try container.decode(UInt64.self, forKey: .latestBlockHeight)
        self.blockHeightTimeout = try container.decode(UInt64.self, forKey: .blockHeightTimeout)
        self.winner = try container.decodeIfPresent(Role.self, forKey: .winner)
        self.host = try container.decode(Address.self, forKey: .host)
        self.challenger = try container.decodeIfPresent(Address.self, forKey: .challenger)
        self.roundWinners = try container.decode([GomokuResult].self, forKey: .roundWinners)
        self.steps = try container.decode([[GomokuStone]].self, forKey: .steps)
        self.locationStoneMaps = try container.decode([[String: StoneColor]].self, forKey: .locationStoneMaps)
        self.destroyable = try container.decode(Bool.self, forKey: .destroyable)
    }
}
