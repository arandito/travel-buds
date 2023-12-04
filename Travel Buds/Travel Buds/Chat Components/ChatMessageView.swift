//
//  ChatMessageView.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 12/3/23.
//

import SwiftUI

struct ChatMessageView: View {
    
    @ObservedObject var cvm: ChatViewModel
    let message: Message
    
    var body: some View {
        VStack {
            if message.senderId == FirebaseManager.shared.auth.currentUser?.uid {
                SentMessageView(message: message)
            } else {
                ReceivedMessageView(message: message)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    
    struct SentMessageView: View {
        
        let message: Message
        
        var body: some View {
            HStack {
                Spacer()
                HStack {
                    Text(message.text)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.purple)
                .cornerRadius(8)
                
                Image(systemName: "person.fill")
            }
        }
    }
    
    struct ReceivedMessageView: View {
        
        let message: Message
        
        var body: some View {
            HStack {
                Image(systemName: "person.fill")
                
                HStack {
                    Text(message.text)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.gray)
                .cornerRadius(8)
                
                Spacer()
            }
        }
    }
}

