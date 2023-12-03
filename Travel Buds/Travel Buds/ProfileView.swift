//
//  ProfileView.swift
//  Travel Buds
//
//  Created by Isaac Romero on 12/2/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    
    @State private var showImageSelector = false
    @State private var image: UIImage?
    @State private var countries: [String]?
    @State private var userStore = UserStore.shared
    
    
    
    var body: some View {
        NavigationView{
            VStack {
                // User Image
                WebImage(url: URL (string: userStore.user!.profileImageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 5)
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .onEnded { _ in
                                showImageSelector.toggle()
                            }
                    )
                    .onChange(of: self.image){ newImage in updateProfilePicture()}
                                
                // User Name
                Text("\(userStore.user?.firstName ?? "") \(userStore.user?.lastName ?? "")")
                    .font(.title)
                
                Divider()
                
                //Additional Info
                VStack(spacing: 20){
                    
                    ProfileInfoRow(title: "Email", value: userStore.user?.email ?? "")
                        .padding(.bottom, 2)
                    Divider()
                    ProfileInfoRow(title: "Username", value: userStore.user?.userName ?? "")
                }
                Divider()
                Text("Past countries")
                    .font(.title)
                
            }.navigationTitle("Profile")
                .padding()
        }
        .fullScreenCover(isPresented: $showImageSelector, onDismiss: nil){
            ImagePicker(image: $image)
        }
    }
    
    func updateProfilePicture(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else{
            print("Unable to fetch UID")
            return
        }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5)
        else{
            print("Did not get image")
            return
        }
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            ref.downloadURL {url, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let url = url else {
                    return
                }
                self.userStore.user?.profileImageUrl = url.absoluteString
                FirebaseManager.shared.firestore
                    .collection("users")
                    .document(uid).updateData(["profileImageUrl" : url.absoluteString])
                }
            }
        }
}

//Struct to allow for extra user data to be displayed
struct ProfileInfoRow: View {
    var title: String
    var value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.black)
        }
    }
}

