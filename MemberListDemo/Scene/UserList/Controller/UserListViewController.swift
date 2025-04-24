//
//  UserListViewController.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

import UIKit
import Combine

class UserListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    
    private let cellIdentifier = "UserListTableViewCell"
    
    private var viewModel: UserListViewModel = UserListViewModel()
    private var cancellables = Set<AnyCancellable>()

    private var refreshControl: UIRefreshControl?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        bindViewModel()
        fetchData()
    }
    
    func setupNavigationBar() {
        title = "Github User List"
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
        if indexPath.row < viewModel.users.count {
            cell.config(with: viewModel.users[indexPath.row])
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY    = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight   = scrollView.frame.height
        
        if offsetY > contentHeight - frameHeight * 2 {
            viewModel.loadNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < viewModel.users.count else { return }
        let userDetailViewModel = UserDetailViewModel(user: viewModel.users[indexPath.row])
        let userDetailVC = UserDetailViewController(viewModel: userDetailViewModel)
        navigationController?.pushViewController(userDetailVC, animated: true)
    }
}

private extension UserListViewController {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func fetchData() {
        viewModel.refresh()
    }
    
    func bindViewModel() {
        viewModel.$users
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                loading ? self?.loadingIndicator.startAnimating()
                : self?.loadingIndicator.stopAnimating()
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.show(error)
                }
            }
            .store(in: &cancellables)
    }
    
    @objc func handleRefresh() {
        viewModel.refresh()
        refreshControl?.endRefreshing()
    }
    
    
    // MARK: - Error Alert
    func show(_ error: APIError) {
        let alert = UIAlertController(title: "Error",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
