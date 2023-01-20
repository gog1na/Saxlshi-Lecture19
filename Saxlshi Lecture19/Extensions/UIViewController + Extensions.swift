//
//  UIViewController + Extensions.swift
//  Saxlshi Lecture19
//
//  Created by Giorgi Goginashvili on 1/20/23.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround()  {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


