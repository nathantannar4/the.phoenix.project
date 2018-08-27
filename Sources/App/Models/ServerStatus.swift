//
//  ServerStatus.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-22.
//

import Vapor

public struct ServerStatus: Content {
    
    let status: String
    let message: String
    
}
