//
//  ProfileViewController.swift
//  BamiSoro
//
//  Created by waheedCodes on 07/11/2020.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    static let cellIdentifier = "profile"
    
    @IBOutlet var tableView: UITableView!
    
    let data = ["Log out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: ProfileViewController.cellIdentifier)
        tableView?.delegate = self
        tableView?.dataSource = self
    }
    
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.cellIdentifier,
                                                 for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .systemRed
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertActioSheet = UIAlertController(title: LogoutActionSheetConstant.title,
                                                message: LogoutActionSheetConstant.message,
                                                preferredStyle: .actionSheet)
        
        alertActioSheet.addAction(UIAlertAction(title: LogoutOptionConstant.yesLogout,
                                                style: .destructive,
                                                handler: { [weak self] (_) in
                                                    guard let strongSelf = self else { return }
                                                    
                                                    do {
                                                        try FirebaseAuth.Auth.auth().signOut()
                                                        
                                                        let loginNavigation = presentLoginScreen()
                                                        strongSelf.present(loginNavigation, animated: false)
                                                    } catch {
                                                        print("Log out failed!")
                                                    }
                                                }))
        
        alertActioSheet.addAction(UIAlertAction(title: LogoutOptionConstant.noCancel,
                                                style: .cancel,
                                                handler: nil))
        
        present(alertActioSheet, animated: true)
    }
}
