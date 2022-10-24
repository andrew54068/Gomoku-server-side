import Fluent
import FluentKit
import Vapor

public protocol FieldKeys {
    var rawValue: String { get }
}

extension FieldKey {

    public init(_ value: FieldKeys) {
        self.init(stringLiteral: value.rawValue)
    }

}

final class User: Model, Content {
    static let schema = "users"

    // address e.g. 0x8f3e345219de6fed
    @ID(custom: .init(CustomFieldKey.id)) var id: String?

    @Field(key: .init(CustomFieldKey.telegramChatId)) var telegramChatId: Int64

    @Boolean(key: .init(CustomFieldKey.enableNotification), format: .trueFalse) var enableNotification: Bool

    @Children(for: \.$user) var compositions: [Composition]

    @Timestamp(key: .init(CustomFieldKey.createdAt), on: .create)  var createdAt: Date?

    public enum CustomFieldKey: String, FieldKeys {
        case id
        case telegramChatId = "telegram_chat_id"
        case enableNotification = "enable_notification"
        case createdAt = "created_at"
    }

    init() {}

    init(
        id: String,
        telegramChatId: Int64,
        enableNotification: Bool = false
    ) {
        self.id = id
        self.telegramChatId = telegramChatId
        self.enableNotification = enableNotification
    }
}

final class Composition: Model, Content {
    static let schema: String = "compositions"

    // index e.g. "1"
    @ID(custom: .init(CustomFieldKey.id)) var id: String?

    @Parent(key: .init(CustomFieldKey.userId)) var user: User

    @Boolean(key: .init(CustomFieldKey.matched), format: .trueFalse) var matched: Bool

    @Boolean(key: .init(CustomFieldKey.finished), format: .trueFalse) var finished: Bool

    @Field(key: .init(CustomFieldKey.version)) var version: UInt8
    
    @Field(key: .init(CustomFieldKey.round))  var round: UInt8
    
    @Field(key: .init(CustomFieldKey.stepCount))  var stepCount: Int
    
    @Timestamp(key: .init(CustomFieldKey.createdAt), on: .create)  var createdAt: Date?
    
    var latestRoundStep: RoundStep {
        .init(round: round, stepCount: stepCount)
    }
    
    public enum CustomFieldKey: String, FieldKeys {
        case id
        case userId = "user_id"
        case matched
        case finished
        case round
        case stepCount = "step_count"
        case version
        case createdAt = "created_at"
    }

    init() {}

    init(
        id: String,
        userAddress: String,
        matched: Bool,
        finished: Bool = false,
        version: UInt8 = 1,
        latestRoundStep: RoundStep
    ) {
        self.id = id
        self.$user.id = userAddress
        self.matched = matched
        self.finished = finished
        self.version = version
        self.round = latestRoundStep.round
        self.stepCount = latestRoundStep.stepCount
    }
}

struct RoundStep {
    let round: UInt8
    let stepCount: Int
}

// MARK: Equatable

extension RoundStep: Equatable {

    static func == (lhs: RoundStep, rhs: RoundStep) -> Bool {
        lhs.round == rhs.round && lhs.stepCount == rhs.stepCount
    }

}
