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
            VStack {
                MessagesView(cvm: cvm)
            }
            .navigationTitle(cvm.groupId ?? "")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
    struct MessagesView: View {
        @ObservedObject var cvm: ChatViewModel
        
        var body: some View {
            
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(cvm.chatMessages) { message in
                            ChatMessageView(cvm: cvm, message: message)
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
                    .onReceive(cvm.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
            .safeAreaInset(edge: .bottom) {
                ChatBarView(cvm: cvm)
                    .background(Color(.systemBackground))
            }
        }
    }
}

#if DEBUG
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let groupId = "Group2"
        let cvm = ChatViewModel(groupId: groupId)
        ChatView(cvm: cvm)
    }
}
#endif



