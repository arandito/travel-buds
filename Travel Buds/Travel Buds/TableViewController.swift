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
    var user: User? = nil
    
    override func viewDidLoad(){
        print("view loaded")
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
                if let TableViewController = segue.destination as? TableViewController {
                    print("")
                }
            }
        }
    }
    
    func populateData(){
        print("data population started")
        let uid = FirebaseManager.shared.auth.currentUser?.uid ?? ""
        print(uid)
        let userRef = FirebaseManager.shared.firestore.collection("users").document(uid)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("document exists")
                let userData = document.data()
                    self.user = User(
                        email: userData!["email"] as? String ?? "",
                        userName: userData!["userName"] as? String ?? "",
                        firstName: userData!["firstName"] as? String ?? "",
                        lastName: userData!["lastName"] as? String ?? "",
                        trips: (userData!["trips"] as? [[String: Any]] ?? []).compactMap { tripData in
                            return Trip(
                                tripID: tripData["tripId"] as? String ?? "",
                                chatID: tripData["chatId"] as? String,
                                location: tripData["location"] as? String ?? "",
                                interest: tripData["interest"] as? String ?? "",
                                arrival: tripData["arrival"] as? Date ?? Date(),
                                departure: tripData["departure"] as? Date ?? Date()
                            )
                        }
                        )
                    }
            print(self.user?.email)
            print(self.user?.userName)
            print(self.user?.firstName)
            print(self.user?.lastName)
            print(self.user?.trips)
        }
    }
}
