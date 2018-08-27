//
//  RemoteConfigController.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-17.
//

import Vapor

final class RemoteConfigController: RouteCollection {
    
    public func boot(router: Router) throws {
        
        router.group(SecretMiddleware.self) { protectedRouter in
            
            let groupedRoutes = protectedRouter.grouped(RemoteConfig.path)
            groupedRoutes.get(use: list)
            groupedRoutes.get(RemoteConfig.parameter, use: index)
            groupedRoutes.post(use: create)
            groupedRoutes.put(RemoteConfig.parameter, use: update)
            groupedRoutes.delete(RemoteConfig.parameter, use: delete)
        }
        
    }
    
    func list(_ req: Request) throws -> Future<[RemoteConfig.Public]> {
        return RemoteConfig.query(on: req).sort(\.createdAt).all().flatMap(to: [RemoteConfig.Public].self) { configs in
            return configs.map { config in
                Future.map(on: req) { config }.mapToPublic()
            }.flatten(on: req)
        }
    }
    
    func index(_ req: Request) throws -> Future<RemoteConfig.Public> {
        return try req.parameters.next(RemoteConfig.self).mapToPublic()
    }
    
    func create(_ req: Request) throws -> Future<RemoteConfig.Public> {
        return try req.content.decode(RemoteConfig.self).save(on: req).mapToPublic()
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(RemoteConfig.self).delete(on: req).transform(to: .ok)
    }
    
    func update(_ req: Request) throws -> Future<RemoteConfig.Public> {
        return try flatMap(to: RemoteConfig.Public.self, req.parameters.next(RemoteConfig.self), req.content.decode(RemoteConfig.self), { model, updatedModel in
            model.key = updatedModel.key
            model.value = updatedModel.value
            return model.update(on: req).mapToPublic()
        })
    }
    
}
