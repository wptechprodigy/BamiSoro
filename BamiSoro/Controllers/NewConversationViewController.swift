//
//  NewConversationViewController.swift
//  BamiSoro
//
//  Created by waheedCodes on 07/11/2020.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .dark)
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = SearchBarConstant.placeHolder
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let noContactResultLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = SearchBarConstant.noSearchResult
        label.textAlignment = .center
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSearchBar()
    }
    
    func setupSearchBar() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: SearchBarConstant.cancelSearch,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search bar clicked.")
    }
}
