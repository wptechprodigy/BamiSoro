//
//  Helpers.swift
//  BamiSoro
//
//  Created by waheedCodes on 23/11/2020.
//

import UIKit

func presentLoginScreen() -> UINavigationController {
    let viewController = LoginViewController()
    let navigation = UINavigationController(rootViewController: viewController)
    navigation.modalPresentationStyle = .fullScreen
    return navigation
}
