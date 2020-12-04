//
//  Extension+UITextField.swift
//  BamiSoro
//
//  Created by waheedCodes on 04/12/2020.
//

import Foundation
import UIKit

extension UITextField {
    func disableAutoFill() {
        if #available(iOS 12, *) {
            textContentType = .oneTimeCode
        } else {
            textContentType = .init(rawValue: "")
        }
    }
}
