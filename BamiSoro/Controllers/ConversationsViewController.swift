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
        view.backgroundColor = .systemRed
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
     
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let viewController = LoginViewController()
            let navigation = UINavigationController(rootViewController: viewController)
            navigation.modalPresentationStyle = .fullScreen
            present(navigation, animated: false)
        }
    }

}

