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
    var location = ""
    var weekStartDate = ""
    var title = ""
    
    
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
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
    }
}

class ChatViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [Message]()
    @Published var userImageURLs = [String : String]()
    
    @Published var recentMessages = [RecentMessage]()
    var listener: ListenerRegistration?
    var chatTextTemp = ""
    
    // let user: User?
    var groupId: String?
    
    init(groupId: String?) {
        self.groupId = groupId
        fetchMessages()
        if self.groupId != nil {
            fetchUserImageURLs(groupId: self.groupId) { userImageURLs in
                self.userImageURLs = userImageURLs
            }
        }

    }
    
    func fetchMessages() {
        
        if let existingListener = listener {
            existingListener.remove()
        }
        
        guard let groupId = self.groupId else {
            // print("Group ID invalid")
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
                    
                    document.setData(data) { error in
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
    

    
    
    func fetchUserImageURLs(groupId: String?, completion: @escaping ([String: String]) -> Void) {
        
        var memberIdAndPictureDict = [String : String]()
        let groupsCollection = FirebaseManager.shared.firestore.collection("groups")
        let usersCollection = FirebaseManager.shared.firestore.collection("users")
        
        groupsCollection.document(groupId!).getDocument { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No data found.")
                return
            }
            
            let groupMembers = data["members"] as? [String] ?? []
            
            let dispatchGroup = DispatchGroup()
            
            for memberId in groupMembers {
                dispatchGroup.enter()
                
                usersCollection.document(memberId).getDocument { snapshot, error in
                    defer {
                        dispatchGroup.leave()
                    }
                    
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    guard let data = snapshot?.data() else {
                        print("No data found.")
                        return
                    }
                    
                    let profileImageUrl = data["profileImageUrl"] as? String ?? ""
                    
                    memberIdAndPictureDict[memberId] = profileImageUrl
                }
            }
            dispatchGroup.notify(queue: .main) {
                completion(memberIdAndPictureDict)
            }
        }
        
    }
}

