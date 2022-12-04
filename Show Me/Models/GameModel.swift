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
    var guessedAnswers: [Bool]
    var gameScore: Int
    var currentScore: Int
    
    init(gameData: [GameData]) {
        self.gameCounter = 0
        self.gameScore = 0
        self.currentScore = 0
        self.allGames = gameData
        self.currentGame = self.allGames[self.gameCounter]
        self.currentQuestion = self.currentGame.question.original
        self.currentAnswers = self.currentGame.answers.raw.sorted(by: { $0.value > $1.value }).map { (answer: $0.key, score: $0.value) }
        self.guessedAnswers = Array(repeating: false, count: currentAnswers.count)
    }
    
    // Return either the index of the correctly guessed answer, or a nil which is interpreted as a wrong answer
    //  in the AR view
    func checkAnswer(answer: String) -> Int? {
        let answerNumber = self.currentAnswers.firstIndex(where: { answer.contains($0.answer) })
        
        if let answerNumber {
            if guessedAnswers[answerNumber] == false {
                guessedAnswers[answerNumber] = true
                self.currentScore += currentAnswers[answerNumber].score
            } else {
                // Answer found previously
                return nil
            }
        }
        
        return answerNumber
    }
    
    func isGameOver() -> Bool {
        return !guessedAnswers.contains(false)
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
