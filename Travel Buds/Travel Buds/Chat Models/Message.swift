//
//  Message.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 11/16/23.
//

import SwiftUI
import Firebase

struct Message: Identifiable {
    var id: String { documentId }
    let documentId, groupId, senderId, text: String
    let timestamp: Date

    init(documentId: String, data: [String : Any]) {
        self.documentId = documentId
        self.groupId = data["groupId"] as? String ?? ""
        self.senderId = data["senderId"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let timestampString = data["timestamp"] as? String ?? ""
        if let date = dateFormatter.date(from: timestampString) {
            self.timestamp = date
        } else {
            self.timestamp = Date()
        }
    }
}
