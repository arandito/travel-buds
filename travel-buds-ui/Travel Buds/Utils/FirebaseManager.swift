//
//  FirebaseManager.swift
//  Travel Buds
//
//  Created by Antonio Aranda on 11/19/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

class FirebaseManager: NSObject {
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    let db: DatabaseReference
    
    
    static let shared = FirebaseManager()
    
    override init(){
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        self.db = Database.database().reference()
        super.init()
    }
    
    
    
    /*
    func sendMessage(id: String, text: String) {
        let messageData: [String: Any] = [
            "id": id,
            "text": text,
            "received": true,
            "timestamp": ServerValue.timestamp()
        ]
        db.child("messages").childByAutoId().setValue(messageData)
    }
    
    func readMessages(completion: @escaping ([Message]) -> Void) {
        db.child("messages").observe(.value, with: { snapshot in
            var messages = [Message]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let messageData = childSnapshot.value as? [String: Any],
                   let sender = messageData["id"] as? String,
                   let message = messageData["text"] as? String,
                   let received = messageData["received"] as? Bool,
                    let time = messageData["timestamp"] as? Date{
                    let chatMessage = Message(id: sender, text: message, received: received, timestamp: time)
                    messages.append(chatMessage)
                }
            }
            completion(messages)
        })
    }
    */
}
