import Vapor
import FluentMySQL

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.get { req throws -> Future<ServerStatus> in
        return Future.map(on: req) {
            ServerStatus(status: "Online", message: "Welcome to the Phoenix API")
        }
    }
    
    let authController = AuthController()
    try router.register(collection: authController)
    
    let userController = UserController()
    try router.register(collection: userController)
    
    let pushController = PushController()
    try router.register(collection: pushController)
    
    let remoteConfigController = RemoteConfigController()
    try router.register(collection: remoteConfigController)
    
    let installationController = InstallationController()
    try router.register(collection: installationController)
    
    let conversationController = ConversationController()
    try router.register(collection: conversationController)
    
    let fileController = FileController()
    try router.register(collection: fileController)
    
}
