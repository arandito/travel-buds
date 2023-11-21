//
//  AddTripController.swift
//  Travel Buds
//
//  Created by Yongkang Lin on 11/8/23.
//
import Firebase
import FirebaseAuth
import FirebaseStorage
import Foundation
import UIKit

class AddTripController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var location: UIPickerView!
    @IBOutlet weak var interest: UIPickerView!
    @IBOutlet weak var arrival: UIDatePicker!
    @IBOutlet weak var departure: UIDatePicker!

    
    let locationOption = ["New York", "Barcelona", "Budapest", "Rome", "Paris"]
    let interestOption = ["Night Life", "Museum and Culture", "Food", "Nature", "Shopping"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        location.delegate = self
        location.dataSource = self
        interest.delegate = self
        interest.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if pickerView == location {
                return locationOption.count
            } else if pickerView == interest {
                return interestOption.count
            }
            return 0
        }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == location {
            return locationOption[row]
        } else if pickerView == interest {
            return interestOption[row]
        }
        return nil
    }
    
    @IBAction func addTrip(_ sender: UIButton){
        let userId = FirebaseManager.shared.auth.currentUser?.uid ?? ""
        let location = locationOption[location.selectedRow(inComponent: 0)]
        let interest = interestOption[interest.selectedRow(inComponent: 0)]
        let arrival = arrival.date
        let departure = departure.date
        var tripData: [String: Any] = [
            "userId": userId,
            "interest": interest,
            "arrival": arrival,
            "departure": departure
        ]
        FirebaseManager.shared.firestore.collection("pending")
            .document(location).setData(tripData) { err in
                if let err = err {
                    print(err)
                    return
                }
                print("Success")
            }
        let ref = FirebaseManager.shared.firestore.collection("users").document(userId)
        tripData = [
            "interest": interest,
            "arrival": arrival,
            "departure": departure,
            "chatId": "",
            "tripId": "maybe we dont need this and can just use array index",
            "location": location
        ]
        ref.updateData([
            "trips": FieldValue.arrayUnion([tripData])
        ])
    }
}
