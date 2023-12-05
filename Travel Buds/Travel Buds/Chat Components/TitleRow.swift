//
//  TitleRow.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 11/16/23.
//

import SwiftUI

struct TitleRow: View {
    
    @EnvironmentObject private var cvm: ChatViewModel
    
    var body: some View {
        
        let name = cvm.groupId ?? "Default Group ID"
        HStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.title).bold()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            /*
            Image(systemName: "phone.fill")
                .foregroundColor(.gray)
                .padding(10)
                .background(.white)
                .cornerRadius(50)
            */
        }
        .padding()
        .background(Color.purple)
    }
        
}


struct TitleRow_Previews: PreviewProvider {
    static var previews: some View {
        return TitleRow()
    }
}
