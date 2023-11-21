//
//  User.swift
//  Travel Buds
//
//  Created by Yongkang Lin on 11/17/23.
//
import Foundation

struct User {
    let email: String
    let userName: String
    let firstName: String
    let lastName: String
    let trips: [Trip]
}

struct Trip{
    let tripID: String
    let chatID: String?
    let location: String
    let interest: String
    let arrival: Date
    let departure: Date
}

