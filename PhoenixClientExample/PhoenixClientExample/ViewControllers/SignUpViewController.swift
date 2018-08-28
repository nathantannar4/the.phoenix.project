//
//  SignUpViewController.swift
//  RewardWallet
//
//  Created by Nathan Tannar on 3/6/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit

final class SignUpViewController: UIViewController {
    
    // MARK: - Properties
    
    private var registerButtonBottomAnchor: NSLayoutConstraint?
    private var titleLabelTopAnchor: NSLayoutConstraint?
    private var keyboardIsHidden: Bool = true
    
    // MARK: - Subviews
    
    private let titleLabel = UILabel(style: Stylesheet.Labels.title) {
        $0.text = "Sign Up"
        $0.textAlignment = .left
        $0.font = Stylesheet.titleFont.withSize(24)
    }
    
    private let subtitleLabel = UILabel(style: Stylesheet.Labels.subtitle) {
        $0.text = "We are happy to have you join us"
        $0.textAlignment = .left
        $0.font = Stylesheet.subtitleFont.withSize(18)
    }
    
    private let emailField = UIAnimatedTextField(style: Stylesheet.TextFields.email)
    private let emailIconView = UIImageView(style: Stylesheet.ImageViews.fitted) {
        $0.image = UIImage.iconEmail
    }
    
    private let nameField = UIAnimatedTextField(style: Stylesheet.TextFields.primary) {
        $0.placeholder = "First and Last Name"
    }
    private let nameIconView = UIImageView(style: Stylesheet.ImageViews.fitted) {
        $0.image = UIImage.iconPerson
    }
    
    private let phoneField = UIAnimatedTextField(style: Stylesheet.TextFields.phone)
    private let phoneIconView = UIImageView(style: Stylesheet.ImageViews.fitted) {
        $0.image = UIImage.iconPhone
    }
    
    private let passwordField = UIAnimatedTextField(style: Stylesheet.TextFields.password)
    private let passwordIconView = UIImageView(style: Stylesheet.ImageViews.fitted) {
        $0.image = UIImage.iconLock
    }
    
    private let confirmPasswordField = UIAnimatedTextField(style: Stylesheet.TextFields.password) {
        $0.placeholder = "Verify Password"
    }
    private let confirmPasswordIconView = UIImageView(style: Stylesheet.ImageViews.fitted) {
        $0.image = UIImage.iconCheckLock
    }
    
    private lazy var closeButton = UIButton(style: Stylesheet.Buttons.close) {
        $0.addTarget(self,
                     action: #selector(SignUpViewController.dismissViewController),
                     for: .touchUpInside)
    }
    
    private lazy var termsButton = UIButton(style: Stylesheet.Buttons.termsAndConditions) {
        $0.addTarget(self,
                     action: #selector(SignUpViewController.didTapTermsButton),
                     for: .touchUpInside)
    }
    
    private lazy var registerButton = RippleButton(style: Stylesheet.Buttons.primary) {
        $0.setTitle("REGISTER", for: .normal)
        $0.addTarget(self,
                     action: #selector(SignUpViewController.didTapRegister),
                     for: .touchUpInside)
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupView()
        registerObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController?.viewControllers.first != self {
            closeButton.isHidden = true
        } else {
            navigationController?.setNavigationBarHidden(true, animated: animated)
            titleLabelTopAnchor?.constant = titleLabelDefaultAnchorTopConstant()
            view.layoutIfNeeded()
        }
    }
    
    private func titleLabelDefaultAnchorTopConstant() -> CGFloat {
        if navigationController?.viewControllers.first == self {
            return 54
        } else {
            return 12
        }
    }
    
    // MARK: - Setup
    
