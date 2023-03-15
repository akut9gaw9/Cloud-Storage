//
//  UIViewExtension.swift
//  diplom
//
//  Created by Stanislav on 07.01.2023.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return cornerRadius }
        set { self.layer.cornerRadius = newValue }
    }
}


