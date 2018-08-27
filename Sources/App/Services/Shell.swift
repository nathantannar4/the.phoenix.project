//
//  Shell.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-22.
//

import Vapor

final class Shell: Service {
    
    private var worker: Container
    
    // MARK: - Initialization
    
    public init(worker: Container) throws{
        self.worker = worker
    }
    
    // MARK: - Public
    
    func execute(commandName: String, arguments: [String] = []) throws -> Future<Data> {
        return try bash(commandName: commandName, arguments:arguments)
    }
    
    // MARK: - Private
    
    private func bash(commandName: String, arguments: [String]) throws -> Future<Data> {
        
        return executeShell(command: "/bin/bash" , arguments:[ "-l", "-c", "which \(commandName)" ])
            .map(to: String.self) { data in
                guard let commandPath = String(data: data, encoding: .utf8) else {
                    throw Abort(.internalServerError)
                }
                return commandPath.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            }.flatMap(to: Data.self) { path in
                return self.executeShell(command: path, arguments: arguments)
        }
    }
    
    private func executeShell(command: String, arguments: [String] = []) -> Future<Data> {
        
        return Future.map(on: worker) {
            
            let process = Process()
            process.launchPath = command
            process.arguments = arguments
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.launch()
            
            return pipe.fileHandleForReading.readDataToEndOfFile()
        }
    }
    
}

extension Shell: ServiceType {
    
    public static func makeService(for worker: Container) throws -> Shell {
        return try Shell(worker: worker)
    }
    
}

