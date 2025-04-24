//
//  UIView+Extension.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

import UIKit

@IBDesignable
extension UIView {
    @IBInspectable
    var cornerRadiusIB: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius  = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
