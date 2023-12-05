import SwiftUI
import Combine

struct ChatBarView: View {
    
    @EnvironmentObject private var cvm: ChatViewModel
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        HStack {
            
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color.purple)
            
            CustomTextField(placeholder: Text("Enter your message here"), text: $cvm.chatText)
            
            Button {
                cvm.handleSend()
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.purple)
                    .cornerRadius(50)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color("Gray"))
        .cornerRadius(50)
        .padding()

    }
}
/*
struct ChatBarView_Previews: PreviewProvider {
    static var previews: some View {
        let cvm = ChatViewModel(groupId: "Group2")
        ChatView(cvm: cvm)
        return ChatBarView()
    }
}
*/

struct CustomTextField: View {
    var placeholder = Text("Enter here...")
    @Binding var text: String
    var editingChanged: (Bool) -> () = {_ in}
    var commit: () -> () = {}
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            TextEditor(text: $text)
                .padding(4)
                .frame(maxHeight: 50)
                .onTapGesture {
                    if text.isEmpty {
                        text = ""
                    }
                }
            
            if text.isEmpty {
                Text("Enter here...")
                    .foregroundColor(Color.gray)

            }

        }
        .onReceive(Just(text)) { _ in
            if text.isEmpty {
                text = ""
            }
        }
    }
}


