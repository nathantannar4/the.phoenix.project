import App
import Vapor
import XCTest

final class AuthTests: AppTestCase {
    
    // MARK: Linux
    
    static let allTests = [
        ("testAuthenticationFlow", testAuthenticationFlow)
    ]
    
    // MARK: - Tests
    
    func testAuthenticationFlow() {
        
        do {
            _ = try app.getResponse(to: "/auth/register", method: .POST, data: testUser, decodeTo: User.Public.self)
            
            _ = try app.getResponse(to: "/auth/login", method: .POST, decodeTo: BearerToken.Public.self, authUser: testUser)

            _ = try app.sendRequest(to: "/auth/verify/login", method: .GET, authUser: testUser)
            
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
        
    }
}
