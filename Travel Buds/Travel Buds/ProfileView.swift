//
//  ProfileView.swift
//  Travel Buds
//
//  Created by Isaac Romero on 12/2/23.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct ProfileView: View {
    
    @State private var showImageSelector = false
    @State private var image: UIImage?
    @State var flagUrls = Set<String>()
    @ObservedObject private var viewModel = ChatListViewModel()
    
    var body: some View {
        NavigationView{
            VStack {
                // User Image
                WebImage(url: URL (string:viewModel.user?.profileImageUrl ?? ""))
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
                Text("\(viewModel.user?.firstName ?? "") \(viewModel.user?.lastName ?? "")")
                    .font(.title)
                
                
                //Additional Info
                VStack(spacing: 20){
                    Divider()
                    ProfileInfoRow(title: "Email", value: viewModel.user?.email ?? "")
                    Divider()
                    ProfileInfoRow(title: "Username", value: viewModel.user?.userName ?? "")
                    Divider()
                }
                Divider()
                Text("You've been to:")
                    .font(.title)
                ScrollView {
                    LazyHGrid(rows: [GridItem()]) {
                        ForEach(Array(flagUrls), id: \.self) { flagUrl in
                            WebImage(url: URL(string: flagUrl))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 3)
                        }
                    }
                    .padding()
                    }
                Spacer()
            }
            .opacity(viewModel.user != nil ? 1.0 : 0.0)
            .animation(.easeInOut)
            .onAppear(){
                flagUrls.removeAll();
                viewModel.getCurrentUser()
                loadFlags()
            }
            .navigationTitle("Profile")
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
                viewModel.user?.profileImageUrl = url.absoluteString
                FirebaseManager.shared.firestore
                    .collection("users")
                    .document(uid).updateData(["profileImageUrl" : url.absoluteString])
                }
            }
        }
    
    func loadFlags() {
        let countries = Set(viewModel.user?.trips.compactMap { $0.destination } ?? [])
        for city in countries where city != "" {
            getFlag(city: city) { flagUrl in
                if let flagUrl = flagUrl {
                    flagUrls.insert(flagUrl)
                }
            }
        }
        flagUrls.removeAll()
    }
    
    func getFlag(city: String, completion: @escaping (String?) -> Void) {
        FirebaseManager.shared.firestore.collection("Flags").document(city).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching flag URL for \(city): \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let data = snapshot?.data(), let flagUrl = data["URL"] as? String {
                completion(flagUrl)
            } else {
                completion(nil)
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

