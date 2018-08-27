import Vapor
import FluentMySQL
import Authentication
import SendGrid
import Leaf

/// Called before your application initializes.
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {

    // Router
    let router: EngineRouter
    if let mount = Environment.MOUNT {
        router = EngineRouter(caseInsensitive: false, mountPath: .constant(mount))
    } else {
        router = .default()
    }
    try routes(router)
    services.register(router, as: Router.self)

    // Server
    let server = NIOServerConfig.default(port: Environment.PORT)
    services.register(server)
    
    // Web Sockets
    let wss = NIOWebSocketServer.default()
    try sockets(wss)
    services.register(wss, as: WebSocketServer.self)
    
    // Fluent Coommands
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)

    // MySQL Database
    try services.register(FluentMySQLProvider())
    let mysqlConfig = MySQLDatabaseConfig(
        hostname: Environment.DATABASE_HOSTNAME,
        port: Environment.DATABASE_PORT,
        username: Environment.DATABASE_USER,
        password: Environment.DATABASE_PASSWORD,
        database: Environment.DATABASE_DB,
        characterSet: .utf8_general_ci,
        transport: .unverifiedTLS
    )
    services.register(mysqlConfig)
    
    // APNS
    services.register(APNS.self)
    
    // Shell
    services.register(Shell.self)
    
    // Leaf Rendering
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    // Middleware
    var middlewares = MiddlewareConfig.default()
    
    // Public Files
    middlewares.use(FileMiddleware.self)
    
    // Route Logging
    services.register(RouteLoggingMiddleware.self)
    middlewares.use(RouteLoggingMiddleware.self)
    
    // Error Logging
    services.register(ErrorLoggingMiddleware.self)
    middlewares.use(ErrorLoggingMiddleware.self)
    
    // Auth
    try services.register(AuthenticationProvider())
    middlewares.use(SessionsMiddleware.self)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
    // Secret
    services.register(SecretMiddleware.self)
    
    // Register all the middleware
    services.register(middlewares)
    
    // SendGrid Email
    if let SENDGRID_API_KEY = Environment.SENDGRID_API_KEY {
        let config = SendGridConfig(apiKey: SENDGRID_API_KEY)
        services.register(config)
        try services.register(SendGridProvider())
    }
    
    // Migrations
    var migrations = MigrationConfig()
    migrations.add(model: FileRecord.self, database: .mysql)
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Installation.self, database: .mysql)
    migrations.add(model: PushRecord.self, database: .mysql)
    migrations.add(model: BearerToken.self, database: .mysql)
    migrations.add(model: VerifyToken.self, database: .mysql)
    migrations.add(model: RemoteConfig.self, database: .mysql)
    migrations.add(model: Conversation.self, database: .mysql)
    migrations.add(model: ConversationUser.self, database: .mysql)
    migrations.add(model: Message.self, database: .mysql)
    services.register(migrations)
}
