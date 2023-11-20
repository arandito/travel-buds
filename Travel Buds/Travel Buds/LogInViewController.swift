//
//  LogInViewController.swift
//  Travel Buds
//
//  Created by Yongkang Lin on 11/8/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class LogInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signUp(_ sender: UIButton) {
        let alert = UIAlertController(title: "Travel Buds", message: "Please sign up here", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter your first name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Enter your last name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Enter your email address"
        }
        alert.addTextField { textField in
            textField.placeholder = "Enter your desired password"
            textField.isSecureTextEntry = true
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let signUp = UIAlertAction(title: "Sign Up", style: .default) { _ in
            if let textFields = alert.textFields {
                let firstName = textFields[0].text ?? ""
                let lastName = textFields[1].text ?? ""
                let email = textFields[2].text ?? ""
                let password = textFields[3].text ?? ""
                
                FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        print(error)
                        let signUpError = UIAlertController(title: "Sign Up Error", message: "Email already in use", preferredStyle: .alert)
                        signUpError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(signUpError, animated: true, completion: nil)
                    } else {
                        let signUpSuccess = UIAlertController(title: "Sign Up Success", message: "Thank You For Using Travel Buds (:",
                                                               preferredStyle: .alert)
                        signUpSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(signUpSuccess, animated: true, completion: nil)
                        
                        /* Store user information in Firestore */
                        self.storeUserInformation(email: email, firstName: firstName, lastName: lastName)
                    }
                }
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(signUp)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func logIn(_ sender: UIButton) {
        let alert = UIAlertController(title: "Travel Buds", message: "Please log in here", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter your email"
        }
        alert.addTextField { textField in
            textField.placeholder = "Enter your password"
            textField.isSecureTextEntry = true
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let login = UIAlertAction(title: "Login", style: .default) { _ in
            if let textFields = alert.textFields, let email = textFields[0].text, let password = textFields[1].text{
                FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
                        if let error = error {
                            let loginError = UIAlertController(title: "Login Error", message: "Invalid Username Or Password", preferredStyle: .alert)
                            loginError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(loginError, animated: true, completion: nil)
                        }else{
                            if let chat = self?.storyboard?.instantiateViewController(withIdentifier: "chat") {
                                self?.present(chat, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        alert.addAction(cancel)
        alert.addAction(login)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func storeUserInformation(email: String, firstName: String, lastName: String) {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email": email, "firstName": firstName, "lastName": lastName]
        FirebaseManager.shared.firestore.collection("users")
            .document(userId).setData(userData) { err in
                if let err = err {
                    print(err)
                    return
                }
                print("Success")
            }
    }
}

