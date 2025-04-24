//
//  UserDetailViewController.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

import UIKit
import SDWebImage

class UserDetailViewController: UIViewController {

    // MARK: - Information
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    // MARK: - Followers
    @IBOutlet private weak var followersNumberLabel: UILabel!
    @IBOutlet private weak var followingNumberLabel: UILabel!
    // MARK: - Blog
    @IBOutlet private weak var blogLinkTextView: UITextView!
    
    private let viewModel: UserDetailViewModel
    
    init(viewModel: UserDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        configView(with: viewModel.user)
    }
    
    func setupNavigationBar() {
        title = "User Details"
        navigationController?.navigationBar.tintColor = UIColor.label
    }
}

private extension UserDetailViewController {
    func setupView() {
        blogLinkTextView.isEditable = false
        blogLinkTextView.isSelectable = true
        blogLinkTextView.dataDetectorTypes = [.link]
        blogLinkTextView.textContainerInset = .zero
        blogLinkTextView.linkTextAttributes = [.foregroundColor: UIColor.darkGray]
    }
    
    func configView(with user: UserDetail) {
        let avatarUrl = URL(string: user.avatarUrl ?? "")
        avatarImageView.sd_setImage(with: avatarUrl,
                                    placeholderImage: UIImage(systemName: "person"))
        nameLabel.text = user.name
        locationLabel.text = user.location ?? "-"
        
        followersNumberLabel.text = String(user.followers ?? 0)
        followingNumberLabel.text = String(user.following ?? 0)
        
        if let urlString = user.blog,
           let url = URL(string: urlString) {
            let attributed = NSAttributedString(string: urlString,
                                                attributes: [
                                                    .link: url,
                                                    .foregroundColor: UIColor.darkGray
                                                ])
            blogLinkTextView.attributedText = attributed
        } else {
            blogLinkTextView.text = user.blog
        }
    }
}
