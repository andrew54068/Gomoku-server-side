import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .field(.init(User.CustomFieldKey.id), .string, .identifier(auto: false))
            .field(.init(User.CustomFieldKey.telegramChatId), .int64, .required)
            .field(.init(User.CustomFieldKey.enableNotification), .string, .required)
            .field(.init(User.CustomFieldKey.createdAt), .date, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
    }
}

struct CreateComposition: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Composition.schema)
            .field(.init(Composition.CustomFieldKey.id), .string, .identifier(auto: false))
            .field(.init(Composition.CustomFieldKey.userId), .string, .required, .references(User.schema, .init(User.CustomFieldKey.id), onDelete: .cascade))
            .field(.init(Composition.CustomFieldKey.matched), .string, .required)
            .field(.init(Composition.CustomFieldKey.finished), .string, .required)
            .field(.init(Composition.CustomFieldKey.version), .uint8, .required)
            .field(.init(Composition.CustomFieldKey.round), .uint8, .required)
            .field(.init(Composition.CustomFieldKey.stepCount), .int, .required)
            .field(.init(Composition.CustomFieldKey.createdAt), .date, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Composition.schema).delete()
    }
}
