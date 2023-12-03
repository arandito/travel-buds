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
    @Environment(\.colorScheme) var colorScheme
    @State private var errorMessage: String?

   var textFieldBackgroundColor: Color {
       return colorScheme == .dark ? Color(.init(white: 0.17, alpha: 1.0)) : Color.white
   }

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
                            TextField("Last Name", text: $lastName)
                                .disableAutocorrection(true)
                            TextField("Username", text: $userName)
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .foregroundStyle(Color.primary)
                            TextField("Email", text: $signUpEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .foregroundStyle(Color.primary)
                            SecureField("Password", text: $signUpPassword)
                                .autocapitalization(.none)
                                .foregroundStyle(Color.primary)
                        } else {
                            TextField("Email", text: $logInEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textFieldStyle(DefaultTextFieldStyle())
                            SecureField("Password", text: $logInPassword)
                                .autocapitalization(.none)
                        }
                    }
                    .padding(12)
                    .background(textFieldBackgroundColor)
                    .cornerRadius(8)
                
                    Button {
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log in" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 15)
                                .font(.system(size: 20, weight: .semibold))
                            Spacer()
                        }
                        .background(Color.purple)
                        .cornerRadius(8)
                    }
                }.padding()
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }
                
            }
            .navigationTitle(isLoginMode ? "Log in" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
            .onChange(of: isLoginMode) { newIsLoginMode, _ in
                errorMessage = nil
            }
            .navigationBarItems(
                trailing:
                    HStack {
                        Image("travelbudslogo")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .padding(.top, 80)
                    }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showImageSelector, onDismiss: nil){
            ImagePicker(image: $image)
        }
    }
    
    private func handleAction() {
        errorMessage = nil
        if isLoginMode {
            print("Should log in to Firebase with existing credentials.")
            FirebaseManager.shared.auth.signIn(withEmail: logInEmail, password: logInPassword) { authResult, error in
                if let error = error {
                    errorMessage = "Invalid username or password."
                    print(error.localizedDescription)
                    return
                } else {
                    self.isLoginCompleted()
                }
            }
        } else {
            print("Register a new account.")
            if firstName == "" {
                errorMessage = "Please include your first name."
                return
            } else if lastName == "" {
                errorMessage = "Please include your last name."
                return
            } else if userName == "" {
                errorMessage = "Please choose a username."
                return
            } else if signUpEmail == "" {
                errorMessage = "Please include your email."
                return
            } else if signUpPassword == "" {
                errorMessage = "Please create a password."
                return
            }
            FirebaseManager.shared.auth.createUser(withEmail: signUpEmail, password: signUpPassword) { authResult, error in
                if let error = error {
                    errorMessage = "Email already in use."
                    print(error.localizedDescription)
                    return
                } else {
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
