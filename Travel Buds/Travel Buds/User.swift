//
//  User.swift
//  Travel Buds
//
//  Created by Yongkang Lin on 11/17/23.
//
import Foundation

struct User {
    let uid: String
    let email: String
    let userName: String
    let firstName: String
    let lastName: String
    var profileImageUrl: String
    let trips: [Trip]

}

struct Trip{
    let chatID: String?
    let destination: String
    let interest: String
    let weekStartDate: Date
    let weekEndDate: Date
}

class UserStore {
    
    static let shared = UserStore()
    @Published var user: User?
    
    init() {
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
            
            var trips: [Trip] = []

            if let tripsData = data["trips"] as? [[String: Any]] {
                trips = tripsData.map { tripData in
                    let destination = tripData["destination"] as? String ?? ""
                    let interest = tripData["interest"] as? String ?? ""
                    let chatId = tripData["chatId"] as? String ?? ""
                    let weekStartDate = tripData["weekStartDate"] as? String ?? ""
                    let weekEndDate = tripData["weekEndDate"] as? String ?? ""

                    return Trip(chatID: destination, destination: interest, interest: chatId, weekStartDate: weekStartDate, weekEndDate: weekEndDate)
                }
            }

            self.user = User(uid: uid, email: email, userName: userName, firstName: firstName, lastName: lastName, profileImageUrl: profileImageUrl, trips: trips)
        }
    }
}
