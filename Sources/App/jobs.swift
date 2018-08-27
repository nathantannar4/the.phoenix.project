import Vapor
import Schedule

/// Register your application's scheduled jobs here.
public func jobs(_ app: Application) throws {
    
    Schedule.every(.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday).at("21:00").do {
        // Do some nightly task at 9pm
    }
}
