//
//  addTripView.swift
//  Travel Buds
//
//  Created by Yongkang Lin on 11/30/23.
//
import SwiftUI
import Firebase
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
    
    struct addTripRequestBody: Codable {
        let uid, destination, interest, weekStartDate, weekEndDate : String
    }
    
    struct tripReturnBody: Codable {
        let group_id, pending_id : String
    }

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
        
        performPostRequest(uid: userId, destination: destination, interest: interest, weekStartDate: weekStartDate, weekEndDate: weekEndDate!)

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
    
    func performPostRequest(uid : String, destination : String , interest : String, weekStartDate : Date, weekEndDate : Date) {
        let url = URL(string: "https://makegroup-tiamo6beta-ue.a.run.app")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"

        let startDateString = dateFormatter.string(from: weekStartDate)
        let endDateString = dateFormatter.string(from: weekEndDate)

        let requestBody = addTripRequestBody(uid: uid, destination: destination, interest: interest, weekStartDate: startDateString, weekEndDate: endDateString)
        let jsonEncoder = JSONEncoder()

        do {
            let jsonData = try jsonEncoder.encode(requestBody)
            request.httpBody = jsonData
        } catch {
            print("Error encoding request body: \(error)")
            return
        }

        // Perform the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }

                // Handle the response data
                if let data = data {
                    do {
                        let responseData = try JSONDecoder().decode(tripReturnBody.self, from: data)
                        // Process the response data as needed
                        print(responseData)
                    } catch {
                        print("Error decoding response data: \(error)")
                    }
                }
            }
        task.resume()
    }
}



struct AddTripPreview: PreviewProvider {
    static var previews: some View {
        AddTripView()
    }
}

