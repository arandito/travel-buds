//
//  addTripView.swift
//  Travel Buds
//
//  Created by Yongkang Lin on 11/30/23.
//
import SwiftUI
import Firebase

struct AddTripView: View {
    @State private var selectedLocation = ""
    @State private var selectedInterest = ""
    @State private var arrivalDate = Date()
    @State private var departureDate = Date()

    let locationOptions = ["New York", "Barcelona", "Budapest", "Rome", "Paris"]
    let interestOptions = ["Night Life", "Museums", "Food", "Nature", "Shopping"]

    var body: some View {
        VStack {
            Picker("Location", selection: $selectedLocation) {
                ForEach(locationOptions, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Picker("Interest", selection: $selectedInterest) {
                ForEach(interestOptions, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            DatePicker("Arrival", selection: $arrivalDate, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .padding()

            DatePicker("Departure", selection: $departureDate, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .padding()

            Button("Add Trip") {
                addTrip()
            }
            .padding()
        }
        .padding()
    }

    func addTrip() {
        let userId = FirebaseManager.shared.auth.currentUser?.uid ?? ""
        let location = selectedLocation
        let interest = selectedInterest
        let arrival = arrivalDate
        let departure = departureDate

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
            "location": location
        ]

        ref.updateData([
            "trips": FieldValue.arrayUnion([tripData])
        ])
    }
}

struct AddTripPreview: PreviewProvider {
    static var previews: some View {
        AddTripView()
    }
}
