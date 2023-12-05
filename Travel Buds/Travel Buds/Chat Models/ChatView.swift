//
//  ChatView.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 12/3/23.
//

import SwiftUI
import Firebase


struct ChatView: View {
    
    @ObservedObject var cvm: ChatViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
<<<<<<< HEAD
                //TitleRow()
                MessagesView()
            }
            .navigationTitle(cvm.groupId ?? "")
            .navigationBarTitleDisplayMode(.inline)
=======
                TitleRow()
                MessagesView()
            }
>>>>>>> a4eb3d487d806c9a11af1c9f39c82a2974d05e00
            .environmentObject(cvm)
        }
    }
    
    
    struct MessagesView: View {
<<<<<<< HEAD
=======
        
>>>>>>> a4eb3d487d806c9a11af1c9f39c82a2974d05e00
        @EnvironmentObject private var cvm: ChatViewModel
        
        var body: some View {
            
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(cvm.chatMessages) { message in
                            ChatMessageView(message: message)
                        }
                        HStack { Spacer() }
                            .id("Empty")
                    }
                    .onAppear {
                        DispatchQueue.main.async {
                            withAnimation(.easeOut(duration: 0.5)) {
                                scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                            }
                        }
                    }
<<<<<<< HEAD
                    .onChange(of: cvm.count) { _ in
=======
                    .onChange(of: cvm.chatMessages.count) { _ in
>>>>>>> a4eb3d487d806c9a11af1c9f39c82a2974d05e00
                        withAnimation(.easeOut(duration: 0.5)) {
                            scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
            .safeAreaInset(edge: .bottom) {
                ChatBarView()
                    .background(Color(.systemBackground))
            }
        }
    }
}

#if DEBUG
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let cvm = ChatViewModel(groupId: "Group2")
        ChatView(cvm: cvm)
    }
}
#endif



