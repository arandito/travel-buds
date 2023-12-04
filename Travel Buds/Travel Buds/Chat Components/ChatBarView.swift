//
//  ChatBarView.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 12/3/23.
//

import SwiftUI

struct ChatBarView: View {
    
    @ObservedObject var cvm: ChatViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            
            TextEditor(text: $cvm.chatText)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.darkGray), lineWidth: 1)
                )
                .frame(maxHeight: 40)
                .padding()
            
            Button {
                cvm.handleSend()
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.purple)
            .cornerRadius(8)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