    private func setupView() {
        
        view.backgroundColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(tapGesture)
        
        [closeButton, titleLabel, subtitleLabel, emailField, emailIconView, nameField, nameIconView, phoneField, phoneIconView, passwordField, passwordIconView, confirmPasswordField, confirmPasswordIconView, termsButton, registerButton].forEach { view.addSubview($0) }
        
        closeButton.anchor(view.layoutMarginsGuide.topAnchor, left: view.layoutMarginsGuide.leftAnchor, topConstant: 6, leftConstant: 6, widthConstant: 36, heightConstant: 36)
        
        titleLabelTopAnchor = titleLabel.anchor(view.layoutMarginsGuide.topAnchor, left: view.layoutMarginsGuide.leftAnchor, right: view.layoutMarginsGuide.rightAnchor, topConstant: 12, leftConstant: 12, rightConstant: 12, heightConstant: 25).first
        
        subtitleLabel.anchorBelow(titleLabel, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: 25)
        
        var lastView: UIView = subtitleLabel
        for subview in [emailField, emailIconView, nameField, nameIconView, phoneField, phoneIconView, passwordField, passwordIconView, confirmPasswordField, confirmPasswordIconView] {
            if subview is UIImageView {
                subview.anchorLeftOf(lastView, topConstant: 14, rightConstant: 8)
                subview.anchorAspectRatio()
            } else if subview is UITextField {
                let leftConstant: CGFloat = lastView == subtitleLabel ? (30 + 8) : 0
                subview.anchorBelow(lastView, topConstant: 12, leftConstant: leftConstant, heightConstant: 44)
                lastView = subview
            }
        }
        
        termsButton.anchorAbove(registerButton, heightConstant: 30)
        
        registerButtonBottomAnchor = registerButton.anchor(left: view.leftAnchor, bottom: view.layoutMarginsGuide.bottomAnchor, right: view.rightAnchor, heightConstant: 44)[1]
        
        // Keep space below login button red when raised with the keyboard
        let spacingRedView = UIView()
        spacingRedView.backgroundColor = .primaryColor
        view.addSubview(spacingRedView)
        spacingRedView.anchor(registerButton.bottomAnchor, left: registerButton.leftAnchor, bottom: view.bottomAnchor, right: registerButton.rightAnchor)
        
    }
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(notification:)), name: .UIKeyboardDidChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - User Actions
    
    @objc
    private func didTapView() {
        view.endEditing(true)
    }
    
    @objc
    private func dismissViewController() {
        if navigationController?.popViewController(animated: true) == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc
    private func didTapTermsButton() {
        
    }
    
    @objc
    private func didTapRegister() {
        
        didTapView()
        
        guard let email = emailField.text, let password = passwordField.text, let verifyPassword = confirmPasswordField.text else { return }
        guard password == verifyPassword else { return }
        
        let auth = Auth(username: email, password: password, email: email)
        Network.request(.signUp(auth), decodeAs: User.self)
            .then { _ in
                Network.request(.login(auth))
            }.then { [weak self] _ in
                let conversationVC = ConversationsViewController()
                let navVC = UINavigationController(rootViewController: conversationVC)
                self?.present(navVC, animated: true, completion: nil)
            }.catch { [weak self] error in
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - Keyboard Observer
    
    @objc
    private func keyboardDidChangeFrame(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, !keyboardIsHidden, let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            guard let constant = self.registerButtonBottomAnchor?.constant else { return }
            guard keyboardSize.height <= constant else { return }
            UIView.animate(withDuration: TimeInterval(truncating: duration), animations: { () -> Void in
                self.registerButtonBottomAnchor?.constant = -keyboardSize.height + self.view.layoutMargins.bottom
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        keyboardIsHidden = false
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            UIView.animate(withDuration: TimeInterval(truncating: duration), animations: { () -> Void in
                self.registerButtonBottomAnchor?.constant = -keyboardSize.height + self.view.layoutMargins.bottom
                self.titleLabelTopAnchor?.constant = -50
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification) {
        keyboardIsHidden = true
        if let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            UIView.animate(withDuration: TimeInterval(truncating: duration), animations: { () -> Void in
                self.registerButtonBottomAnchor?.constant = 0
                self.titleLabelTopAnchor?.constant = self.titleLabelDefaultAnchorTopConstant()
                self.view.layoutIfNeeded()
            })
        }
    }
    
}
