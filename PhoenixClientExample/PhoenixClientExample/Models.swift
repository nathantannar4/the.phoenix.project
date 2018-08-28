//
//  User..swift
//  PhoenixClientExample
//
//  Created by Nathan Tannar on 2018-08-21.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import Foundation

struct Auth: Encodable {
    let username: String
    let password: String
    let email: String?
}

struct User: Codable {
    let id: String
    var createdAt: Date
    var updatedAt: Date
    let username: String
    var email: String
    var isEmailVerified: Bool
    var image: Image?
}

struct Image: Codable {
    let publicURL: URL
    let filename: String
}

struct Message: Codable {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let text: String
    let user: User
}

struct ConnectedUser: Codable {
    let userId: String
    let updatedAt: Date
}

struct Conversation: Codable {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let users: [User]
    let connectedUsers: [ConnectedUser]
    let lastMessage: Message?
}

struct BearerToken: Decodable {
    let value: String
    let createdAt: Date
    let expiresAt: Date
}


