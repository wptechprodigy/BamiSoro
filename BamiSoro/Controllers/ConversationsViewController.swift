//
//  ViewController.swift
//  BamiSoro
//
//  Created by waheedCodes on 06/11/2020.
//

import UIKit

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemRed
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isLoggedIn = UserDefaults.standard.bool(forKey: LoginConstant.isLoggedIn)
        
        if !isLoggedIn {
            let viewController = LoginViewController()
            let navigation = UINavigationController(rootViewController: viewController)
            navigation.modalPresentationStyle = .fullScreen
            present(navigation, animated: false)
        }
        
    }

}

