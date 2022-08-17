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
        cancelButton.layer.borderColor = UIColor.darkGray.cgColor
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
    
    func downloadButtonDidTap(){
    
    }
    
    func newFolderButtonDidTap(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewFolderViewController") as! AddNewFolderViewController
        vc.url = self.url
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    func insertExistedFile(sourceUrl: URL,destinationUrl: URL , insertType: vcType){
        let alert = UIAlertController(title: "EXISTED", message: "Your file Existed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Replace", style: .default, handler: { [ weak alert] (_) in
            do{
            try FileManager.default.removeItem(at: destinationUrl)
                switch insertType {
                case .normal:
                    return
                case .copy:
                    try FileManager.default.copyItem(at: sourceUrl, to: destinationUrl)
                case .move:
                    try FileManager.default.moveItem(at: sourceUrl, to: destinationUrl)
                }
            } catch (let error) {
                print("Cannot insert item at \(sourceUrl) to \(destinationUrl): \(error)")
            }
            self.delegate?.closedView()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [self, weak alert] (_) in
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
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
        secureCopyItem(at: url, to: (self.url.appendingPathComponent("\(url.lastPathComponent)")))
    print(urls)
    }
    
    func secureCopyItem(at sourceUrl: URL, to destinationUrl: URL){
            do {
                if destinationUrl.pathExtension == "pdf"{
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    insertExistedFile(sourceUrl: sourceUrl, destinationUrl: destinationUrl , insertType: .copy)
                }else{
                    try FileManager.default.copyItem(at: sourceUrl, to: destinationUrl)
                }
                }else{
                    BannerManager.showMessage(errorMessageStr: "Only PDF Files", .warning)
                }
            } catch (let error) {
                print("Cannot copy item at \(sourceUrl) to \(destinationUrl): \(error)")
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
