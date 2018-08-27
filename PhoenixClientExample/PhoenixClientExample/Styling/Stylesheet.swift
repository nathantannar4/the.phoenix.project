//
//  AppRouter.swift
//  RewardWallet
//
//  Created by Nathan Tannar on 2/5/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit

enum Stylesheet {
    
    static var titleFont: UIFont {
        return .boldSystemFont(ofSize: 34)
    }
    
    static var subtitleFont: UIFont {
        return .systemFont(ofSize: 28, weight: .semibold)
    }
    
    static var headerFont: UIFont {
        return .systemFont(ofSize: 16, weight: .medium)
    }
    
    static var subheaderFont: UIFont {
        return .systemFont(ofSize: 14, weight: .medium)
    }
    
    static var descriptionFont: UIFont {
        return .systemFont(ofSize: 14, weight: .regular)
    }
    
    static var buttonFont: UIFont {
        return .systemFont(ofSize: 14, weight: .regular)
    }
    
    static var captionFont: UIFont {
        return .systemFont(ofSize: 13)
    }
    
    static var footnoteFont: UIFont {
        return .systemFont(ofSize: 12, weight: .medium)
    }
    
    enum Labels {
        
        static let title = Style<UILabel> {
            $0.font = titleFont
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.adjustsFontSizeToFitWidth = true
        }
        
        static let subtitle = Style<UILabel> {
            $0.font = subtitleFont
            $0.textColor = .darkGray
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.adjustsFontSizeToFitWidth = true
        }
        
        static let header = Style<UILabel> {
            $0.font = headerFont
            $0.numberOfLines = 0
            $0.textAlignment = .left
            $0.adjustsFontSizeToFitWidth = true
        }
        
        static let subheader = Style<UILabel> {
            $0.font = subheaderFont
            $0.textColor = .darkGray
            $0.numberOfLines = 0
            $0.textAlignment = .left
            $0.adjustsFontSizeToFitWidth = true
        }
        
        static let light = Style<UILabel> {
            $0.font = UIFont.systemFont(ofSize: 28, weight: .light)
            $0.textColor = .black
            $0.numberOfLines = 0
            $0.adjustsFontSizeToFitWidth = true
        }
        
        static let description = Style<UILabel> {
            $0.font = descriptionFont
            $0.textColor = .black
            $0.numberOfLines = 0
            $0.adjustsFontSizeToFitWidth = true
        }
        
        static let address = Style<UILabel> {
            $0.font = descriptionFont.withSize(12)
            $0.textColor = .darkGray
            $0.numberOfLines = 0
            $0.adjustsFontSizeToFitWidth = true
        }
        
        static let caption = Style<UILabel> {
            $0.font = captionFont
            $0.textColor = .darkGray
            $0.numberOfLines = 0
            $0.adjustsFontSizeToFitWidth = true
        }
        
        static let footnote = Style<UILabel> {
            $0.font = footnoteFont
            $0.textColor = .darkGray
            $0.numberOfLines = 0
            $0.adjustsFontSizeToFitWidth = true
        }
        
    }
    
    enum Views {
        
        static let rounded = Style<UIView> {
            $0.layer.cornerRadius = 8
        }
        
        static let lightlyShadowed = Style<UIView> {
            $0.layer.shadowColor = UIColor.shadowColor.cgColor
            $0.layer.shadowOpacity = 0.2
            $0.layer.shadowRadius = 2
            $0.layer.shadowOffset = CGSize(width: 0, height: 0)
        }
        
        static let shadowed = Style<UIView> {
            $0.layer.shadowColor = UIColor.shadowColor.cgColor
            $0.layer.shadowOpacity = 0.5
            $0.layer.shadowRadius = 3
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        }
        
        static let roundedShadowed = Style<UIView> {
            $0.apply(Stylesheet.Views.shadowed)
            $0.apply(Stylesheet.Views.rounded)
        }
        
        static let roundedLightlyShadowed = Style<UIView> {
            $0.apply(Stylesheet.Views.lightlyShadowed)
            $0.apply(Stylesheet.Views.rounded)
        }
        
        static let farShadowed = Style<UIView> {
            $0.layer.shadowRadius = 5
            $0.layer.shadowOpacity = 0.3
            $0.layer.shadowColor = UIColor.lightGray.cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
    }
    
    enum ImageViews {
        
