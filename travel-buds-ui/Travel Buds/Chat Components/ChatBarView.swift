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
                .frame(height: 52)
            
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
        let uvm = UserViewModel()
        // ChatView(cvm: cvm, uvm: uvm)
        return ChatBarView()
    }
}
 */


struct CustomTextField: View {
    var placeholder : Text
    @Binding var text: String
    var editingChanged: (Bool) -> () = {_ in}
    var commit: () -> () = {}
    
    var body: some View {
        ZStack(alignment: .leading) {
            /*
            ScrollView(.vertical, showsIndicators: false) {
                if text.isEmpty {
                    placeholder
                        .opacity(0.5)
                        .padding(.leading, 2)
                }
                TextField("", text: $text, axis: .vertical)
                    .frame(minHeight: 52)
            }
             */
            
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .background(.clear)
        }
    }
}


