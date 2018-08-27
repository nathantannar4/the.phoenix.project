import Vapor
@testable import App
import XCTest

class AppTestCase: XCTestCase {
    
    var app: Application!
    
    var testUser: User {
        return try! User(username: "nathantannar", password: "password", email: "nathantannar4@gmail.com")
    }
    
    override func setUp() {
        super.setUp()
        
        try! Application.reset()
        app = try! Application.default()
    }
    
}
