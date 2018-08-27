//
//  AppRouter.swift
//  RewardWallet
//
//  Created by Nathan Tannar on 2/5/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var primaryColor: UIColor {
//        return .offWhite
//        return UIColor(hex: "795548")
        return UIColor(r: 39, g: 111, b: 251)
    }
    
    static var secondaryColor: UIColor {
//        return UIColor(hex: "8D6E63")
        return UIColor(r: 159, g: 65, b: 251)
    }
    
    static var tertiaryColor: UIColor {
        return .yellowColor
    }
    
    static var greenColor: UIColor {
        return UIColor(hex: "43A047") // Material Green 600
    }
    
    static var redColor: UIColor {
        return UIColor(hex: "D32F2F") // Material Red 700
    }
    
    static var grayColor: UIColor {
        return UIColor(hex: "9E9E9E") // Material Gray 500
    }
    
    static var shadowColor: UIColor {
        return UIColor(hex: "757575") // Material Gray 600
    }
    
    static var offWhite: UIColor {
        return UIColor(white: 0.96, alpha: 1)
    }
    
    static var orangeColor: UIColor {
        return UIColor(r: 245, g: 134, b: 49)
    }
    
    static var yellowColor: UIColor {
        return UIColor(r: 254, g: 201, b: 62)
    }
    
    static var backgroundColor: UIColor {
        return .white
    }
    
    static var facebookBlue: UIColor {
        return UIColor(hex: "3b5998")
    }
    
    static var googleOffWhite: UIColor {
        return UIColor(hex: "EEEEEE")
    }
    
}

extension UIImage {
    
    static var defaultRenderingMode: UIImageRenderingMode = .alwaysOriginal
    
    static var logo: UIImage? {
        return UIImage(named: "Logo")
    }
    
    static var logo_wireframe: UIImage? {
        return UIImage(named: "Logo-Wireframe")?.withRenderingMode(.alwaysTemplate)
    }
    
    static var coin: UIImage? {
        return UIImage(named: "Coin")
    }
    
    static var iconCoins: UIImage? {
        return UIImage(named: "Coins")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var coin_wireframe: UIImage? {
        return UIImage(named: "Coin-Wireframe")?.withRenderingMode(.alwaysTemplate)
    }
    
    static var icon_shop: UIImage? {
        return UIImage(named: "Shop")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var icon_user: UIImage? {
        return UIImage(named: "User")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var icon_logOut: UIImage? {
        return UIImage(named: "Logout")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var icon_wallet: UIImage? {
        return UIImage(named: "Bank Card Back Side")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var icon_about: UIImage? {
        return UIImage(named: "About")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var icon_bell: UIImage? {
        return UIImage(named: "Appointment Reminders")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var iconStar: UIImage? {
        return UIImage(named: "icon-star")
    }
    
    static var iconStarFilled: UIImage? {
        return UIImage(named: "icon-star-filled")
    }
    
    static var iconCollect: UIImage? {
        return UIImage(named: "POS Terminal")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var iconTransaction: UIImage? {
        return UIImage(named: "Check")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var iconBusinessDetails: UIImage? {
        return UIImage(named: "Agreement")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var iconNFC: UIImage? {
        return UIImage(named: "icon-nfc_sign")?.withRenderingMode(.alwaysTemplate)
    }
    
    static var facebookLogo: UIImage? {
        return UIImage(named: "facebook-letter")?.withRenderingMode(.alwaysTemplate)
    }
    
    static var googleLogo: UIImage? {
        return UIImage(named: "googleplus-letter")
    }
    
    static var iconClose: UIImage? {
        return UIImage(named: "icon_close")
    }
    
    static var iconEmail: UIImage? {
        return UIImage(named: "mail-icon")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var iconPerson: UIImage? {
        return UIImage(named: "person-icon")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var iconPhone: UIImage? {
        return UIImage(named: "phone-icon")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var iconLock: UIImage? {
        return UIImage(named: "lock-icon")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var iconCheckLock: UIImage? {
        return UIImage(named: "lock-check-icon")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var iconReview: UIImage? {
        return UIImage(named: "Search Property")?.withRenderingMode(defaultRenderingMode)
    }
    
    static var iconCoupons: UIImage? {
        return UIImage(named: "Check")?.withRenderingMode(defaultRenderingMode)
    }
    
}

