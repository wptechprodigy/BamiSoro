//
//  NewConversationViewController.swift
//  BamiSoro
//
//  Created by waheedCodes on 07/11/2020.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    public var completion: (([String: String]) -> (Void))?
    private let spinner = JGProgressHUD(style: .dark)
    private var users = [[String: String]]()
    private var results = [[String: String]]()
    private var hasFetched = false
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = SearchBarConstant.placeHolder
        return searchBar
    }()
    
    private let listOfContactsTableView: UITableView = {
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
        view.addSubview(noContactResultLabel)
        view.addSubview(listOfContactsTableView)
        
        listOfContactsTableView.dataSource = self
        listOfContactsTableView.delegate = self
        
        view.backgroundColor = .white
        setupSearchBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        listOfContactsTableView.frame = view.bounds
        noContactResultLabel.frame = CGRect(x: view.width / 4,
                                            y: (view.height - 200) / 2,
                                            width: view.width / 2,
                                            height: 200)
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
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

extension NewConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Start conversation
        let targetContact = results[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetContact)
        })
    }
}

extension NewConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        // Remove the result everytime a new search is done
        results.removeAll()
        spinner.show(in: view)
        self.searchUsers(query: searchText)
    }
    
    func searchUsers(query: String) {
        // Check if the array has Firebase results
        if hasFetched {
            // If it does -> filter
            filterUsers(with: query)
        } else {
            // does not -> fetch then filter
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            })
        }
    }
    
    func filterUsers(with term: String) {
        // The we update UI: either show results or show no contentsResultLabel
        guard hasFetched else {
            return
        }
        
        self.spinner.dismiss()
        
        let results: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        })
        
        self.results = results
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            self.noContactResultLabel.isHidden = false
            self.listOfContactsTableView.isHidden = true
        } else {
            self.noContactResultLabel.isHidden = true
            self.listOfContactsTableView.isHidden = false
            self.listOfContactsTableView.reloadData()
        }
    }
}
