//
//  ObjectID.swift
//  App
//
//  Created by Nathan Tannar on 2018-07-29.
//

import Foundation

public extension String {
    
    static func randomAlphanumeric(ofLength len: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.utf8.count)
        var randomString = ""
        
        for _ in 0..<len {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
}
