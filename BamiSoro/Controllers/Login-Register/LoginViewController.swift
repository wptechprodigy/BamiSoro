//
//  LoginViewController.swift
//  BamiSoro
//
//  Created by waheedCodes on 07/11/2020.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAssetsConstant.logo)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.textColor = .darkGray
        field.attributedPlaceholder = setPlaceHolder(with: PlaceholderConstant.email)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        field.textColor = .darkGray
        field.attributedPlaceholder = setPlaceHolder(with: PlaceholderConstant.password)
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle(LoginConstant.loginTitle, for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let fbLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email" ,"public_profile"]
        return button
    }()
    
    private let googleLoginButton = GIDSignInButton()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Helps handle dismissing the google login since it's done in the appdelegate
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification,
                                                               object: nil,
                                                               queue: .main,
                                                               using: { [weak self] (_) in
                                                                guard let strongSelf = self else { return }
                                                                
                                                                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                                                               })
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        title = LoginConstant.loginTitle
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: RegisterConstant.register,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginButton.addTarget(self,
                              action: #selector(didTapLoginButton),
                              for: .touchUpInside)
        
        passwordField.delegate = self
        emailField.delegate = self
        
        fbLoginButton.delegate = self
        
        // Add subview
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(fbLoginButton)
        scrollView.addSubview(googleLoginButton)
    }
    
    // deinitializes the login observer to preempt memory leak
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: (scrollView.width - size) / 2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: (imageView.bottom + 40),
                                  width: (scrollView.width - 60),
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: (emailField.bottom + 10),
                                     width: (scrollView.width - 60),
                                     height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                   y: (passwordField.bottom + 10),
                                   width: (scrollView.width - 60),
                                   height: 52)
        
        fbLoginButton.frame = CGRect(x: 30,
                                     y: (loginButton.bottom + 10),
                                     width: (scrollView.width - 60),
                                     height: 52)
        
        googleLoginButton.frame = CGRect(x: 27,
                                         y: (fbLoginButton.bottom + 10),
                                         width: (scrollView.width - 56),
                                         height: 52)
    }
    
    @objc private func didTapLoginButton() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authDataResult, error) in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authDataResult, error == nil else {
                print(ErrorMessageConstant.loginUserErrorMessage + " \(email)")
                return
            }
            
            let user = result.user
            print("Logged in user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: ErrorMessageConstant.loginRegistrationErrorTitle,
                                      message: ErrorMessageConstant.loginErrorMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: ErrorMessageConstant.dismissError,
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let viewController = RegisterViewController()
        viewController.title = RegisterConstant.createAccount
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            didTapLoginButton()
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to login with Facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: FBGraphPath.graphPath,
                                                         parameters: ["fields": "email, name"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start { (_ graphRequestConnection, result, error) in
            guard let result = result as? [String: Any],
                  error == nil else {
                print("Failed to make the graph request.")
                return
            }
            
            guard
                let name = result["name"] as? String,
                let email = result["email"] as? String else {
                print("Failed to get name and email from FB")
                return
            }
            
            let nameComponents = name.components(separatedBy: " ")
            guard nameComponents.count == 2 else { return }
            
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    DatabaseManager.shared.insertUser(with: BamiSoroUser(firstName: firstName,
                                                                         lastName: lastName,
                                                                         email: email))
                }
            })
        }
        
        let userFBCredential = FacebookAuthProvider.credential(withAccessToken: token)
        
        FirebaseAuth.Auth.auth().signIn(with: userFBCredential) { [weak self] (authDataResult, error) in
            guard let strongSelf = self else { return }
            
            guard authDataResult != nil, error == nil else {
                if let error = error {
                    print("Facebook credentials login failed. MFA may be needed - \(error)")
                }
                return
            }
            
            strongSelf.navigationController?.dismiss(animated: true,
                                                     completion: nil)
        }
    }
    
    
}
