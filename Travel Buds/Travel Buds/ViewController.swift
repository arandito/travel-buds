//
//  ViewController.swift
//  Travel Buds
//
//  Created by Yongkang Lin on 11/8/23.
//

import UIKit
<<<<<<< HEAD
import FirebaseAuth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let handle = Auth.auth().addStateDidChangeListener { auth, user in
        //do stuff with user data fetched from firebase
        }
=======

class ViewController: UIViewController {
    
    var userCredentials: [String: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
>>>>>>> 716dd0535e2badcf7ec6125248d23b4d5e71f14c
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
<<<<<<< HEAD
            textField.placeholder = "Enter your email address"
=======
            textField.placeholder = "Enter your desired username"
>>>>>>> 716dd0535e2badcf7ec6125248d23b4d5e71f14c
        }
        alert.addTextField { textField in
            textField.placeholder = "Enter your desired password"
            textField.isSecureTextEntry = true
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let signUp = UIAlertAction(title: "Sign Up", style: .default) { _ in
            if let textFields = alert.textFields {
<<<<<<< HEAD
                let email = textFields[2].text ?? ""
                let password = textFields[3].text ?? ""
                
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        let signUpError = UIAlertController(title: "Sign Up Error", message: "Username Already Taken", preferredStyle: .alert)
                        signUpError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(signUpError, animated: true, completion: nil)
                    }else{
                        let signUpSuccess = UIAlertController(title: "Sign Up Success", message: "Thank You For Using Travel Buds (:", preferredStyle: .alert)
                        signUpSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(signUpSuccess, animated: true, completion: nil)
                    }
=======
                let username = textFields[2].text ?? ""
                let password = textFields[3].text ?? ""
                
                if self.userCredentials[username] == nil {
                    self.userCredentials[username] = password
                    let signUpSuccess = UIAlertController(title: "Sign Up Success", message: "Thank You For Using Travel Buds (:", preferredStyle: .alert)
                    signUpSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(signUpSuccess, animated: true, completion: nil)
                } else {
                    let signUpError = UIAlertController(title: "Sign Up Error", message: "Username Already Taken", preferredStyle: .alert)
                    signUpError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(signUpError, animated: true, completion: nil)
>>>>>>> 716dd0535e2badcf7ec6125248d23b4d5e71f14c
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
<<<<<<< HEAD
            textField.placeholder = "Enter your email"
=======
            textField.placeholder = "Enter your username"
>>>>>>> 716dd0535e2badcf7ec6125248d23b4d5e71f14c
        }
        alert.addTextField { textField in
            textField.placeholder = "Enter your password"
            textField.isSecureTextEntry = true
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let login = UIAlertAction(title: "Login", style: .default) { _ in
<<<<<<< HEAD
            if let textFields = alert.textFields, let email = textFields[0].text, let password = textFields[1].text{
                    Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                        if let error = error {
                            let loginError = UIAlertController(title: "Login Error", message: "Invalid Username Or Password", preferredStyle: .alert)
                            loginError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(loginError, animated: true, completion: nil)
                        }else{
                            if let chat = self?.storyboard?.instantiateViewController(withIdentifier: "chat") {
                                self?.present(chat, animated: true, completion: nil)
                            }
                        }
=======
            if let textFields = alert.textFields, let username = textFields[0].text, let password = textFields[1].text{
                    if let storedPassword = self.userCredentials[username], storedPassword == password {
                        if let chat = self.storyboard?.instantiateViewController(withIdentifier: "chat") {
                            self.present(chat, animated: true, completion: nil)
                        }
                    } else {
                        let loginError = UIAlertController(title: "Login Error", message: "Invalid Username Or Password", preferredStyle: .alert)
                        loginError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(loginError, animated: true, completion: nil)
>>>>>>> 716dd0535e2badcf7ec6125248d23b4d5e71f14c
                    }
                }
            }
        
        alert.addAction(cancel)
        alert.addAction(login)
        
        self.present(alert, animated: true, completion: nil)
    }

}

