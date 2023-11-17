//
//  ContentView.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 11/16/23.
//

import SwiftUI

struct ChatContentView: View {
    var messageArraySent = ["We have decided to create an app targeted towards connecting travelers on their journeys!"]
    var messageArrayReceived = ["Cool bro.", "Very cool bro."]
    
    var body: some View {
        VStack {
            VStack {
                TitleRow()
                
                ScrollView {
                    ForEach(messageArraySent, id: \.self) { text in
                        MessageBubble(message: Message(id: "12345", text: text, received: false, timestamp: Date()))
                    }
                    
                    ForEach(messageArrayReceived, id: \.self) { text in
                        MessageBubble(message: Message(id: "12345", text: text, received: true, timestamp: Date()))
                    }
                }
                .padding(.top, 10)
                .background(.white)
                .cornerRadius(30, corners: [.topLeft, .topRight])
            }
            .background(Color("Purple"))
            
            MessageField()
        }
    }
}

#Preview {
    ChatContentView()
}
