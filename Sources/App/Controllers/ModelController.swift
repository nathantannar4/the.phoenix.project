import Vapor
import Fluent

open class ModelController<T:Object>: RouteCollection {
    
    open func boot(router: Router) throws {
        let groupedRoutes = router.grouped(T.path)
        groupedRoutes.get(use: list)
        groupedRoutes.get(T.parameter, use: index)
        groupedRoutes.post(use: create)
        groupedRoutes.put(T.parameter, use: update)
        groupedRoutes.delete(T.parameter, use: delete)
    }
    
    open func list(_ req: Request) throws -> Future<[T]> {
        return T.query(on: req).sort(\.createdAt).all()
    }
    
    open func index(_ req: Request) throws -> Future<T> {
        guard let future = try req.parameters.next(T.self) as? EventLoopFuture<T> else {
            throw Abort(.internalServerError)
        }
        return future
    }
    
    open func create(_ req: Request) throws -> Future<T> {
        return try req.content.decode(T.self).save(on: req)
    }
    
    open func delete(_ req: Request) throws -> Future<HTTPStatus> {
        guard let future = try req.parameters.next(T.self) as? EventLoopFuture<T> else {
            throw Abort(.notImplemented)
        }
        return future.delete(on: req).transform(to: .ok)
    }

    open func update(_ req: Request) throws -> Future<T> {
        guard let futureA = try req.parameters.next(T.self) as? EventLoopFuture<T> else {
            throw Abort(.internalServerError)
        }
        return try flatMap(to: T.self, futureA, req.content.decode(T.self), { model, updatedModel in
            // Update
            return model.update(on: req)
        })
    }
    
}

