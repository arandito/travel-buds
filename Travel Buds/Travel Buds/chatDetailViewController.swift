//
//  chatDetailViewController.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 11/9/23.
//


import UIKit
import FirebaseAuth
import FirebaseDatabase

class chatDetailViewController: UIViewController {
    
    @IBOutlet weak var interest: UILabel!
    var interestLabel: String = ""

    class FirebaseManager: NSObject {
        let auth: Auth
        let db: DatabaseReference
        
        static let shared = FirebaseManager()
        
        override init(){
            self.auth = Auth.auth()
            self.db = Database.database().reference()
            super.init()
        }
        
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemPurple.withAlphaComponent(1)


        self.interest.text = interestLabel
        // Do any additional setup after loading the view.
    }
    
    //if you want to use the send and read message function of the firebasemanager
    //do FirebaseManager.shared.readMessages{{ messages in
    //for message in messages {
    // do stuff
    //  }
    //}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

