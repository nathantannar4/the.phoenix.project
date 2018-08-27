import App
import Vapor
import XCTest

final class BasicTests: AppTestCase {
    
    var cache: RemoteConfig?
    
    // MARK: - Linux
    
    static let allTests = [
        ("testPing", testPing)
    ]
    
    // MARK: - Tests
    
    func testPing() throws {
        
        let a = try app.sendRequest(to: "/", method: .GET)
        XCTAssert(a.http.status == .ok, "Server Offline")
        
    }
    
    func testCreate() throws {
        
        let KEY = "TEST_KEY"
        let VALUE = "TEST_VALUE"
        
        let data = RemoteConfig(key: KEY, value: VALUE)
        let config = try app.getResponse(to: "/remoteconfigs", method: .POST, data: data, decodeTo: RemoteConfig.self)
        XCTAssert(config.key == KEY && config.value == VALUE, "Create Failed")
        self.cache = config
    }
    
    func testUpdate() throws {
        
        if cache == nil {
            try testCreate()
        }
        
        let UPDATED_VALUE = "UPDATED_VALUE"
        
        let data = cache!
        data.value = UPDATED_VALUE
        let config = try app.getResponse(to: "/remoteconfigs/\(data.id!)", method: .PUT, data: data, decodeTo: RemoteConfig.self)
        XCTAssert(config.value == UPDATED_VALUE, "Update Value Failed")
        
        XCTAssert(data.updatedAt! < config.updatedAt!, "Update `updatedAt` Failed")
        
    }
    
}
