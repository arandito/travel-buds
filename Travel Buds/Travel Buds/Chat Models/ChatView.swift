//
//  ChatView.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 12/3/23.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI


struct ChatView: View {
    
    @ObservedObject var cvm: ChatViewModel
    @ObservedObject var uvm: UserViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TitleRow()
                MessagesView()
            }
            .environmentObject(cvm)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .environmentObject(cvm)
        .environmentObject(uvm)
    }
    
    
    
    struct MessagesView: View {
        
        @EnvironmentObject private var cvm: ChatViewModel
        @EnvironmentObject private var uvm: UserViewModel
        
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
                            //withAnimation(.easeOut(duration: 0.5)) {
                            scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                            //}
                        }
                    }
                    .onChange(of: cvm.chatMessages.count) { _ in
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
        let uvm = UserViewModel()
        ChatView(cvm: cvm, uvm: uvm)
    }
}
#endif





