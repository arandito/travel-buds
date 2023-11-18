//
//  TableViewController.swift
//  Travel Buds
//
//  Created by Yongkang Lin on 11/8/23.
//
import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

class TableViewController: UITableViewController{
    
    var trips: [String] = []
    let user: User? = nil
    
    class FirebaseManager: NSObject {
        let auth: Auth
        let storage: Storage
        let firestore: Firestore
        
        static let shared = FirebaseManager()
        
        override init(){
            self.auth = Auth.auth()
            self.storage = Storage.storage()
            self.firestore = Firestore.firestore()
            super.init()
        }
    }
    
    override func viewDidLoad(){
        self.populateData()
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            self.performSegue(withIdentifier: "detailedChat", sender: self)
        }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailedChat" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selected = trips[indexPath.row]
                if let detailedViewController = segue.destination as? DetailedViewController {
                    print("")
                }
            }
        }
    }
    
    func populateData(){
        let uid = FirebaseManager.shared.auth.currentUser?.uid ?? ""
        let userRef = FirebaseManager.shared.firestore.collection("users").document(uid)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let userData = document.data(),
                    user = User(
                        email: userData!["email"] as? String ?? "",
                        userName: userData!["userName"] as? String ?? "",
                        firstName: userData!["firstName"] as? String ?? "",
                        lastName: userData!["lastName"] as? String ?? "",
                        trips: (userData!["trips"] as? [[String: Any]] ?? []).compactMap { tripData in
                            return Trip(
                                tripID: tripData["tripID"] as? String ?? "",
                                chatID: tripData["chatID"] as? String,
                                location: tripData["location"] as? String ?? "",
                                interest: tripData["interest"] as? String ?? "",
                                arrival: tripData["arrival"] as? Date ?? Date(),
                                departure: tripData["departure"] as? Date ?? Date()
                            )
                        }
                        )
                    }
        }
        print(user?.email)
        print(user?.userName)
        print(user?.firstName)
        print(user?.lastName)
        print(user?.trips)
    }
}
