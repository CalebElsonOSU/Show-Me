//
//  GameOverView.swift
//  Show Me
//
//  Created by Caleb Elson on 3/15/22.
//

import SwiftUI

struct GameOverView: View {
    var currentGame: GameModel
    @Binding var showGameOver: Bool
    
    var body: some View {
        VStack {
            Text("Game Over")
            
            Spacer()
            
            Text("You scored: \(currentGame.gameScore)")
            
            Spacer()
            
            Button(action: {
                showGameOver = false
            }, label: {
                Text("Return to main menu")
            })
        }
        .padding()
    }
}

struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        GameOverView(currentGame: GameModel(gameData: []), showGameOver: .constant(true))
    }
}
