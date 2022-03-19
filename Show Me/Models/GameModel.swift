//
//  GameModel.swift
//  Show Me
//
//  Created by Caleb Elson on 3/14/22.
//

import SwiftUI

class GameModel {
    let allGames: [GameData]
    var currentGame: GameData
    var gameCounter: Int
    var currentQuestion: String
    var currentAnswers: [(answer: String, score: Int)]
    var gameScore: Int
    var currentScore: Int
    var currentAnswered: Int
    
    init(gameData: [GameData]) {
        self.gameCounter = 0
        self.gameScore = 0
        self.currentScore = 0
        self.currentAnswered = 0
        self.allGames = gameData
        self.currentGame = self.allGames[self.gameCounter]
        self.currentQuestion = self.currentGame.question.original
        self.currentAnswers = self.currentGame.answers.raw.sorted(by: { $0.value > $1.value }).map { (answer: $0.key, score: $0.value) }
    }
    
    func nextGame() {
        if !isLastGame() {
            self.gameCounter += 1
            self.currentGame = allGames[gameCounter]
            self.currentQuestion = self.currentGame.question.original
            self.currentAnswers = self.currentGame.answers.raw.sorted(by: { $0.value > $1.value }).map { (answer: $0.key, score: $0.value) }
            resetCurrentScore()
        } else {
            fatalError("Tried iterating out of game list bounds")
        }
    }
    
    func resetCurrentScore() {
        self.gameScore += self.currentScore
        self.currentScore = 0
    }
    
    func isLastGame() -> Bool {
        return gameCounter == allGames.count - 1
    }
}
