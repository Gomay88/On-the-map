//
//  ViewController.swift
//  OnTheMap
//
//  Created by Victor Jimenez on 12/27/16.
//  Copyright © 2016 Victor Jimenez. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let udacityClient = UdacityClient.sharedClient()
    private let studentsData = StudentsData.sharedData()
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loginButton.isEnabled = true
        activityIndicator.stopAnimating()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    private func getStudentData(key: String) {
        udacityClient.studentData(key) { (student, error) in
            DispatchQueue.main.async {
                if student != nil {
                    self.studentsData.currentStudent = StudentWithLocation(student: student!)
                    self.performSegue(withIdentifier: "Login", sender: self)
                } else {
                    self.showError(error: "Failed to retrieve student data")
                    self.loginButton.isEnabled = true
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    private func showError(error: String) {
        let alertView = UIAlertController(title: "Found some error", message: error, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Hide", style: .cancel, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func LoginButtonTap(_ sender: Any) {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            showError(error: "Please fill the textfields in order to continue")
        } else {
            loginButton.isEnabled = false
            activityIndicator.startAnimating()
            udacityClient.login(emailTextField.text!, password: passwordTextField.text!) { (userKey, error) in
                DispatchQueue.main.async {
                    if let userKey = userKey {
                        self.getStudentData(key: userKey)
                    } else {
                        self.showError(error: error!.localizedDescription)
                        self.loginButton.isEnabled = true
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    //Keyboard
    @objc func keyboardWillShow(_ notification: Notification) {
        if passwordTextField.isFirstResponder || emailTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
