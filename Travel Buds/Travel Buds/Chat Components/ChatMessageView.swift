//
//  ChatMessageView.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 12/3/23.
//

import SwiftUI

struct ChatMessageView: View {
    
    let message: Message
    
    var body: some View {
        VStack {
            // if message.senderId == uvm.user?.uid {
            if message.senderId == FirebaseManager.shared.auth.currentUser?.uid {
                SentMessageBubble(message: message)
            } else {
                ReceivedMessageBubble(message: message)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    struct SentMessageBubble: View {
        
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
                
                Image(systemName: "person.fill")
            }
        }
    }
    
    struct ReceivedMessageBubble: View {
        
        let message: Message
        
        var body: some View {
            HStack {
                Image(systemName: "person.fill")
        
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
