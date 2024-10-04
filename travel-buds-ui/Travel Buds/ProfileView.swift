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
    @State private var feedbackText = ""
    @State private var showFeedbackAlert = false
    @ObservedObject private var viewModel = UserViewModel()
    
    var body: some View {
        NavigationView{
            VStack {
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
                
                Spacer()
                
                Form{
                    Section{
                        VStack(spacing: 20){
                            ProfileInfoRow(title: "Email", value: viewModel.user?.email ?? "")
                                .padding(10)
                            Divider()
                            ProfileInfoRow(title: "Username", value: viewModel.user?.userName ?? "")
                                .padding(10)
                        }
                    }
                    header: {
                            Text("Info")
                    }
                    .listRowBackground(Color.purple.opacity(0.1))
                    
                    
                    let tripsList : [Trip] = viewModel.user?.trips ?? []
                    
                    Section{
                        ForEach(tripsList, id:\.weekStartDate){ newTrip in
                            Text("\(newTrip.interest) @ \(newTrip.destination)")
                                .multilineTextAlignment(.leading)
                                .bold()
                        }
                    }
                    header: {
                        Text("Trips")
                    }
                    .listRowBackground(Color.purple.opacity(0.1))
                }
                Spacer()
                
                Text("You've been to:")
                    .font(.title)
                ScrollView {
                    LazyHGrid(rows: [GridItem()]) {
                        ForEach(Array(viewModel.user?.flags ?? Set()), id: \.self) { flagUrl in
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
            .navigationTitle("Profile")
            .navigationBarItems(trailing:
                Button(action: {
                    showFeedbackAlert.toggle()
                }) {
                    Image(systemName: "envelope")
                        .foregroundColor(.blue)
                }
                .alert("Enter your feedback", isPresented: $showFeedbackAlert) {
                    TextField("Feedback", text: $feedbackText)
                    HStack {
                        Button("Submit", action: submitFeedback)
                        Button("Cancel") {
                            showFeedbackAlert = false
                            feedbackText = ""
                        }
                    }
                }
            )
        }
        .onAppear(){
            viewModel.getCurrentUser()
        }
        .fullScreenCover(isPresented: $showImageSelector, onDismiss: nil){
            ImagePicker(image: $image)
        }
    }
    
    func submitFeedback() {
        var ref = FirebaseManager.shared.firestore.collection("feedbacks").addDocument(data: [
            "feedback": feedbackText,
            "uid": FirebaseManager.shared.auth.currentUser?.uid ?? ""
        ]) { err in
            if let err = err {
                print("Error adding feedback: \(err)")
            }
        }
        feedbackText = ""
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
    
}


struct ProfileViewPreview: PreviewProvider{
    static var previews: some View{
        ProfileView()
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
            Spacer()
            Text(value)
                .font(.body)
        }
    }
}

