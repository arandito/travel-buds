//
//  ChatViewModel.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 12/3/23.
//

import SwiftUI
import Firebase

struct RecentMessage: Identifiable, Hashable {
    var id: String { documentId }
    let documentId: String
    let text: String
    let senderId: String
    let groupId: String
    let timestamp: Firebase.Timestamp
    let title: String
    let url: String
    
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        let timeAgoString = formatter.localizedString(for: timestamp.dateValue(), relativeTo: Date())
        if timeAgoString == "in 0s" {
            return "Just now"
        }
        return timeAgoString
    }
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.text = data["text"] as? String ?? ""
        self.senderId = data["senderId"] as? String ?? ""
        self.groupId = data["groupId"] as? String ?? ""
        self.title = data["title"] as? String ?? ""
        self.url = data["url"] as? String ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
    }
}

class ChatViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [Message]()
    @Published var userImageURLs = [String: String]()
    //@Published var count = 0
    
    @Published var recentMessages = [RecentMessage]()
    var listener: ListenerRegistration?
    var chatTextTemp = ""
    
    // let user: User?
    var groupId: String?
    
    init(groupId: String?) {
        self.groupId = groupId
        fetchMessages()
    }
    
    func fetchMessages() {
        
        if let existingListener = listener {
                existingListener.remove()
            }
        
        guard let groupId = self.groupId else {
            print("Group ID invalid")
            return
        }
        
        listener = FirebaseManager.shared.firestore
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
        
        self.chatTextTemp = self.chatText
        
        let messageData: [String : Any] = ["senderId": senderId, "text": self.chatText, "timestamp": Timestamp()]
        
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message in to Firestore: \(error)"
                print(self.errorMessage)
                return
            }
        }
        storeRecentMessage()
        self.chatText = ""
    }
    
    func storeRecentMessage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let groupId = self.groupId else { return }
        var memberList: [String] = []
        
        print(groupId)
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
                
                memberList = data["members"] as! [String]
                
                for member in memberList {
                    let document = FirebaseManager.shared.firestore
                        .collection("recentMessages")
                        .document(member)
                        .collection("messages")
                        .document(groupId)
                    
                    let data = [
                        "timestamp": Timestamp(),
                        "text": self.chatTextTemp,
                        "senderId": uid,
                        "groupId" : self.groupId ?? ""
                    ] as [String: Any]
                    
                    document.setData(data, merge: true) { error in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                    }
                }
            }
    }
    deinit {
        listener?.remove()
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


