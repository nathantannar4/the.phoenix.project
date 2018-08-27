import App
import Vapor
import XCTest

final class UserTests: AppTestCase {
    
    // MARK: - Linux
    
    static let allTests = [
        ("testPing", testPing)
    ]
    
    // MARK: - Tests
    
    func testPing() throws {
        
        let a = try app.sendRequest(to: "/", method: .GET)
        XCTAssert(a.http.status == .ok, "Server Offline")
        
    }
    
}
