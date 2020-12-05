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

func setPlaceHolder(with text: String) -> NSAttributedString {
    return NSAttributedString(string: text,
                              attributes: [
                                NSAttributedString.Key.foregroundColor: UIColor.systemGray2
                              ])
}

/// Upload profile picture to Firebase 
public func uploadProfilePictureToFirebase(with data: Data, fileName: String) {
    StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
        switch result {
        case .success(let downloadURL):
            UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
            print(downloadURL)
        case .failure(let error):
            print("Storage manager error: \(error)")
        }
    })
}

public func saveToUserDefault(forValue value: Any, withKey key: String) {
    return UserDefaults.standard.setValue(value, forKey: key)
}
