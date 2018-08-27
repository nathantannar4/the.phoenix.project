import Vapor
@testable import App
import FluentMySQL
import Authentication

extension Application {
    
    static func `default`() throws -> Application {
        return try Application.testable(arguments: [])
    }
    
    static func testable(arguments: [String]) throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = try Environment.detect()
        env.arguments = arguments
        
        try App.configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services)
        
        try App.boot(app)
        return app
    }
    
    static func reset() throws {
        let revertEnvironment = ["vapor", "revert", "--all", "-y"]
        try Application.testable(arguments: revertEnvironment).asyncRun().wait()
        let migrateEnvironment = ["vapor", "migrate", "-y"]
        try Application.testable(arguments: migrateEnvironment).asyncRun().wait()
    }
    
    func sendRequest<T>(to path: String, method: HTTPMethod, headers: HTTPHeaders = .init(), body: T? = nil, authUser: User? = nil) throws -> Response where T: Content {
        var headers = headers
        headers.add(name: .xApiKey, value: Environment.X_API_KEY!)
        if let user = authUser {
            var tokenHeaders = HTTPHeaders()
            let credentials = BasicAuthorization(username: user.username, password: user.password)
            tokenHeaders.basicAuthorization = credentials
            let tokenResponse = try self.sendRequest(to: "/auth/login", method: .POST, headers: tokenHeaders)
            let token = try tokenResponse.content.decode(BearerToken.Public.self).wait()
            headers.add(name: .authorization, value: "Bearer \(token.value)")
        }
        let responder = try self.make(Responder.self)
        let request = HTTPRequest(method: method, url: URL(string: path)!, headers: headers)
        let wrappedRequest = Request(http: request, using: self)
        if let body = body {
            try wrappedRequest.content.encode(body)
        }
        return try responder.respond(to: wrappedRequest).wait()
    }
    
    func sendRequest(to path: String, method: HTTPMethod, headers: HTTPHeaders = .init(), authUser: User? = nil) throws -> Response {
        let emptyContent: EmptyContent? = nil
        return try sendRequest(to: path, method: method, headers: headers, body: emptyContent, authUser: authUser)
    }
    
    func getResponse<C, T>(to path: String, method: HTTPMethod, headers: HTTPHeaders = .init(), data: C? = nil, decodeTo type: T.Type, authUser: User? = nil) throws -> T where C: Content, T: Decodable {
        let response = try self.sendRequest(to: path, method: method, headers: headers, body: data, authUser: authUser)
        return try response.content.decode(type).wait()
    }
    
    func getResponse<T>(to path: String, method: HTTPMethod, headers: HTTPHeaders = .init(), decodeTo type: T.Type, authUser: User? = nil) throws -> T where T: Content {
        let emptyContent: EmptyContent? = nil
        return try self.getResponse(to: path, method: method, headers: headers, data: emptyContent, decodeTo: type, authUser: authUser)
    }
    
    func sendRequest<T>(to path: String, method: HTTPMethod, headers: HTTPHeaders, data: T, authUser: User? = nil) throws where T: Content {
        _ = try self.sendRequest(to: path, method: method, headers: headers, body: data, authUser: authUser)
    }
    
}

struct EmptyContent: Content {}
