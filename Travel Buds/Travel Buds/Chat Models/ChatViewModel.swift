//
//  ChatViewModel.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 12/3/23.
//

import SwiftUI
import Firebase

class ChatViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [Message]()
    @Published var userImageURLs = [String: String]()
    @Published var count = 0
    
    // let user: User?
    let groupId: String?
    
    init(groupId: String?) {
        // self.user = user
        self.groupId = groupId
        fetchMessages()
    }
    
    private func fetchMessages() {
        
        guard let groupId = self.groupId else {
            print("Group ID invalid")
            return
        }
        
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(groupId)
            .collection(groupId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                snapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                        
                    }
                })
            }
    }
    
    
    func handleSend() {
        
        if self.chatText == "" {
            return
        }
        
        guard let senderId = FirebaseManager.shared.auth.currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        guard let groupId = self.groupId else {
            print("Group ID invalid")
            return
        }
        
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(groupId)
            .collection(groupId)
            .document()
        
        let messageData: [String : Any] = ["senderId": senderId, "text": self.chatText, "timestamp": Timestamp()]
        
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message in to Firestore: \(error)"
                print(self.errorMessage)
                return
            }
        }
        
        self.chatText = ""
        self.count += 1
        
    }
}
    
    /*
    func fetchUserImageURLs(completion: @escaping () -> Void) {
        
        let usersCollection = FirebaseManager.shared.firestore.collection("users")
        
        usersCollection.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user image URLs: \(error)")
                completion()
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion()
                return
            }
            
            for document in documents {
                if let userId = document.data()["userId"] as? String,
                   let imageURL = document.data()["profileImageUrl"] as? String {
                    self.userImageURLs[userId] = imageURL
                }
            }
        }
        completion()
    }
     */


