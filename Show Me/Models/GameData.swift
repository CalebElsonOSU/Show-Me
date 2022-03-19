//
//  GameData.swift
//  Show Me
//
//  Created by Caleb Elson on 3/2/22.
//

import Foundation

struct GameData: Decodable {
    let question: Question
    let answers: Answer
    let metadata: [String:String]
    let num: [String:Int]
}

struct Answer: Decodable {
    let clusters: [String:Cluster]
    let raw: [String:Int]
}

struct Cluster: Decodable {
    let count: Int
    let answers: [String]
}

struct Raw: Decodable {
    let results: [String:Int]
}

struct Question: Decodable {
    let normalized: String
    let original: String
}
