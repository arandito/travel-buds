//
//  TravelBudsChatApp.swift
//  Travel Buds
//
//  Created by Antonio Aranda on 11/19/23.
//

import SwiftUI
import Firebase

@main
struct TravelBudsChatApp: App {
    init() {
        FirebaseApp.configure() // Call this to configure Firebase
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
        }
    }
}
