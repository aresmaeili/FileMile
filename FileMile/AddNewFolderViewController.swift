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
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var newFolderNameTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBAction func confirmButtonAction(_ sender: Any) {
        confirmButtonDidTapped()
    }
    @IBAction func cancelButtonAction(_ sender: Any) {
        cancelButtonDidTapped()
    }
    
    var url :URL!
    weak var delegate : AddNewFolderViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupKeyBoardHandling()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
}

//MARK: - Functions
extension AddNewFolderViewController {
    func setupViews(){
        newFolderNameTextField.delegate = self
        bottomView.layer.cornerRadius = 25
        confirmButton.layer.cornerRadius = 10
        cancelButton.layer.cornerRadius = 10
        confirmButton.layer.borderWidth = 0.25
        cancelButton.layer.borderWidth = 0.25
        confirmButton.layer.borderColor = UIColor.systemBlue.cgColor
        cancelButton.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    func confirmButtonDidTapped(){
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
    
    func cancelButtonDidTapped(){
        self.dismiss(animated: true)
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

//MARK: - Handling KeyBoard
extension AddNewFolderViewController {
    func setupKeyBoardHandling(){
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
        initializeHideKeyboard()
    }
    
    func initializeHideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }

    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        if let scrollView = scrollView, let userInfo = notification.userInfo, let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey], let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
            let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
            let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y
            scrollView.contentInset.bottom = keyboardOverlap
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardOverlap
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}

//MARK: - Handling TextField
extension AddNewFolderViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
