//
//  Fact.swift
//  CornerApp
//
//  Created by Jar Jar on 8/2/25.
//


import Foundation

struct Fact: Codable {
    let id: String
    let text: String
    let category: String?
    let emojis: [String]?
    var factPack: String? // Track which fact pack this fact came from

    init(id: String = UUID().uuidString, text: String, category: String? = nil, emojis: [String]? = nil, factPack: String? = nil) {
        self.id = id
        self.text = text
        self.category = category
        self.emojis = emojis
        self.factPack = factPack
    }
}

