//
//  Environment+Extensions.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-19.
//

import Vapor

extension Environment {
    
    static var DATABASE_HOSTNAME: String {
        return Environment.get("DATABASE_HOSTNAME") ?? "127.0.0.1"
    }
    
    static var DATABASE_PORT: Int {
        return Int(Environment.get("DATABASE_PORT") ?? "3306") ?? -1
    }
    
    static var DATABASE_USER: String {
        return Environment.get("DATABASE_USER") ?? "root"
    }
    
    static var DATABASE_PASSWORD: String {
        return Environment.get("DATABASE_PASSWORD") ?? "root"
    }
    
    static var DATABASE_DB: String {
        return Environment.get("DATABASE_DB") ?? "vapor"
    }
    
    static var SENDGRID_API_KEY: String? {
        return Environment.get("SENDGRID_API_KEY")
    }
    
    static var APP_NAME: String {
        return Environment.get("APP_NAME") ?? "Phoenix App"
    }
    
    static var PUBLIC_URL: String {
        return Environment.get("PUBLIC_URL") ?? "127.0.0.1:\(PORT)"
    }
    
    static var PORT: Int {
        return Int(Environment.get("PORT") ?? "8000") ?? -1
    }
    
    static var X_API_KEY: String? {
        return Environment.get("X-API-KEY") ?? "myApiKey"
    }
    
    static var NO_REPLY_EMAIL: String? {
        return Environment.get("NO_REPLY_EMAIL") ?? "no-reply@phoenix.io"
    }
    
    static var MOUNT: String? {
        return Environment.get("MOUNT")
    }
    
    static var STORAGE_PATH: [PathComponentsRepresentable] {
        return [Environment.get("STORAGE_PATH") ?? "Storage"]
    }
    
    static var PUSH_CERTIFICATE_PATH: [PathComponentsRepresentable] {
        guard let path = Environment.get("PUSH_CERTIFICATE_PATH") else {
            return ["Push","Certificates","aps.pem"]
        }
        return [path]
    }
    
    static var PUSH_CERTIFICATE_PWD: String? {
        return Environment.get("PUSH_CERTIFICATE_PWD") ?? "password"
    }
    
    static var PUSH_DEV_CERTIFICATE_PATH: [PathComponentsRepresentable] {
        guard let path = Environment.get("PUSH_DEV_CERTIFICATE_PATH") else {
            return ["Push","Certificates","aps_development.pem"]
        }
        return [path]
    }
    
    static var PUSH_DEV_CERTIFICATE_PWD: String? {
        return Environment.get("PUSH_DEV_CERTIFICATE_PWD") ?? "password"
    }
    
    static var BUNDLE_IDENTIFIER: String? {
        return Environment.get("BUNDLE_IDENTIFIER")
    }
    
    static var LOG_PATH: [PathComponentsRepresentable] {
        return [Environment.get("LOG_PATH") ?? "Logs"]
    }
    
}
