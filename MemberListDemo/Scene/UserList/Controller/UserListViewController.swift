//
//  UserListViewController.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

import UIKit

class UserListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private let cellIdentifier = "UserListTableViewCell"
    
    private var viewModel: UserListViewModelProtocol = UserListViewModel()
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = UserListViewModel(output: self)
        setupNavigationBar()
        setupTableView()
        fetchData()
    }
    
    func setupNavigationBar() {
        title = "Github User List"
//        let currentLocationButton = UIBarButtonItem(image: UIImage(named: "navigate"), style: .plain, target: self, action: #selector(currentLocationOnTap))
//        let createGeofenceAreaButton = UIBarButtonItem(image: UIImage(named: "pencil"), style: .plain, target: self, action: #selector(createGeofenceAreaOnTap))
//        navigationItem.leftBarButtonItem = currentLocationButton
//        navigationItem.rightBarButtonItem = createGeofenceAreaButton
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    private func fetchData() {
        Task {
            await viewModel.refresh()
        }
    }
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserListTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY    = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight   = scrollView.frame.height
        
        if offsetY > contentHeight - frameHeight * 2 {
            Task { await viewModel.loadNextPage() }
        }
    }
}

// MARK: - UserListViewModelOutput
extension UserListViewController: UserListViewModelOutput {
    func usersPager(didUpdate list: [UserDetail]) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func usersPager(didChangeLoading isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading {
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
            }
        }
    }
    
    func usersPager(didReachEnd reached: Bool) {
        if reached {
            print("Reached the end of the list.")
        }
    }
    
    func usersPager(didFail error: APIError) {
        showAlertView(title: "Error",
                      message: error.localizedDescription,
                      okActionTitle: "OK") { action in
            
        }
    }
    
    
}
