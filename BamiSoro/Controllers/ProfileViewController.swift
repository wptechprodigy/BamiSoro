//
//  ProfileViewController.swift
//  BamiSoro
//
//  Created by waheedCodes on 07/11/2020.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

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
        tableView.tableHeaderView = createTableHeader()
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: UserDefaultConstant.email) as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        let filename = safeEmail + ProfilePictureConstant.profilePictureSuffix
        let profilePicturePath = "images/" + filename
        
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        headerView.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (headerView.width - 150) / 2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = imageView.width / 2
        imageView.layer.masksToBounds = true
        
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(with: profilePicturePath, completion: { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let url):
                // download the profile picture with the url
                strongSelf.downloadProfilePicture(imageView: imageView, url: url)
            case .failure(let error):
                print("Failed to download profile picture with url: \(error)")
            }
        })
        
        return headerView
    }
    
    func downloadProfilePicture(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let profilePicture = UIImage(data: data)
                imageView.image = profilePicture
            }
        }).resume()
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
                                                    
                                                    // Logout FB session
                                                    FBSDKLoginKit.LoginManager().logOut()
                                                    
                                                    // Google Sign out
                                                    GIDSignIn.sharedInstance()?.signOut()
                                                    
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
