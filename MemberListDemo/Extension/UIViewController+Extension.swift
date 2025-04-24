//
//  UIViewController+Extension.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

import UIKit

public typealias AlertActionHandler = ((UIAlertAction) -> Void)?

extension UIViewController {
    public func showAlertView(title: String, message: String?,
                       okActionTitle: String? = "OK", okActionHandler: AlertActionHandler = nil) {
        let alerVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okActionTitle, style: .default, handler: okActionHandler)
        alerVC.addAction(okAction)
        self.present(alerVC, animated: true)
    }
}
