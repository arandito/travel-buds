//
//  ChatMessageView.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 12/3/23.
//

import SwiftUI
import FirebaseAuth
import SDWebImageSwiftUI

struct ChatMessageView: View {
    
    @EnvironmentObject private var uvm: UserViewModel
    
    let message: Message
    
    var body: some View {
        VStack {
            if message.senderId == uvm.user?.uid {
            // if message.senderId == FirebaseManager.shared.auth.currentUser?.uid {
                SentMessageBubble(message: message)
            } else {
                ReceivedMessageBubble(message: message)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    struct SentMessageBubble: View {
        
        @EnvironmentObject private var cvm: ChatViewModel
        @EnvironmentObject private var uvm: UserViewModel
        
        let message: Message
        
        var body: some View {
            HStack {
                Spacer()
                HStack {
                    Text(message.text)
                }
                .padding(10)
                .foregroundColor(.white)
                .background(Color.purple)
                .cornerRadius(15)
                .shadow(radius: 2, x: 0, y: 2)
                
                WebImage(url:URL(string:uvm.user?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipped()
                    .cornerRadius(44)
            }
        }
    }
    
    struct ReceivedMessageBubble: View {
        
        @EnvironmentObject private var cvm: ChatViewModel
        @EnvironmentObject private var uvm: UserViewModel
        
        let message: Message
        
        var body: some View {
            HStack {
                
                if let profileImageUrl = cvm.userImageURLs[message.senderId], !profileImageUrl.isEmpty {
                    WebImage(url: URL(string: profileImageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipped()
                        .cornerRadius(44)
                } else {
                    Image("person.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipped()
                        .cornerRadius(44)
                }
                
                HStack {
                    Text(message.text)
                }
                .padding(10)
                .foregroundColor(.white)
                .background(Color.gray)
                .cornerRadius(15)
                .shadow(radius: 2, x: 0, y: 2)
                
                Spacer()
            }
        }
    }
}


