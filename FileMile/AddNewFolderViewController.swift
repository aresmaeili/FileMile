//
//  AddNewFolderViewController.swift
//  FileMile
//
//  Created by EbcomCo on 5/22/1401 AP.
//

import Foundation
import UIKit

protocol AddNewFolderViewControllerDelegate: AnyObject {
        func closeView()
}

class AddNewFolderViewController : UIViewController {
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var newFolderNameTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBAction func confirmbuttonAction(_ sender: Any) {
        confirmbuttonDidTapped()
    }
    @IBAction func cancelButtonAction(_ sender: Any) {
        cancelbuttonDidTapped()

    }
    
    var url :URL!
    weak var delegate : AddNewFolderViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        parentView.layer.cornerRadius = 25
    }
}

//MARK: - Functions
extension AddNewFolderViewController {
    func confirmbuttonDidTapped(){
        guard let name = newFolderNameTextField.text else { return }
        if name != "" && name != " " {
            createDirectory(FolderName: name)
            self.dismiss(animated: true) {
                self.delegate?.closeView()
            }
            

            
        }else{
            BannerManager.showMessage(errorMessageStr: "Please choose a name for this folder", .info)
        }
    }
    
    func cancelbuttonDidTapped(){
        
    }
        
    func createDirectory(FolderName: String){
        let newFolder = url.appendingPathComponent("\(FolderName)")
        do{
            if !FileManager.default.fileExists(atPath: newFolder.path) {
                try FileManager.default.createDirectory(at: newFolder, withIntermediateDirectories: true, attributes: [:])
            }
        }catch{
            print("ERROR --> Create Directory \(newFolder.path)")
        }
    }
}
