//
//  PasswordResetEmail.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-20.
//

import Vapor
import SendGrid

public struct EmailTemplates {
    
    static func passwordReset(to: EmailAddress, token: String) -> SendGridEmail {
        
        let from = EmailAddress(email: Environment.NO_REPLY_EMAIL, name: Environment.APP_NAME)
        let personalization = Personalization(to: [to])
        
        let header = "Password Reset for \(Environment.APP_NAME)"
        let link = "http://\(Environment.PUBLIC_URL)/auth/reset/password/\(token)"
        
        let html = "<h1>\(header)</h1><p>To reset your password, please visit <a href=\"\(link)\">this link</a></p></p>This link expires in 48 hours.</p>"
        let text = header + "\nTo reset your password, please visit " + link + "\n This link expires in 48 hours."
        
        return SendGridEmail(personalizations: [personalization], from: from, replyTo: from, subject: "Password Reset", content: [["type":"text/plain", "value": text], ["type":"text/html", "value": html]], sendAt: Date())
    }
    
    static func accountVerification(to: EmailAddress, token: String) -> SendGridEmail {
        
        let from = EmailAddress(email: Environment.NO_REPLY_EMAIL, name: Environment.APP_NAME)
        let personalization = Personalization(to: [to])
        
        let header = "Welcome To \(Environment.APP_NAME)"
        let link = "http://\(Environment.PUBLIC_URL)/auth/verify/email/\(token)"
        
        let html = "<h1>\(header)</h1><p>Please verify your email by visiting <a href=\"\(link)\">this link</a></p></p>This link expires in 48 hours.</p>"
        let text = header + "\nPlease verify your email by visiting " + link + "\n This link expires in 48 hours."
        
        return SendGridEmail(personalizations: [personalization], from: from, replyTo: from, subject: "Email Verification", content: [["type":"text/plain", "value": text], ["type":"text/html", "value": html]], sendAt: Date())
    }
    
}