        static let fitted = Style<UIImageView> {
            $0.tintColor = .grayColor
            $0.contentMode = .scaleAspectFit
        }
        
        static let filled = Style<UIImageView> {
            $0.tintColor = .offWhite
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = .backgroundColor
            $0.clipsToBounds = true
        }
        
        static let roundedSquare = Style<UIImageView> {
            $0.tintColor = .offWhite
            $0.apply(Stylesheet.Views.rounded)
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = .backgroundColor
        }
    }
    
    enum NavigationBars {
        
        static let primary = Style<UINavigationBar> {
            $0.barTintColor = .primaryColor
            $0.tintColor = .white
            $0.barStyle = .black
            $0.isTranslucent = false
            $0.shadowImage = UIImage()
        }
        
        static let inversePrimary = Style<UINavigationBar> {
            $0.barTintColor = .white
            $0.tintColor = .primaryColor
            $0.barStyle = .default
            $0.isTranslucent = false
            $0.shadowImage = UIImage()
        }
        
        static let clear = Style<UINavigationBar> {
            $0.barTintColor = .white
            $0.tintColor = .primaryColor
            $0.barStyle = .default
            $0.isTranslucent = true
            $0.shadowImage = UIImage()
        }
    }
    
    enum Buttons {
        
        static let regular = Style<UIButton> {
            $0.titleLabel?.font = buttonFont
            $0.titleLabel?.numberOfLines = 0
            $0.titleLabel?.textAlignment = .center
            $0.imageView?.tintColor = .gray
            $0.imageView?.contentMode = .scaleAspectFit
            $0.setTitleColor(UIColor.darkGray, for: .normal)
            $0.setTitleColor(UIColor.darkGray.withAlphaComponent(0.3), for: .highlighted)
        }
        
        static let primary = Style<UIButton> {
            $0.apply(Stylesheet.Buttons.regular)
            $0.backgroundColor = .primaryColor
            let titleColor: UIColor = UIColor.primaryColor.isLight ? .black : .white
            $0.imageView?.tintColor = titleColor
            $0.setTitleColor(titleColor, for: .normal)
            $0.setTitleColor(titleColor.withAlphaComponent(0.3), for: .highlighted)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
        }
        
        static let secondary = Style<UIButton> {
            $0.apply(Stylesheet.Buttons.regular)
            $0.backgroundColor = .secondaryColor
            let titleColor: UIColor = UIColor.secondaryColor.isLight ? .black : .white
            $0.imageView?.tintColor = titleColor
            $0.setTitleColor(titleColor, for: .normal)
            $0.setTitleColor(titleColor.withAlphaComponent(0.3), for: .highlighted)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
        }
        
        static let link = Style<UIButton> {
            $0.apply(Stylesheet.Buttons.regular)
            $0.contentHorizontalAlignment = .left
            let titleColor: UIColor = UIColor.primaryColor
            $0.imageView?.tintColor = titleColor
            $0.setTitleColor(titleColor, for: .normal)
            $0.setTitleColor(titleColor.withAlphaComponent(0.3), for: .highlighted)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
        }
        
        static let roundedWhite = Style<UIButton> {
            $0.apply(Stylesheet.Buttons.regular)
            $0.layer.cornerRadius = 22
            $0.backgroundColor = .white
            $0.setTitleColor(.black, for: .normal)
            $0.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: .highlighted)
        }
        
        static let close = Style<UIButton> {
            $0.setImage(.iconClose, for: .normal)
            $0.imageView?.apply(Stylesheet.ImageViews.fitted)
        }
        
        static let facebook = Style<UIButton> {
            let normalTitle = NSMutableAttributedString().normal("Connect with ", font: buttonFont.withSize(12), color: .white).bold("Facebook", size: 14, color: .white)
            let highlightedTitle = NSMutableAttributedString().normal("Connect with ", font: buttonFont.withSize(12), color: UIColor.white.withAlphaComponent(0.3)).bold("Facebook", size: 14, color: UIColor.white.withAlphaComponent(0.3))
            $0.setAttributedTitle(normalTitle, for: .normal)
            $0.setAttributedTitle(highlightedTitle, for: .highlighted)
            $0.contentHorizontalAlignment = .center
            $0.setImage(.facebookLogo, for: .normal)
            $0.imageView?.apply(Stylesheet.ImageViews.fitted)
            $0.imageView?.tintColor = .white
            $0.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            $0.titleEdgeInsets.left = 12
            $0.backgroundColor = .facebookBlue
        }
        
