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
    
    var body: some View {
        NavigationView {
            
            VStack {
                customNavBar
                messagesView
            }
            .navigationBarHidden(true)
        }
    }
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            if !viewModel.isLoggedOut {
                WebImage(url:URL(string:viewModel.user?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:50, height:50)
                    .clipped()
                    .cornerRadius(44)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.user?.firstName ?? "") \(viewModel.user?.lastName ?? "")")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.white)
                    HStack {
                        Circle()
                            .foregroundColor(.green)
                            .frame(width: 14, height: 14)
                            .padding(.trailing, -5)
                        Text("online")
                            .font(.system(size: 15))
                            .foregroundColor(Color.white)
                    }
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
        .fullScreenCover(isPresented: $viewModel.isLoggedOut, onDismiss: nil) {
            LoginView(isLoginCompleted: {
                self.viewModel.isLoggedOut = false
                self.viewModel.getCurrentUser()
            })
        }
        .background(viewModel.isLoggedOut ? Color.white : Color.purple)
    }
    
    private var messagesView: some View {
        if viewModel.isLoggedOut {
            return AnyView(Color.white.edgesIgnoringSafeArea(.all))
        } else {
            return AnyView(
                ScrollView {
                    ForEach(0..<10, id: \.self) { num in
                        VStack {
                            HStack(spacing: 16) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 32))
                                    .padding(8)
                                    .overlay(RoundedRectangle(cornerRadius: 44)
                                        .stroke(Color(.label), lineWidth: 1)
                                    )
                                VStack(alignment: .leading) {
                                    Text("Username")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("Message sent to user")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(.lightGray))
                                }
                                Spacer()
                                
                                Text("1d")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            Divider()
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        .padding(.top, num == 0 ? 16 : 0)
                        
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
