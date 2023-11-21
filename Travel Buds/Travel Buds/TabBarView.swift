//
//  TabBarView.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 11/20/23.
//

import SwiftUI

struct TabBarView: View {
    
    var body: some View {
        TabView {

            ChatListView()
            .tabItem {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 30, weight: .bold))
            }

            NavigationView {
                Text("Activities")
                    .navigationTitle("Activities")
            }
            .tabItem {
                Image(systemName: "star.fill")
                    .font(.system(size: 30, weight: .bold))
            }
            
            NavigationView {
                Text("Add Trip")
                    .navigationTitle("Add Trip")
            }
            .tabItem {
                Image(systemName: "plus.app.fill")
                    .font(.system(size: 30, weight: .bold))
            }
           
            NavigationView {
                Text("Profile")
                    .navigationTitle("Profile")
            }
            .tabItem {
                Image(systemName: "person.fill")
                    .font(.system(size: 30, weight: .bold))
            }
            
            NavigationView {
                Text("Settings")
                    .navigationTitle("Settings")
            }
            .tabItem {
                Image(systemName: "gear")
                    .font(.system(size: 30, weight: .bold))
            }
        }
        .accentColor(.purple)
    }
}

#Preview {
    TabBarView()
        .preferredColorScheme(.light)
}

