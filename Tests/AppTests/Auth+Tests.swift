import App
import Vapor
import Promises
import Moya
import XCTest

final class AuthTests: AppTestCase {
    
    // MARK: Linux
    
    static let allTests = [
        ("testRegister", testRegister),
        ("testLogin", testLogin)
    ]
    
    // MARK: - Tests
    
    func testRegister() {
        
        let expectation = XCTestExpectation(description: "testRegister")
        
        let user = try! User(username: String.randomAlphanumeric(ofLength: 10),
                             password: String.randomAlphanumeric(ofLength: 10))
        
        Network.request(.signUp(user), decodeAs: User.Public.self)
            .then { user in
                XCTAssert(user.id != nil)
            }.catch { error in
                XCTAssert(false, error.localizedDescription)
            }.always {
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }

    func testLogin() {
        
        let expectation = XCTestExpectation(description: "testLogin")
        
        let user = try! User(username: String.randomAlphanumeric(ofLength: 10),
                             password: String.randomAlphanumeric(ofLength: 10))
        
        Network.request(.signUp(user))
            .then { _ in
                Network.request(.login(user), decodeAs: BearerToken.Public.self)
            }.then { token in
                XCTAssert(token.expiresAt != nil)
            }.catch { error in
                XCTAssert(false, error.localizedDescription)
            }.always {
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testVerifyLogin() {
        
        let expectation = XCTestExpectation(description: "testVerifyLogin")
        
        let user = try! User(username: String.randomAlphanumeric(ofLength: 10),
                             password: String.randomAlphanumeric(ofLength: 10))
        
        Network.request(.signUp(user))
            .then { _ in
                Network.request(.login(user), decodeAs: BearerToken.Public.self)
            }.then { _ in
                Network.request(.verifyLogin, decodeAs: User.Public.self)
            }.then { authUser in
                XCTAssert(authUser.id != nil)
                XCTAssert(authUser.username == user.username)
            }.catch { error in
                XCTAssert(false, error.localizedDescription)
            }.always {
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testLogout() {
        
        let expectation = XCTestExpectation(description: "testLogout")
        
        let user = try! User(username: String.randomAlphanumeric(ofLength: 10),
                             password: String.randomAlphanumeric(ofLength: 10))
        
        Network.request(.signUp(user))
            .then { _ in
                Network.request(.login(user), decodeAs: BearerToken.Public.self)
            }.then { _ in
                Network.request(.logout)
            }.catch { error in
                XCTAssert(false, error.localizedDescription)
            }.always {
                XCTAssert(AuthPlugin.bearerToken == nil, "Auth Plugin didn't reset")
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
}
