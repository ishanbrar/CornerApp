//
//  UserProfile.swift
//  CornerApp
//
//  Created by Jar Jar on 8/2/25.
//


import Foundation

struct UserProfile: Codable {
    let uid: String
    let email: String
    let username: String

    var cornerButtonTaps: Int
    var likedFacts: [String]
    var dislikedFacts: [String]
    
    init(uid: String, email: String, username: String) {
        self.uid = uid
        self.email = email
        self.username = username

        self.cornerButtonTaps = 0
        self.likedFacts = []
        self.dislikedFacts = []
    }
}
