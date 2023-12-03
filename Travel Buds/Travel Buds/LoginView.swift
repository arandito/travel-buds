//
//  LoginView.swift
//  test
//
//  Created by Yuya Taniguchi on 11/19/23.
//

import SwiftUI

struct LoginView: View {
    
    let isLoginCompleted: () -> ()
    
    @State private var isLoginMode = true
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var userName = ""
    @State private var logInEmail = ""
    @State private var logInPassword = ""
    @State private var signUpEmail = ""
    @State private var signUpPassword = ""
    
    @State private var showImageSelector = false
    @State private var image: UIImage?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label: Text("Picker")) {
                        Text("Log in").tag(true)
                        Text("Create Account").tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                        .padding()
                    
                    if !isLoginMode {
                        Button {
                            showImageSelector.toggle()
                        } label: {
                            VStack {
                                if let image = self.image {
                                    Image(uiImage:image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:128, height:128)
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 96))
                                        .padding()
                                        .foregroundColor(.purple)
                                }
                            }
                        }
                    }
                    
                    Group {
                        if !isLoginMode {
                            TextField("First Name", text: $firstName)
                                .disableAutocorrection(true)
                                .foregroundColor(.white)
                            TextField("Last Name", text: $lastName)
                                .disableAutocorrection(true)
                                .foregroundColor(.white)
                            TextField("Username", text: $userName)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .foregroundColor(.white)
                            TextField("Email", text: $signUpEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .foregroundColor(.white)
                            SecureField("Password", text: $signUpPassword)
                                .autocapitalization(.none)
                                .foregroundColor(.white)
                        } else {
                            TextField("Email", text: $logInEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .foregroundColor(.white)
                            SecureField("Password", text: $logInPassword)
                                .autocapitalization(.none)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(12)
                    .background(Color.black)
                    
                    Button {
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log in" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.purple)
                    }
                }.padding()
                
                
            }
            .navigationTitle(isLoginMode ? "Log in" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showImageSelector, onDismiss: nil){
            ImagePicker(image: $image)
        }
    }
    
    private func handleAction() {
        if isLoginMode {
            print("Should log in to Firebase with existing credentials.")
            FirebaseManager.shared.auth.signIn(withEmail: logInEmail, password: logInPassword) { authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                    let loginError = UIAlertController(title: "Login Error", message: "Invalid Username Or Password", preferredStyle: .alert)
                    loginError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    //self.present(loginError, animated: true, completion: nil) // Present the login error alert
                } else {
                    self.isLoginCompleted()
                }
            }
        } else {
            print("Register a new account.")
            FirebaseManager.shared.auth.createUser(withEmail: signUpEmail, password: signUpPassword) { authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                    let signUpError = UIAlertController(title: "Sign Up Error", message: "Email already in use", preferredStyle: .alert)
                    signUpError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                   // self.present(signUpError, animated: true, completion: nil) // Present the sign-up error alert
                } else {
                    let signUpSuccess = UIAlertController(title: "Sign Up Success", message: "Thank You For Using Travel Buds (:",
                                                           preferredStyle: .alert)
                    signUpSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    //self.present(signUpSuccess, animated: true, completion: nil)
                    
                    /* Store user information and image in Firestore */
                    self.storeUserData(email: signUpEmail, firstName: firstName, lastName: lastName, userName: userName)
                }
            }
        }
    }
    
    func storeProfileImage(completion: @escaping (URL?) -> Void) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            completion(nil)
            return
        }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            ref.downloadURL {url, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(nil)
                    return
                }
                guard let url = url else {
                    completion(nil)
                    return
                }
                completion(url)
            }
        }
        
    }
    func storeUserData(email: String, firstName: String, lastName: String, userName: String) {
        storeProfileImage {imageUrl in
            guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
            var userData = ["email": email, "firstName": firstName, "lastName": lastName, "userName": userName]
            if let imageUrl = imageUrl {
                userData["profileImageUrl"] = imageUrl.absoluteString
            }
            FirebaseManager.shared.firestore.collection("users")
                .document(userId).setData(userData) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    self.isLoginCompleted()
                    print("Success")
                }
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoginCompleted: {
            
        })
            .preferredColorScheme(.light)

    }
}
