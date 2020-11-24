//
//  ViewController.swift
//  BamiSoro
//
//  Created by waheedCodes on 06/11/2020.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
     
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let loginNavigation = presentLoginScreen()
            present(loginNavigation, animated: true)
        }
    }

}

