//
//  ChatMessageView.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 12/3/23.
//

import SwiftUI
import FirebaseAuth
import SDWebImageSwiftUI

struct ChatMessageView: View {
    
    @EnvironmentObject private var uvm: UserViewModel
    
    let message: Message
    
    var body: some View {
        VStack {
            if message.senderId == uvm.user?.uid {
            // if message.senderId == FirebaseManager.shared.auth.currentUser?.uid {
                SentMessageBubble(message: message)
            } else {
                ReceivedMessageBubble(message: message)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    struct SentMessageBubble: View {
        
        @EnvironmentObject private var cvm: ChatViewModel
        @EnvironmentObject private var uvm: UserViewModel
        
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
                
                
                if let profileImageUrl = uvm.user?.profileImageUrl, !profileImageUrl.isEmpty {
                    WebImage(url: URL(string: profileImageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipped()
                        .cornerRadius(44)
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipped()
                        .cornerRadius(44)
                }
                
                /*
                WebImage(url:URL(string:uvm.user?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipped()
                    .cornerRadius(44)
                */
                
            }
        }
    }
    
    struct ReceivedMessageBubble: View {
        
        let message: Message
        let translator = Translate()
        let languageOptions: [String: String] = [
            "English": "en",
            "Espanol": "es",
            "français": "fr",
            "中文": "zh-cn",
            "عربي": "ar",
            "Türkçe": "tr",
            "Thai": "th",
            "Vietnamese": "vi",
            "Ukrainian": "uk",
            "Swedish": "sv",
            "Russian": "ru",
            "Romanian": "ro",
            "Norwegian": "no",
            "Japanese": "ja",
            "Hungarian": "hu",
            "Czech": "cs",
            "Filipino": "fil",
            "German": "de",
            "Greek": "el",
            "Hindi": "hi",
            "Hebrew": "iw",
            "Icelandic": "is",
            "Italian": "it",
            "Korean": "ko"
        ]
        @State private var showAlert = false
        @State private var isMenuVisible = false
        @State private var selectedLanguage = "es"
        @State private var translationInfo: TranslationInfo?
        @EnvironmentObject private var cvm: ChatViewModel
        @EnvironmentObject private var uvm: UserViewModel
        
        var body: some View {
            HStack {
                
                if let profileImageUrl = cvm.userImageURLs[message.senderId], !profileImageUrl.isEmpty {
                    WebImage(url: URL(string: profileImageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipped()
                        .cornerRadius(44)
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipped()
                        .cornerRadius(44)
                }
                
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
            .gesture(
                LongPressGesture(minimumDuration: 1.0)
                    .onEnded { _ in
                        isMenuVisible.toggle()
                    }
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Translated from \(translationInfo?.source_language ?? "Unknown")"),
                    message: Text(translationInfo?.trans ?? "Unable to translate"),
                    dismissButton: .default(Text("OK"))
                )
            }
            if isMenuVisible {
                Menu("Select Language") {
                    ForEach(languageOptions.sorted(by: { $0.key > $1.key }), id: \.key) { (displayName, languageCode) in
                        Button(action: {
                            selectedLanguage = languageCode
                            translateMessage()
                            isMenuVisible = false
                        }) {
                            Text(displayName)
                        }
                    }
                }
            }
        }
        func translateMessage() {
            translator.translate(text: message.text, targetLanguage: selectedLanguage) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let translatedJSON):
                        do {
                            let decoder = JSONDecoder()
                            self.translationInfo = try decoder.decode(TranslationInfo.self, from: translatedJSON.data(using: .utf8)!)
                            showAlert = true
                        } catch {
                            print("Decoding error: \(error)")
                            self.translationInfo = nil
                            showAlert = true
                        }

                    case .failure(let error):
                        print("Translation error: \(error)")
                        self.translationInfo = nil
                        showAlert = true
                    }
                }
            }
        }
    }
}


