//
//  ChatListView.swift
//  test
//
//  Created by Yuya Taniguchi on 11/19/23.
//

//
//  MainMessagesView.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 11/18/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatListView: View {
    
    @State var shouldShowLogOutOptions = false
    @ObservedObject private var viewModel = UserViewModel()
    @State private var isProfileImageLoaded = false
    @State private var shouldNavigateToChatView = false
    @State private var shouldNavigateToAddTripView = false
    @Environment(\.colorScheme) var colorScheme
    @State var chatViewModel = ChatViewModel(groupId:nil)
    
    var textForegroundColor: Color {
        return colorScheme == .dark ? Color.white : Color.black
    }
    
    var body: some View {
        NavigationView {
            VStack {
                navigationBar
                
                if !viewModel.isLoggedOut {
                    VStack(alignment: .leading) {
                        Text("Chats")
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(textForegroundColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
                    .padding(.bottom, 2)
                }
                
                listView
                
                NavigationLink("", isActive:$shouldNavigateToChatView){
                    ChatView(cvm: chatViewModel)
                }
                
                NavigationLink("", isActive:$shouldNavigateToAddTripView){
                    AddTripView()
                }
                .navigationBarBackButtonHidden(true)
            }
            .navigationBarHidden(true)
            
            .fullScreenCover(isPresented: $viewModel.isLoggedOut, onDismiss: nil) {
                LoginView(isLoginCompleted: {
                    self.viewModel.isLoggedOut = false
                    self.viewModel.getCurrentUser()
                    self.viewModel.getRecentMessages()
                })
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        
    }
    
    private var navigationBar: some View {
        HStack(spacing: 16) {
            if !viewModel.isLoggedOut {
                WebImage(url:URL(string:viewModel.user?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:56, height:56)
                    .clipped()
                    .cornerRadius(44)
                    .overlay(RoundedRectangle(cornerRadius: 64)
                        .stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.user?.firstName ?? "") \(viewModel.user?.lastName ?? "")")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.white)
                    
                    Text("\(viewModel.user?.userName ?? "")")
                        .font(.system(size: 17))
                        .foregroundColor(Color.white)
                }
                Spacer()
                Button {
                    shouldShowLogOutOptions.toggle()
                } label: {
                    Image(systemName: "lock")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.white)
                }
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    viewModel.handleSignOut()
                }),
                .cancel()
            ])
        }
        .onAppear {
            viewModel.getCurrentUser()
        }
        .background(viewModel.isLoggedOut ? Color.white : Color.purple)
    }
    
    private var listView: some View {
        if viewModel.isLoggedOut {
            return AnyView(Color.white.edgesIgnoringSafeArea(.all))
        } else {
            return AnyView(
                ScrollView {
                    if viewModel.recentMessages.isEmpty {
                        // Show a separate view for users with no chats
                        VStack {
                            Text("You currently have no group chats :(")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(textForegroundColor)
                                .padding(.top, 30)
                            Text("Add trips to meet fellow travelers!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(textForegroundColor)
                                .padding(.top, 0.4)


                            Button(action: {
                                self.shouldNavigateToAddTripView.toggle()
                            }) {
                                Text("Add Trip")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(16)
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal)
                        VStack{
                            Image("travelbudslogo")
                                .resizable()
                                .padding(.top, 80)
                                .ignoresSafeArea()
                        }
                        .padding(-15)
                    } else {
                        ForEach(Array(viewModel.recentMessages.enumerated()), id:\.1) { index, recentMessage in
                            VStack {
                                Button {
                                    chatViewModel = ChatViewModel(groupId: recentMessage.groupId)
                                    self.shouldNavigateToChatView.toggle()
                                } label: {
                                    HStack(spacing: 1.5) {
                                        WebImage(url: URL(string: recentMessage.url))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 64, height: 64)
                                            .clipped()
                                            .cornerRadius(64)
                                            .overlay(RoundedRectangle(cornerRadius: 64)
                                                .stroke(Color.purple, lineWidth: 3))
                                            .shadow(radius: 3)
                                        Spacer()
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(recentMessage.title)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(textForegroundColor)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text(recentMessage.text)
                                                .font(.system(size: 14))
                                                .multilineTextAlignment(.leading)
                                                .foregroundColor(Color(.systemGray))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .lineLimit(2)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(recentMessage.timeAgo)
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .padding(.vertical, 8)
                                }
                                Divider()
                            }
                            .padding(.horizontal)
                            .padding(.top, index == 0 ? 16 : 0)
                            
                        }
                        VStack{
                            Image("travelbudslogo")
                                .resizable()
                                .padding(.top, 80)
                                .ignoresSafeArea()
                        }
                        .padding(-15)
                    }
                    
                }.padding(.top, -8)
            )
        }
    }
}

struct GroupChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
            .preferredColorScheme(.light)
        }
}
