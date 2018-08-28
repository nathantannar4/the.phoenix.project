//
//  LoginViewController.swift
//  RewardWallet
//
//  Created by Nathan Tannar on 3/6/18.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private var loginButtonBottomAnchor: NSLayoutConstraint?
    private var keyboardIsHidden: Bool = true
    
    // MARK: - Subviews
    
    private let titleLabel = UILabel(style: Stylesheet.Labels.title) {
        $0.text = "Welcome Back"
        $0.textAlignment = .left
    }
    
    private let subtitleLabel = UILabel(style: Stylesheet.Labels.subtitle) {
        $0.text = "Please sign in to continue"
        $0.textAlignment = .left
    }
    
    private let emailField = UIAnimatedTextField(style: Stylesheet.TextFields.email)
    private let emailIconView = UIImageView(style: Stylesheet.ImageViews.fitted) {
        $0.image = UIImage.iconEmail
    }
    
    private let passwordField = UIAnimatedTextField(style: Stylesheet.TextFields.password)
    private let passwordIconView = UIImageView(style: Stylesheet.ImageViews.fitted) {
        $0.image = UIImage.iconLock
    }
    
    private lazy var closeButton = UIButton(style: Stylesheet.Buttons.close) {
        $0.addTarget(self,
                     action: #selector(LoginViewController.dismissViewController),
                     for: .touchUpInside)
    }
    
    private lazy var forgotPasswordButton = UIButton(style: Stylesheet.Buttons.regular) {
        $0.setTitle("Forgot Password?", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        $0.contentHorizontalAlignment = .center
        $0.addTarget(self,
                     action: #selector(LoginViewController.didTapForgotPassword),
                     for: .touchUpInside)
    }
    
    private lazy var termsButton = UIButton(style: Stylesheet.Buttons.termsAndConditions) {
        $0.addTarget(self,
                     action: #selector(LoginViewController.didTapTermsButton),
                     for: .touchUpInside)
    }
    
    private lazy var loginButton = RippleButton(style: Stylesheet.Buttons.primary) {
        $0.setTitle("LOGIN", for: .normal)
        $0.addTarget(self,
                     action: #selector(LoginViewController.didTapLogin),
                     for: .touchUpInside)
    }
    
    private lazy var facebookLoginButton = UIButton(style: Stylesheet.Buttons.facebook) {
        $0.addTarget(self,
                     action: #selector(LoginViewController.didTapFacebookLogin),
                     for: .touchUpInside)
    }
    
    private lazy var googleLoginButton = UIButton(style: Stylesheet.Buttons.google) {
        $0.addTarget(self,
                     action: #selector(LoginViewController.didTapGoogleLogin),
                     for: .touchUpInside)
    }
    
    private lazy var signUpButton: UIButton = { [weak self] in
        let button = UIButton(style: Stylesheet.Buttons.regular)
        let normalTitle = NSMutableAttributedString().normal("Don't have an account? ", font: Stylesheet.buttonFont, color: .darkGray).bold("Sign up here", size: 14, color: .primaryColor)
        let highlightedTitle = NSMutableAttributedString().normal("Don't have an account? ", font: Stylesheet.buttonFont, color: UIColor.darkGray.withAlphaComponent(0.3)).bold("Sign up here", size: 14, color: UIColor.primaryColor.withAlphaComponent(0.3))
        button.setAttributedTitle(normalTitle, for: .normal)
        button.setAttributedTitle(highlightedTitle, for: .highlighted)
        button.addTarget(self,
                         action: #selector(LoginViewController.didTapSignUp),
                         for: .touchUpInside)
        button.contentHorizontalAlignment = .center
        return button
    }()

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissViewController))
        registerObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // If pushing a UIViewController onto the stack, unhide the UINavigationBar
        guard (navigationController?.viewControllers.count ?? 1) > 1 else { return }
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupView() {
        
        view.backgroundColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(tapGesture)
        
        [closeButton, titleLabel, subtitleLabel, emailIconView, emailField, passwordField, passwordIconView, forgotPasswordButton, termsButton, signUpButton, facebookLoginButton, googleLoginButton, loginButton].forEach { view.addSubview($0) }
        
        closeButton.anchor(view.layoutMarginsGuide.topAnchor, left: view.layoutMarginsGuide.leftAnchor, topConstant: 6, leftConstant: 6, widthConstant: 36, heightConstant: 36)
        
        titleLabel.anchor(view.layoutMarginsGuide.topAnchor, left: view.layoutMarginsGuide.leftAnchor, right: view.layoutMarginsGuide.rightAnchor, topConstant: 50, leftConstant: 12, rightConstant: 12, heightConstant: 40)
        
        subtitleLabel.anchorBelow(titleLabel, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, heightConstant: 30)

        emailField.anchor(titleLabel.bottomAnchor, left: view.layoutMarginsGuide.leftAnchor, bottom: nil, right: view.layoutMarginsGuide.rightAnchor, topConstant: 75, leftConstant: 12 + 30 + 8, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 50)
        
        emailIconView.anchorLeftOf(emailField, topConstant: 20, bottomConstant: 0, rightConstant: 8)
        emailIconView.anchorAspectRatio()
        
        passwordField.anchorBelow(emailField, bottom: nil, topConstant: 16, bottomConstant: 0, heightConstant: 50)
        
        passwordIconView.anchorLeftOf(passwordField, topConstant: 20, bottomConstant: 0, rightConstant: 8)
        passwordIconView.anchorAspectRatio()
        
        forgotPasswordButton.anchorCenterXToSuperview()
        forgotPasswordButton.anchor(passwordField.bottomAnchor,topConstant: 12, heightConstant: 15)
        
        termsButton.anchorAbove(loginButton, heightConstant: 30)
        
        loginButtonBottomAnchor = loginButton.anchor(left: view.leftAnchor, bottom: facebookLoginButton.topAnchor, right: view.rightAnchor, heightConstant: 44)[1]
        
        // Keep space below login button red when raised with the keyboard
        let spacingRedView = UIView()
        spacingRedView.backgroundColor = .primaryColor
        view.addSubview(spacingRedView)
        spacingRedView.anchor(loginButton.bottomAnchor, left: loginButton.leftAnchor, bottom: facebookLoginButton.topAnchor, right: loginButton.rightAnchor)
        
        facebookLoginButton.anchor(left: view.leftAnchor, bottom: signUpButton.topAnchor, right: googleLoginButton.leftAnchor, heightConstant: 44)
        
        googleLoginButton.anchor(left: facebookLoginButton.rightAnchor, bottom: signUpButton.topAnchor, right: view.rightAnchor, heightConstant: 44)
        googleLoginButton.anchorWidthToItem(facebookLoginButton)
        
        signUpButton.anchor(left: view.leftAnchor, bottom: view.layoutMarginsGuide.bottomAnchor, right: view.rightAnchor, heightConstant: 44)
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
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func didTapForgotPassword() {
        
    }
    
    @objc
    private func didTapTermsButton() {
        
    }
    
    @objc
    private func didTapLogin() {
        
        didTapView()
        
        guard let email = emailField.text, let password = passwordField.text else { return }
        
        let auth = Auth(username: email, password: password, email: email)
        Network.request(.login(auth))
            .then { [weak self] _ in
                let conversationVC = ConversationsViewController()
                let navVC = UINavigationController(rootViewController: conversationVC)
                self?.present(navVC, animated: true, completion: nil)
            }.catch { [weak self] error in
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc
    private func didTapFacebookLogin() {
        
    }
    
    @objc
    private func didTapGoogleLogin() {
        
    }
    
    @objc
    private func didTapSignUp() {
        navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
    
    // MARK: - Keyboard Observer
    
    @objc
    private func keyboardDidChangeFrame(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, !keyboardIsHidden, let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            guard let constant = self.loginButtonBottomAnchor?.constant else { return }
            guard keyboardSize.height <= constant else { return }
            UIView.animate(withDuration: TimeInterval(truncating: duration), animations: { () -> Void in
                self.loginButtonBottomAnchor?.constant = -keyboardSize.height + self.view.layoutMargins.bottom + self.signUpButton.bounds.height + self.facebookLoginButton.bounds.height
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        keyboardIsHidden = false
        guard emailField.isFirstResponder || passwordField.isFirstResponder else { return }
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            UIView.animate(withDuration: TimeInterval(truncating: duration), animations: { () -> Void in
                self.loginButtonBottomAnchor?.constant = -keyboardSize.height + self.view.layoutMargins.bottom + self.signUpButton.bounds.height + self.facebookLoginButton.bounds.height
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification) {
        keyboardIsHidden = true
        if let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            UIView.animate(withDuration: TimeInterval(truncating: duration), animations: { () -> Void in
                self.loginButtonBottomAnchor?.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
}
