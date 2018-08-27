//
//  ImageController.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-18.
//

import Vapor
import Crypto

final class FileController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let groupedRoutes = router.grouped(FileRecord.path)
        groupedRoutes.get(FileRecord.parameter, use: download)
        
        groupedRoutes.group(SecretMiddleware.self) { protectedRouter in
            
            let tokenAuthMiddleware = User.tokenAuthMiddleware()
            let guardAuthMiddleware = User.guardAuthMiddleware()
            let tokenAuthGroup = protectedRouter.grouped(tokenAuthMiddleware, guardAuthMiddleware)
            tokenAuthGroup.post(use: recieve)
            
        }
        
    }
    
    static func upload(_ req: Request) throws -> Future<FileRecord> {
        return try req.content.decode(File.self).flatMap(to: FileRecord.self) { file in
            
            let workDir = DirectoryConfig.detect().workDir
            let fileStorage = Environment.STORAGE_PATH.convertToPathComponents().readable + "/" + (file.ext ?? "other")
            let path = URL(fileURLWithPath: workDir).appendingPathComponent(fileStorage, isDirectory: true)
            if !FileManager.default.fileExists(atPath: path.absoluteString) {
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            }
            let key = try CryptoRandom().generateData(count: 16).base64URLEncodedString()
            let encodedFilename = key + "." + (file.ext ?? "")
            let writePath = path.appendingPathComponent(encodedFilename, isDirectory: false)
            try file.data.write(to: writePath, options: .withoutOverwriting)
            let localPath = fileStorage + "/" + encodedFilename
            return FileRecord(filename: file.filename, fileKind: file.ext, localPath: localPath).save(on: req)
        }
    }
    
    func recieve(_ req: Request) throws -> Future<FileRecord.Public> {
        return try FileController.upload(req).mapToPublic()
    }
    
    func download(_ req: Request) throws -> Future<Response> {
        
        return try req.parameters.next(FileRecord.self).flatMap(to: Response.self) { record in
            
            let workDir = DirectoryConfig.detect().workDir
            let filePath = workDir + record.localPath
            
            var isDir: ObjCBool = false
            guard FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir), !isDir.boolValue else {
                throw Abort(.notFound)
            }
            return try req.streamFile(at: filePath)
        }.catchMap { _ in
            throw Abort(.notFound)
        }
    }
    
}
