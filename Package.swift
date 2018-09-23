// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Phoenix",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.1.0"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.1"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.1"),
        .package(url: "https://github.com/vapor/crypto.git", from: "3.2.0"),
        .package(url: "https://github.com/vapor-community/sendgrid-provider.git", from: "3.0.5"),
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.1"),
        .package(url: "https://github.com/jianstm/Schedule.git", from: "0.0.7"),
        .package(url: "https://github.com/google/promises.git", from: "1.2.3"),
        .package(url: "https://github.com/Moya/Moya.git", from: "11.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentMySQL", "Authentication", "Crypto", "SendGrid", "JWT", "Leaf", "Schedule"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "Moya", "Promises"])
    ]
)





