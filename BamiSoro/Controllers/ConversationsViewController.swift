//
//  ViewController.swift
//  BamiSoro
//
//  Created by waheedCodes on 06/11/2020.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationsViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .dark)
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = ConversationsConstant.noConverstations
        label.textAlignment = .center
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeNewChat))
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        setupTableView()
        fetchConversations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    @objc private func didTapComposeNewChat() {
        let newConversationViewController = NewConversationViewController()
        let navigationController = UINavigationController(rootViewController: newConversationViewController)
        present(navigationController, animated: true, completion: nil)
    }
     
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let loginNavigation = presentLoginScreen()
            present(loginNavigation, animated: true)
        }
    }
    
    private func fetchConversations() {
        tableView.isHidden = false
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension ConversationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let chatViewController = ChatViewController()
        chatViewController.title = "Omotolani Shodunke"
        chatViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}

extension ConversationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello World!"
        return cell
    }

}
