//
//  TitleRow.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 11/16/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct TitleRow: View {
    
    @EnvironmentObject private var cvm: ChatViewModel
    @EnvironmentObject private var uvm: UserViewModel
    
    var body: some View {
        let name = cvm.groupId ?? "Default Group ID"
        HStack {
            WebImage(url:URL(string:uvm.user?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width:50, height:50)
                .clipped()
                .cornerRadius(44)
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.black)
            }
            Spacer()
            
        }
        .padding()
        .background(Color.white)
    }
        
}
    
/*
struct TitleRow_Previews: PreviewProvider {
    static var previews: some View {
        // ChatView(cvm: cvm)
        return TitleRow()
    }
}
*/
