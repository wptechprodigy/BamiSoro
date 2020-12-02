//
//  AppDelegate.swift
//  BamiSoro
//
//  Created by waheedCodes on 06/11/2020.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance().handle(url)
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("Failed to sign in with Google: \(error)")
            }
            return
        }
        
        guard
            let email = user.profile.email,
            let firstName = user.profile.givenName,
            let lastName = user.profile.familyName else {
            return
        }
        
        // Does a user exists with the email?
        DatabaseManager.shared.userExists(with: email,
                                          completion: { exists in
                                            if !exists {
                                                DatabaseManager.shared.insertUser(with: BamiSoroUser(firstName: firstName,
                                                                                                     lastName: lastName,
                                                                                                     email: email))
                                            }
                                          })
        
        guard let authentication = user.authentication else {
            print("Missing auth object off from Google")
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credential) { (authDataResult, error) in
            guard authDataResult != nil, error == nil else {
                print("Google credentials login failed.")
                return
            }
            
            print("Successfully signed in with Google credentials.")
            NotificationCenter.default.post(name: .didLoginNotification, object: nil)
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google user was disconnected.")
    }
    
}


