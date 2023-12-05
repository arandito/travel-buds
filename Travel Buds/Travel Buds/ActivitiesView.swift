//
//  ActivitiesView.swift
//  Travel Buds
//
//  Created by Isaac Romero on 12/1/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI


struct ActivitiesView: View{
    @State private var selectedDestination = "New York"
    @State private var selectedInterest = "Nature"
    
    @State private var activityList: [Activity] = []
    
    let destinationOptions = ["New York", "Barcelona", "Budapest", "Rome", "Paris"]
    let interestOptions = ["Night Life", "Museums", "Food", "Nature", "Shopping"]
    
    struct Activity {
        let activityName, address, description, photoURL : String
    }
    
    
    var body: some View {
            NavigationView {
                VStack{
                    Text("\(selectedInterest) in \(selectedDestination)")
                        .font(.title2)
                        .bold()
                        .frame(alignment: .topLeading)
                    
                    List(activityList, id: \.activityName) { activity in
                        NavigationLink(destination: ActivityDetailView(activity: activity)){
                            ActivityCellView(activity: activity)
                        }
                        .listRowBackground(Color.purple.opacity(0.2))
                    }
                    NavigationLink(destination: selectOptionsView(selectedCity: $selectedDestination, selectedInterest: $selectedInterest)){
                        Text("Search")
                    }
                    .frame(alignment: .trailing)
                    .bold()
                    .padding(10)
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(100)
                    Spacer()
                }
                .onAppear(){
                    fetchActivities()
                }
                .navigationTitle("Activities")
            }
            .accentColor(.purple)
    }
    
    func fetchActivities() {
        FirebaseManager.shared.firestore.collection("activities").document("\(self.selectedDestination)_\(self.selectedInterest)").getDocument { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let data = snapshot?.data() else {
                print("No data found.")
                return
            }
            
            // Access "activityList" directly from the fetched data
            if let activityList = data["activities"] as? [[String: Any]] {
                self.activityList = activityList.map { activityData in
                    let activityName = activityData["activityName"] as? String ?? ""
                    let address = activityData["address"] as? String ?? ""
                    let description = activityData["description"] as? String ?? ""
                    let photoURL = activityData["photoURL"] as? String ?? ""
                    
                    return Activity(activityName: activityName, address: address, description: description, photoURL: photoURL)
                }
            }
            else{
                print("Parse Error in Activity")
                return
            }
        }
    }
    
    struct ActivityCellView: View {
        let activity: Activity

        var body: some View {
            HStack {
                WebImage(url: URL (string:activity.photoURL))
                    .resizable() // Allows the image to be resizable
                    .scaledToFill() // Scales the image to fit within the frame
                    .frame(width: 100, height: 100) // Set the desired frame size
                    .clipShape(Circle()) // Optional: Clip the image into a circle
                    .overlay(Circle().stroke(Color.white, lineWidth: 4)) // Optional: Add a border to the circle
                    .shadow(radius: 10) // Optional: Add a shadow effect
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(activity.activityName)
                        .font(.title2)
                        .bold()
                    Text(activity.address)
                        .font(.subheadline)
                }
                .padding(10)
            }
        }
    }

    struct ActivityDetailView: View {
        let activity: Activity

        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                WebImage(url: URL (string:activity.photoURL))
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.high)
                    .antialiased(true)
                    .aspectRatio(contentMode: .fit)
                Text(activity.activityName)
                    .font(.title)
                Text(activity.address)
                    .font(.subheadline)
                Text(activity.description)
                    .font(.body)
                    .foregroundColor(.gray)

                // You can also display the photoURL here if you have an image component
                // Image(activity.photoURL)
                //     .resizable()
                //     .aspectRatio(contentMode: .fit)
                //     .frame(height: 200)
            }
            .padding(16)
            .navigationTitle(activity.activityName)
        }
    }
    
    struct selectOptionsView: View {
        
        @Binding var selectedCity: String
        @Binding var selectedInterest: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Select City")
                    .font(.headline)
                Picker("City", selection: $selectedCity) {
                    ForEach(ActivitiesView().destinationOptions, id: \.self) { city in
                        Text(city)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Text("Select Interest")
                    .font(.headline)
                Picker("Interest", selection: $selectedInterest) {
                    ForEach(ActivitiesView().interestOptions, id: \.self) { interest in
                        Text(interest)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(16)
            .background(Color.purple.opacity(0.1)) // Set the background color
            .navigationTitle("User Preferences")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}




struct ActivitiesPreview: PreviewProvider {
    static var previews: some View {
        ActivitiesView()
    }
}
