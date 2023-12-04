//
//  User.swift
//  Travel Buds
//
//  Created by Yongkang Lin on 11/17/23.
//
import Foundation

struct User {
    let uid: String
    let email: String
    let userName: String
    let firstName: String
    let lastName: String
    var profileImageUrl: String
    var groups: [String]
    var trips: [Trip]
}

struct PendingRequest{
    let uid: String
    let destination: String
    let interest: String
    let weekStartDate: String
    let weekEndDate: String
}

struct Trip{
    let chatID: String?
    let destination: String
    let interest: String
    let weekStartDate: Date
    let weekEndDate: Date
}
