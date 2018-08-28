import Vapor
@testable import App
import FluentMySQL
import XCTest

class AppTestCase: XCTestCase {
    
    var app: Application!
    
    override func setUp() {
        super.setUp()
        
//        try! Application.reset()
        app = try! Application.testable()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
}
