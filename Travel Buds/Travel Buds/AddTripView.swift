//
//  addTripView.swift
//  Travel Buds
//
//  Created by Yongkang Lin on 11/30/23.
//
import SwiftUI
import Firebase
import MapKit
import SDWebImageSwiftUI

struct AddTripView: View {
    //destination and interest needs to be presetted to first value as UIPicker is presetted to first value
    @State private var selectedDestination = "New York"
    @State private var selectedInterest = "Night Life"
    @State private var weekStartDate = Date()
    @State private var weekEndDate = Date()
    
    @State private var showAlert = false
    
    let destinationOptions = ["New York", "Barcelona", "Budapest", "Rome", "Paris"]
    let interestOptions = ["Night Life", "Museums", "Food", "Nature", "Shopping"]

    var body: some View {
        NavigationView{
            VStack(spacing: 50) {
                HStack{
                    Text("Choose a destination")
                        .font(.headline)
                    Spacer()
                    Picker("Location", selection: $selectedDestination) {
                        ForEach(destinationOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Divider()
                
                HStack{
                    Text("Choose an interest")
                        .font(.headline)
                    Spacer()
                    Picker("Interest", selection: $selectedInterest) {
                        ForEach(interestOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Divider()

                
                HStack{
                    Text("Select the Week")
                        .bold()
                    Spacer()
                    DatePicker("Select a Monday", selection: $weekStartDate, in: Date()..., displayedComponents: .date)
                        .labelsHidden()
                        .onChange(of: weekStartDate) { newDate in
                            weekStartDate = findNextMonday(from: newDate); weekEndDate = addWeek(to: weekStartDate)!
                        }
                }
                
                Divider()
                HStack{
                    Text("Trip Week")
                        .bold()
                    
                    Spacer()
                    
                    Text("\(weekStartDate.formatted(date: .abbreviated, time: .omitted)) to \(weekEndDate.formatted(date: .abbreviated, time: .omitted))")
                }
                Button("Add Trip") {
                    addTrip()
                    showAlert.toggle()
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Trip Confirmed!"),
                        message: Text("Please sit tight while we match you with your groups"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .padding()
            }
            .navigationTitle("Add Trip")
        }
    }
        
    func addWeek(to date: Date) -> Date? {
        return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: date)
    }
    
    func findNextMonday(from date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear, .weekday], from: date)
    
        // Find the next Monday
        components.weekday = 2 // Monday
        components.hour = 0
        components.minute = 0
        components.second = 0

        guard let nextMonday = calendar.date(from: components) else {
            return date
        }

        return nextMonday
    }

    var formattedSelectedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: weekStartDate)
    }
    
    func addTrip() {
        let userId = FirebaseManager.shared.auth.currentUser?.uid ?? ""
        let destination = selectedDestination
        let interest = selectedInterest
        let weekStartDate = weekStartDate
        let weekEndDate = addWeek(to: weekStartDate)

        var tripData: [String: Any] = [
            "userId": userId,
            "interest": interest,
            "weekStartDate": weekStartDate,
            "weekEndDate": weekEndDate ?? "",
            "destination": destination
        ]

        FirebaseManager.shared.firestore.collection("pending")
            .document().setData(tripData) { err in
                if let err = err {
                    print(err)
                    return
                }
                print("Success")
            }

        let ref = FirebaseManager.shared.firestore.collection("users").document(userId)
        tripData = [
            "interest": interest,
            "weekStartDate": weekStartDate,
            "chatId": "",
            "destination": destination,
            "weekEndDate": weekEndDate ?? ""
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

