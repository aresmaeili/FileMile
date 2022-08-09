//
//  Extensions.swift
//  FileMile
//
//  Created by EbcomCo on 5/18/1401 AP.
//

import Foundation
import UIKit

extension UIViewController {
    
    func dismissWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissView() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
}
