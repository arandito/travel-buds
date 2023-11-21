//
//  ChatView.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 11/20/23.
//

import SwiftUI

struct ChatView: View {
    
    @State var chatText = ""
    
    var body: some View {
        
        VStack {
            ScrollView {
                ForEach(0..<10) { num in
                    
                    HStack {
                        Spacer()
                        HStack {
                            Text("MEASSAGE")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                }
                
                HStack { Spacer() }
                
            }
            .background(Color(.black))
            
            HStack {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.darkGray))
                TextField("Enter text here", text: $chatText)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.darkGray), lineWidth: 1)
                    )
                Button {
                    print("Message sent :)")
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
        
       
        .navigationTitle("My Chat")
            .navigationBarTitleDisplayMode(.inline)
    }
    
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView()
                .preferredColorScheme(.dark)
        }
    }
}

