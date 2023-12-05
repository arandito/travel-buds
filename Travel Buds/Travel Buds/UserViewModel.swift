//
//  UserViewModel.swift
//  Travel Buds
//
//  Created by Antonio Aranda on 12/3/23.
//

import SwiftUI
import FirebaseFirestore

class UserViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var isLoggedOut = false
    @Published var recentMessages = [RecentMessage]()
    var listener: ListenerRegistration?
    
    init() {
        DispatchQueue.main.async{
            self.isLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        getCurrentUser()
        getRecentMessages()
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
            self.loadFlags()
        }
    }
    
    func handleSignOut() {
        try? FirebaseManager.shared.auth.signOut()
        self.isLoggedOut.toggle()
        self.user = nil
    }
    
    func getRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        listener?.remove()
        self.recentMessages.removeAll()
        
        listener = FirebaseManager.shared.firestore
            .collection("recentMessages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener{ querySnapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    let documentId = change.document.documentID
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.documentId == documentId
                    }){
                        self.recentMessages.remove(at: index)
                    }
                    self.recentMessages.insert(.init(documentId: documentId, data: change.document.data()), at: 0)
                })
            }
            
        var groupId = ""
        for var message in recentMessages {
            groupId = message.groupId
            FirebaseManager.shared.firestore
                .collection("groups")
                .document(groupId)
                .getDocument { snapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    guard let data = snapshot?.data() else {
                        print("No data found.")
                        return
                    }
                    
                    message.location = data["destination"] as? String ?? ""
                    message.weekStartDate = data["weekStartDate"] as? String ?? ""
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy"

                    if let date = dateFormatter.date(from: message.weekStartDate) {
                        dateFormatter.dateFormat = "MM/dd"
                        message.weekStartDate = dateFormatter.string(from: date)
                    }
                    message.title = "\(message.location) \(message.weekStartDate)"
                }
        }
    }
    
    func loadFlags() {
        let countries = Set(user?.trips.compactMap { $0.destination } ?? [])
        for city in countries where city != "" {
            getFlag(city: city) { flagUrl in
                if let flagUrl = flagUrl {
                    self.user?.flags.insert(flagUrl)
                }
            }
        }
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
