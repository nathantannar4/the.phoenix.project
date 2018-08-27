//
//  CRUDModel.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-23.
//

import Vapor
import FluentMySQL
import Crypto

public typealias DatabaseType = MySQLDatabase

public typealias IDType = String

public protocol Object: Model, Parameter, Content, Migration where ID == IDType, Database == DatabaseType {
    
    // MARK: - Properties
    
    var id: ID? { get set }
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
    var deletedAt: Date? { get set }
    
    // MARK: - Fluent Keys
    
    static var idKey: WritableKeyPath<Self, ID?> { get }
    static var createdAtKey: TimestampKey? { get }
    static var updatedAtKey: TimestampKey? { get }
    static var deletedAtKey: TimestampKey? { get }
    
    // MARK: - Access Path
    
    static var path: [PathComponentsRepresentable] { get }
    
}


extension Object {
    
    // MARK: - Default Key Paths
    
    public static var idKey: WritableKeyPath<Self, ID?> {
        return \Self.id
    }
    
    public static var createdAtKey: TimestampKey? {
        return \Self.createdAt
    }
    
    public static var updatedAtKey: TimestampKey? {
        return \Self.updatedAt
    }
    
    public static var deletedAtKey: TimestampKey? {
        return \Self.deletedAt
    }
    
    // MARK: - Default Path
    
    public static var path: [PathComponentsRepresentable] {
        return [String(describing: Self.self).lowercased() + "s"]
    }
    
}


extension Object {
    
    // MARK: - Default Lifecycle
    
    public func willCreate(on conn: Database.Connection) throws -> EventLoopFuture<Self> {
        try setDefaultCreateProperties(on: conn)
        return conn.future(self)
    }
    
    public func setDefaultCreateProperties(on conn: Database.Connection) throws {
        var this = self
        this.id = String.randomAlphanumeric(ofLength: 10)
        this.createdAt = Date()
        this.updatedAt = Date()
    }
    
    public func willUpdate(on conn: Database.Connection) throws -> EventLoopFuture<Self> {
        try setDefaultUpdateProperties(on: conn)
        return conn.future(self)
    }
    
    public func setDefaultUpdateProperties(on conn: Database.Connection) throws {
        var this = self
        this.updatedAt = Date()
    }
    
}
