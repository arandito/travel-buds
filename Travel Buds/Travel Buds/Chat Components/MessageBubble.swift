//
//  MessageBubble.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 11/16/23.
//

import SwiftUI

struct MessageBubble: View {
    var message: Message
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
    @State private var showTime = false
    @State private var showAlert = false
    @State private var isMenuVisible = false
    @State private var selectedLanguage = "es"
    @State private var translationInfo: TranslationInfo?

    var body: some View {
        VStack(alignment: message.senderId == FirebaseManager.shared.auth.currentUser?.uid ? .leading : .trailing) {
            HStack {
                Text(message.text)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(message.senderId == FirebaseManager.shared.auth.currentUser?.uid ? Color.gray : Color.purple)
                    .cornerRadius(15)
                    .shadow(radius: 2, x: 0, y: 2)
                    .gesture(
                        LongPressGesture(minimumDuration: 1.0)
                            .onEnded { _ in
                                isMenuVisible.toggle()
                            }
                    )
            }
            .frame(maxWidth: 300, alignment: message.senderId == FirebaseManager.shared.auth.currentUser?.uid ? .leading : .trailing)
            .onTapGesture {
                showTime.toggle()
            }

            if showTime {
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(message.senderId == FirebaseManager.shared.auth.currentUser?.uid ? .leading : .trailing, 25)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.senderId == FirebaseManager.shared.auth.currentUser?.uid ? .leading : .trailing)
        .padding(message.senderId == FirebaseManager.shared.auth.currentUser?.uid ? .leading : .trailing)
        .padding(.horizontal, 10)
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
            .padding(.horizontal, 10)
        }
    }

    private func translateMessage() {
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


struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        let docId = "12345"
        let data = ["senderId": "12345", "text": "Hewwo! My name is Beny :)", "timestamp": Date()] as [String : Any]
        let message = Message(documentId: docId, data: data)
        MessageBubble(message: message)
    }
}
