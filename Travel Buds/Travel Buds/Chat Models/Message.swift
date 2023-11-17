//
//  Message.swift
//  Travel Buds
//
//  Created by Yuya Taniguchi on 11/16/23.
//

import Foundation

struct Message: Identifiable, Codable {
    var id : String
    var text : String
    var received : Bool
    var timestamp : Date
}
