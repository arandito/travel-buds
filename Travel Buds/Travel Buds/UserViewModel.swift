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
            // let uid = data["uid"] as? String ?? ""
            let uid = uid
            let email = data["email"] as? String ?? ""
            let profileImageUrl = data["profileImageUrl"] as? String ?? ""
            let groups = data["groups"] as? [String] ?? []
            let pendingRequests = data["pendingRequests"] as? [String] ?? []


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
            
            
            self.user = User(uid: uid, email: email, userName: userName, firstName: firstName, lastName: lastName, profileImageUrl: profileImageUrl, groups: groups, pendingRequests: pendingRequests, trips: trips)
            self.loadFlags()
            self.getRecentMessages()
        }
    }
    
    func handleSignOut() {
        try? FirebaseManager.shared.auth.signOut()
        self.isLoggedOut.toggle()
        self.user = nil
    }
    
    func removeUserFromChat(groupId: String){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let documentReference1 = FirebaseManager.shared.firestore
            .collection("recentMessages")
            .document(uid)
            .collection("messages")
            .document(groupId)

        documentReference1.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Document successfully deleted")
            }
        }
        
        let documentReference2 = FirebaseManager.shared.firestore
            .collection("groups")
            .document(groupId)
        
        documentReference2.updateData(["members": FieldValue.arrayRemove([uid])]) { error in
            if let error = error {
                print("Error removing UID from members list: \(error)")
            } else {
                print("UID successfully removed from members list")
            }
        }

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
