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
        newFolderNameTextField.delegate = self
        setupkeyBoardHandling()
        bottomView.layer.cornerRadius = 25
        confirmButton.layer.cornerRadius = 10
        cancelButton.layer.cornerRadius = 10
        confirmButton.layer.borderWidth = 0.25
        cancelButton.layer.borderWidth = 0.25
        confirmButton.layer.borderColor = UIColor.systemBlue.cgColor
        cancelButton.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Unsubscribe from all our notifications
        unsubscribeFromAllNotifications()
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
    
    func setupkeyBoardHandling(){
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
                
                //Subscribe to a Notification which will fire before the keyboard will hide
                subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
                
                //We make a call to our keyboard handling function as soon as the view is loaded.
                initializeHideKeyboard()
    }
    
    func initializeHideKeyboard(){
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissMyKeyboard(){
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        //In short- Dismiss the active keyboard.
        view.endEditing(true)
    }
}

//MARK: - Handling KeyBoard
extension AddNewFolderViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        // Get required info out of the notification
        if let scrollView = scrollView, let userInfo = notification.userInfo, let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey], let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
            
            // Transform the keyboard's frame into our view's coordinate system
            let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
            
            // Find out how much the keyboard overlaps our scroll view
            let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y
            
            // Set the scroll view's content inset & scroll indicator to avoid the keyboard
            scrollView.contentInset.bottom = keyboardOverlap
            scrollView.scrollIndicatorInsets.bottom = keyboardOverlap
            
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
