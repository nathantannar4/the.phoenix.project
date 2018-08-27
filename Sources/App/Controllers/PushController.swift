//
//  PushController.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-22.
//

import Vapor
import FluentSQL

final class PushController: RouteCollection {
    
    public final class PushContent: Content {
        let payload: APNSPayload
        let users: [User.ID]
    }
    
    func boot(router: Router) throws {
        
        router.group(SecretMiddleware.self) { protectedRouter in
            
            let groupedRouter = router.grouped(PushRecord.path)
            
            let tokenAuthMiddleware = User.tokenAuthMiddleware()
            let guardAuthMiddleware = User.guardAuthMiddleware()
            let tokenAuthGroup = groupedRouter.grouped(tokenAuthMiddleware, guardAuthMiddleware)
            
            tokenAuthGroup.post(use: push)
            tokenAuthGroup.post(User.parameter, use: pushToUser)
            
        }
        
    }
    
    func pushToUser(_ req: Request) throws -> Future<[PushRecord.Public]> {
        
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        
        return try flatMap(to: [PushRecord.Public].self,
                           req.content.decode(APNSPayload.self),
                           req.parameters.next(User.self)) { payload, toUser in
            
            return try toUser.installations.query(on: req).all().flatMap(to: [PushRecord.Public].self) { installations in
                    
                return try installations.compactMap { installation in
                    try self.pushToDeviceToken(installation.deviceToken, payload, byUser: user.requireID(), req)
                }.flatten(on: req)
            }
        }
        
    }
    
    func push(_ req: Request) throws -> Future<[PushRecord.Public]> {
        
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        
        return try req.content.decode(PushContent.self).flatMap(to: [PushRecord.Public].self) { content in
            
            return Installation.query(on: req).filter(\.userId ~~ content.users).all().flatMap(to: [PushRecord.Public].self) { installations in
                    
                return try installations.compactMap { installation in
                    try self.pushToDeviceToken(installation.deviceToken, content.payload, byUser: user.requireID(), req)
                }.flatten(on: req)
            }
            
        }
    
    }
    
    func pushToDeviceToken(_ token: String, _ payload: APNSPayload, byUser: User.ID, _ req: Request) throws -> Future<PushRecord.Public> {
        
        let shell = try req.make(Shell.self)
        
        let workDir = DirectoryConfig.detect().workDir
        let certURL: URL
        let apnsURL: String
        let password: String
        
        if req.environment.isRelease {
            let filePath = Environment.PUSH_CERTIFICATE_PATH.convertToPathComponents().readable
            guard let path = URL(string: workDir)?.appendingPathComponent(filePath) else {
                throw Abort(.custom(code: 512, reasonPhrase: "APNS push certificate not found"))
            }
            guard let certPwd = Environment.PUSH_CERTIFICATE_PWD else {
                throw Abort(.custom(code: 512, reasonPhrase: "No $PUSH_CERTIFICATE_PWD set on environment. Use `export PUSH_CERTIFICATE_PWD=<password>`"))
            }
            certURL = path
            apnsURL = "https://api.push.apple.com/3/device/"
            password = certPwd
        } else {
            let filePath = Environment.PUSH_DEV_CERTIFICATE_PATH.convertToPathComponents().readable
            guard let path = URL(string: workDir)?.appendingPathComponent(filePath) else {
                throw Abort(.custom(code: 512, reasonPhrase: "APNS development push certificate not found"))
            }
            guard let certPwd = Environment.PUSH_DEV_CERTIFICATE_PWD else {
                throw Abort(.custom(code: 512, reasonPhrase: "No $PUSH_DEV_CERTIFICATE_PWD set on environment. Use `export PUSH_DEV_CERTIFICATE_PWD=<password>`"))
            }
            certURL = path
            apnsURL = "https://api.development.push.apple.com/3/device/"
            password = certPwd
        }
        
        guard let bundleId = Environment.BUNDLE_IDENTIFIER else {
            throw Abort(.custom(code: 512, reasonPhrase: "No $BUNDLE_IDENTIFIER set on environment. Use `export BUNDLE_IDENTIFIER=<identifier>`"))
        }
        
        
        let certPath = certURL.absoluteString.replacingOccurrences(of: "file://", with: "")
        
        let content = APNSPayloadContent(payload: payload)
        let data = try JSONEncoder().encode(content)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw Abort(.custom(code: 512, reasonPhrase: "Invalid APNS payload"))
        }
        
        let arguments = ["-d", jsonString, "-H", "apns-topic:\(bundleId)", "-H", "apns-expiration: 1", "-H", "apns-priority: 10", "--http2-prior-knowledge", "--cert", "\(certPath):\(password)", apnsURL + token]
        
        
        return try shell.execute(commandName: "curl", arguments: arguments).flatMap(to: PushRecord.Public.self) { data in
            guard data.count != 0 else {
                let record = PushRecord(payload: payload, installationId: nil, status: .delivered, sentBy: byUser)
                return record.save(on: req).mapToPublic()
            }
            do {
                let decoder = JSONDecoder()
                let error = try decoder.decode(APNSError.self, from: data)
                let record = PushRecord(payload: payload, installationId: nil, error: error, sentBy: byUser)
                return record.save(on: req).mapToPublic()
            } catch _ {
                let record = PushRecord(payload: payload, installationId: nil, error: .unknown, sentBy: byUser)
                return record.save(on: req).mapToPublic()
            }
        }
        
    }
        
}