        static let google = Style<UIButton> {
            let normalTitle = NSMutableAttributedString().normal("Connect with ", font: buttonFont.withSize(12), color: .black).bold("Google", size: 14, color: .black)
            let highlightedTitle = NSMutableAttributedString().normal("Connect with ", font: buttonFont.withSize(12), color: UIColor.black.withAlphaComponent(0.3)).bold("Google", size: 14, color: UIColor.black.withAlphaComponent(0.3))
            $0.setAttributedTitle(normalTitle, for: .normal)
            $0.setAttributedTitle(highlightedTitle, for: .highlighted)
            $0.contentHorizontalAlignment = .center
            $0.setImage(.googleLogo, for: .normal)
            $0.imageView?.apply(Stylesheet.ImageViews.fitted)
            $0.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
            $0.titleEdgeInsets.left = 6
            $0.backgroundColor = .googleOffWhite
        }
        
        static let termsAndConditions = Style<UIButton> {
            let title = "By proceeding you agree to the "
            let normalTitle = NSMutableAttributedString().normal(title, font: Stylesheet.buttonFont.withSize(10), color: .black).bold("Terms of Use", size: 10, color: .primaryColor)
            let highlightedTitle = NSMutableAttributedString().normal(title, font: Stylesheet.buttonFont.withSize(10), color: UIColor.black.withAlphaComponent(0.3)).bold("Terms of Use", size: 10, color: UIColor.primaryColor.withAlphaComponent(0.3))
            $0.setAttributedTitle(normalTitle, for: .normal)
            $0.setAttributedTitle(highlightedTitle, for: .highlighted)
            $0.backgroundColor = .white
        }
        
    }
    
    enum RippleButtons {
        
        static let primary = Style<RippleButton> {
            $0.apply(Stylesheet.Buttons.primary)
        }
        
        static let secondary = Style<RippleButton> {
            $0.apply(Stylesheet.Buttons.secondary)
        }
        
        static let link = Style<RippleButton> {
            $0.apply(Stylesheet.Buttons.link)
        }
        
        static let roundedWhite = Style<RippleButton> {
            $0.apply(Stylesheet.Buttons.roundedWhite)
        }
        
    }
    
    enum TextViews {
        
        static let regular = Style<UITextView> {
            $0.tintColor = .primaryColor
            $0.font = Stylesheet.descriptionFont
        }
        
        static let nonEditable = Style<UITextView> {
            $0.apply(Stylesheet.TextViews.regular)
            $0.isEditable = false
        }
    }
    
    enum TextFields {
        
        static let primary = Style<UIAnimatedTextField> {
            $0.placeholderColor = .grayColor
            $0.borderActiveColor = .primaryColor
            $0.borderInactiveColor = .grayColor
            $0.tintColor = .primaryColor
            $0.isSecureTextEntry = false
            $0.autocorrectionType = .default
            $0.clearButtonMode = .whileEditing
        }
        
        static let search = Style<UIAnimatedTextField> {
            $0.apply(Stylesheet.TextFields.primary)
            $0.tintColor = .primaryColor
            $0.isSecureTextEntry = false
            $0.autocorrectionType = .default
            $0.clearButtonMode = .whileEditing
            $0.placeholder = "Search"
        }
        
        static let email = Style<UIAnimatedTextField> {
            $0.apply(Stylesheet.TextFields.primary)
            $0.placeholder = "Email"
            $0.autocapitalizationType = .none
            $0.keyboardType = .emailAddress
            $0.autocorrectionType = .no
        }
        
        static let phone = Style<UIAnimatedTextField> {
            $0.placeholderColor = .grayColor
            $0.borderActiveColor = .primaryColor
            $0.borderInactiveColor = .grayColor
            $0.placeholder = "Phone Number"
            $0.keyboardType = .phonePad
            $0.autocorrectionType = .no
            $0.tintColor = .primaryColor
            $0.clearButtonMode = .whileEditing
        }
        
        static let password = Style<UIAnimatedTextField> {
            $0.apply(Stylesheet.TextFields.primary)
            $0.placeholder = "Password"
            $0.isSecureTextEntry = true
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .no
        }
        
    }
    
}
