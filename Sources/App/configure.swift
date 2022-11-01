import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import LeafKit
import Queues
import QueuesRedisDriver
import Redis

// configures your application
public func configure(_ app: Application) throws {

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    // cors middleware should come before default error middleware using `at: .beginning`
    app.middleware.use(cors, at: .beginning)

    app.http.server.configuration.port = 8081

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    app.migrations.add(CreateUser(), to: DatabaseID.psql)
    app.migrations.add(CreateComposition(), to: DatabaseID.psql)

    try app.autoMigrate().wait()

    let hostname = "127.0.0.1"
    
    let config = try RedisConfiguration(
        url: "redis://\(hostname):6379",
        pool: .init(
            maximumConnectionCount: .maximumPreservedConnections(2),
            minimumConnectionCount: 1,
            initialConnectionBackoffDelay: .seconds(1),
            connectionRetryTimeout: .seconds(1)
        )
    )

    app.queues.use(
        .redis(
            config
        )
    )

    // Register jobs
    let telegramBotJob = TelegramBotJob()
    app.queues.add(telegramBotJob)

    try app.queues.startInProcessJobs()

    // register routes
    try routes(app)
}
