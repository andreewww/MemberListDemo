//
//  UserListTableViewCell.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

import UIKit
import SDWebImage

class UserListTableViewCell: UITableViewCell {
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var profileLinkTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileLinkTextView.isEditable = false
        profileLinkTextView.isSelectable = true
        profileLinkTextView.dataDetectorTypes = [.link]
        profileLinkTextView.textContainerInset = .zero
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func config(with user: UserDetail) {
        nameLabel.text = user.name
        let avatarUrl = URL(string: user.avatarUrl ?? "")
        avatarImageView.sd_setImage(with: avatarUrl,
                                    placeholderImage: UIImage(systemName: "person"))
        if let urlString = user.htmlUrl,
           let url = URL(string: urlString) {
            let attributed = NSAttributedString(string: urlString,
                                                attributes: [.link: url])
            profileLinkTextView.attributedText = attributed
        } else {
            profileLinkTextView.text = user.htmlUrl
        }
    }
}
