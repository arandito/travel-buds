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
    
    @State private var showBadRequest = false
    @State private var showTripConfirmed = false
        
    
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
            Form{
                Section{
                    VStack{
                        Picker("Select Destination", selection: $selectedDestination) {
                            ForEach(destinationOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        Divider()
                        
                        Picker("Select Interest", selection: $selectedInterest) {
                            ForEach(interestOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()

                        
                        Divider()
                        
                        DatePicker("Select Week", selection: $weekStartDate, in: Date()..., displayedComponents: .date)
                            .onChange(of: weekStartDate) { newDate in
                                weekStartDate = findNextMonday(from: newDate); weekEndDate = addWeek(to: weekStartDate)!
                            }
                            .padding()
                    }
                }
                header: {
                    Text("Trip Details")
                }
                .listRowBackground(Color.purple.opacity(0.1))
                
                Section{
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            Text("\(selectedInterest) in \(selectedDestination) from \(weekStartDate.formatted(date: .abbreviated, time: .omitted)) to \(weekEndDate.formatted(date: .abbreviated, time: .omitted))")
                                .multilineTextAlignment(.center)
                                .font(.title3)
                            Spacer()
                        }
                        Spacer()
                        
                        Divider()
                        
                        VStack{
                            Spacer()
                            Button("Add Trip") {
                                addTrip()
                            }
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .cornerRadius(100)
                            NavigationLink(
                                destination: tripConfirmedView(destination: selectedDestination, interest: selectedInterest),
                                isActive: $showTripConfirmed,
                                label: { EmptyView() }
                                )
                            .hidden()
                        }
                    }
                }
                header: {
                    Text("Confirm Trip")
                }
                .listRowBackground(Color.purple.opacity(0.1))
                
            }
            .alert(isPresented: $showBadRequest) {
                        Alert(
                            title: Text("That Didn't Seem Right..."),
                            message: Text("You may have entered overlapping dates. Please try again!"),
                            dismissButton: .default(Text("OK")) {
                            }
                        )
            }
            .navigationTitle("Add Trip")
            .background(Color.purple.opacity(0.3))
            .accentColor(.blue)
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
        
        performPostRequest(uid: userId, destination: destination, interest: interest, weekStartDate: weekStartDate, weekEndDate: weekEndDate!)
    }
    
    func performPostRequest(uid : String, destination : String , interest : String, weekStartDate : Date, weekEndDate : Date) {
        
        var tripData: [String: Any] = [
            "userId": uid,
            "interest": interest,
            "weekStartDate": weekStartDate,
            "weekEndDate": weekEndDate,
            "destination": destination
        ]
        
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
                        print(data)
                        let responseData = try JSONDecoder().decode(tripReturnBody.self, from: data)
                        // Process the response data as needed
                        showTripConfirmed.toggle()
                        
                        let ref = FirebaseManager.shared.firestore.collection("users").document(uid)
                        tripData = [
                            "interest": interest,
                            "weekStartDate": weekStartDate,
                            "chatId": "",
                            "destination": destination,
                            "weekEndDate": weekEndDate
                        ]

                        ref.updateData([
                            "trips": FieldValue.arrayUnion([tripData])
                        ])
                        print(responseData)
                    } catch {
                        DispatchQueue.main.async {
                            showBadRequest.toggle()
                        }
                        print("Error decoding response data: \(error)")
                    }
                }
            }
        task.resume()
    }
    
    struct tripConfirmedView: View{
        var destination = String()
        var interest = String()
        @State private var imageURL: String?
        
        var body: some View{
            VStack{
                Text("Your Trip to \(destination) Has Been Confirmed!")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .bold()
                    .multilineTextAlignment(.center)
                
                if let imageURL = imageURL {
                    WebImage(url: URL(string: imageURL))
                        .resizable()
                        .scaledToFit()
                } else {
                    Image("travelbudslogo")
                        .resizable()
                        .scaledToFit()
                }
            }
            .onAppear {
                getImage(destination: destination, interest: interest) { url in
                    if let url = url {
                        imageURL = url
                    }
                }
            }
        }
        func getImage(destination: String, interest: String, completion: @escaping (String?) -> Void) {
            FirebaseManager.shared.firestore.collection("tripImages").document(destination + "_" + interest).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching city image URL for \(destination): \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let data = snapshot?.data(), let Url = data["URL"] as? String {
                    completion(Url)
                } else {
                    completion(nil)
                }
            }
            }
            }
        }


struct AddTripPreview: PreviewProvider {
    static var previews: some View {
        AddTripView()
    }
}

