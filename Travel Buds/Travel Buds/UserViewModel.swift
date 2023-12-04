//
//  UserViewModel.swift
//  Travel Buds
//
//  Created by Antonio Aranda on 12/3/23.
//

import SwiftUI

class UserViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var isLoggedOut = true
    
    init() {
        DispatchQueue.main.async{
            self.isLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        getCurrentUser()
    }
    
    func getCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            print("User not logged in.")
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No data found.")
                return
            }
            
            let userName = data["userName"] as? String ?? ""
            let firstName = data["firstName"] as? String ?? ""
            let lastName = data["lastName"] as? String ?? ""
            let uid = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let profileImageUrl = data["profileImageUrl"] as? String ?? ""
            let groups = data["groups"] as? [String] ?? []


            var trips: [Trip] = []

            if let tripsData = data["trips"] as? [[String: Any]] {
                trips = tripsData.map { tripData in
                    let destination = tripData["destination"] as? String ?? ""
                    let interest = tripData["interest"] as? String ?? ""
                    let chatId = tripData["chatId"] as? String ?? ""
                    let weekStartDate = tripData["weekStartDate"] as? Date ?? Date()
                    let weekEndDate = tripData["weekEndDate"] as? Date ?? Date()

                    return Trip(chatID: chatId, destination: destination, interest: interest, weekStartDate: weekStartDate, weekEndDate: weekEndDate)
                }
            }

            self.user = User(uid: uid, email: email, userName: userName, firstName: firstName, lastName: lastName, profileImageUrl: profileImageUrl, groups: groups, trips: trips)
        }
    }
    
    func handleSignOut() {
        try? FirebaseManager.shared.auth.signOut()
        self.isLoggedOut.toggle()
        self.user = nil
    }
}
