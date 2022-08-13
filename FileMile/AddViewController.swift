//
//  AddViewController.swift
//  FileMile
//
//  Created by EbcomCo on 5/18/1401 AP.
//

import Foundation
import UIKit

class AddViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var newFolderButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBAction func cancelButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView(){
        backView.layer.cornerRadius = 25
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemBlue.cgColor
        cancelButton.layer.cornerRadius = 10
        importButton.setImage(UIImage(named: "importFile"), for: .normal)
        newFolderButton.setImage(UIImage(named: "newFolder") , for: .normal)
        newFolderButton.contentMode = .scaleAspectFit
        importButton.contentMode = .scaleAspectFit
        importButton.setTitle("", for: .normal)
        newFolderButton.setTitle("", for: .normal)
    }
}
