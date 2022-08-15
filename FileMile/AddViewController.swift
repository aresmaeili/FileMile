//
//  AddViewController.swift
//  FileMile
//
//  Created by EbcomCo on 5/18/1401 AP.
//

import Foundation
import UIKit
import MobileCoreServices

protocol addViewControllerDelegate: AnyObject {
    func closedView()
}

class AddViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var newFolderButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBAction func importButtonAction(_ sender: Any) {
        importButtonDidTap()
    }
    @IBAction func newFolderButtonAction(_ sender: Any) {
        newFolderButtonDidTap()
    }
    @IBAction func cancelButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    var url : URL!
    weak var delegate : addViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

//MARK: - Functions
extension AddViewController {
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
    
    func importButtonDidTap(){
        openDocumentPicker()

    }
    
    func newFolderButtonDidTap(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewFolderViewController") as! AddNewFolderViewController
        vc.url = self.url
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}


extension AddViewController:  UIDocumentPickerDelegate {
    func openDocumentPicker(){
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText),String(kUTTypeContent),String(kUTTypeItem),String(kUTTypeData)], in: .import)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
//        for url in urls {
        secureCopyItem(at: url, to: (self.url.appendingPathComponent("\(url.lastPathComponent)")))
//        }
    print(urls)
    }
    
    func secureCopyItem(at srcURL: URL, to dstURL: URL){
            do {
                if FileManager.default.fileExists(atPath: dstURL.path) {
                    try FileManager.default.removeItem(at: dstURL)
                }
                try FileManager.default.copyItem(at: srcURL, to: dstURL)
            } catch (let error) {
                print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            }
        delegate?.closedView()
        self.dismiss(animated: true) 
        }
}

extension AddViewController: AddNewFolderViewControllerDelegate{
    func closeView() {
        self.dismiss(animated: true) {
            self.delegate?.closedView()
        }
    }
}
