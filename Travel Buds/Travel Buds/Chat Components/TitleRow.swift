//
//  TitleRow.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 11/16/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct TitleRow: View {
    
    @EnvironmentObject private var cvm: ChatViewModel
    @EnvironmentObject private var uvm: UserViewModel
    
    var body: some View {
        // let name = cvm.groupId ?? "Default Group ID"
        
        if let recentMessage = uvm.recentMessages.first(where: { $0.groupId == cvm.groupId }) {
            
            let title = recentMessage.title.isEmpty ? "Random Chat" : recentMessage.title
            let url = recentMessage.url.isEmpty ? "" : recentMessage.url
            
            HStack {
                if url == "" {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipped()
                        .cornerRadius(44)
                        .overlay(RoundedRectangle(cornerRadius: 44)
                            .stroke(Color.purple, lineWidth: 3))
                        .shadow(radius: 3)
                } else {
                    WebImage(url: URL(string: url))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipped()
                        .cornerRadius(44)
                        .overlay(RoundedRectangle(cornerRadius: 44)
                            .stroke(Color.purple, lineWidth: 3))
                        .shadow(radius: 3)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.black)
                }
                Spacer()
                
            }
            .padding()
            .background(Color.purple.opacity(0.5))
            
        } else {
            HStack {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width:50, height:50)
                    .clipped()
                    .cornerRadius(44)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Group Chat")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.black)
                }
                Spacer()
                
            }
            .padding()
            .background(Color.purple)
            
        }
        
        
    }
        
}
    
/*
struct TitleRow_Previews: PreviewProvider {
    static var previews: some View {
        // ChatView(cvm: cvm)
        return TitleRow()
    }
}
*/
