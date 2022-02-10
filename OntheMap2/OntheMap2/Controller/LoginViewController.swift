//
//  LoginViewController.swift
//  OntheMap2
//
//  Created by Mac on 11/6/21.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.text = ""
        passwordTextField.text = ""
        activityIndicator.isHidden = true
        
        setupTextField()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        navigationController?.navigationBar.isHidden = true

    }
    
    func setupTextField() {
        emailTextField.textColor = .black
        passwordTextField.textColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTextField()
        subscribeToKeyboardNotifications()
        navigationController?.navigationBar.isHidden = true
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        if (emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Required information", message: "Please complete information", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            setLoggingIn(true)
            UdacityClient.login(username: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: loginButtonResponse(success: error:))
        }
    }
    
    func loginButtonResponse(success: Bool, error: Error?) {
        setLoggingIn(false)
        if success{
            print(UdacityClient.Auth.sessionId)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "tabBarSegue", sender: nil)
            }
        } else {
            emailTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        setLoggingIn(true)
        UIApplication.shared.open(UdacityClient.Endpoints.webAuth.url, options: [:], completionHandler: nil)
        setLoggingIn(false)
    }
    
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertVC, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if passwordTextField.isEditing || emailTextField.isEditing {
            view.frame.origin.y = (-1)*getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func setLoggingIn(_ loggingIn : Bool) {
        if loggingIn {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
        
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        signUpButton.isEnabled = !loggingIn
        activityIndicator.isHidden = !loggingIn
    }
}
