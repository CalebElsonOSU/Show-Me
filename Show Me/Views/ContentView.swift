//
//  ContentView.swift
//  Show Me
//
//  Created by Caleb Elson on 3/2/22.
//

import SwiftUI
import RealityKit
import AVFoundation
import AVKit
import TextEntity
import Combine

class AppModel: ObservableObject {
    let showTimer = PassthroughSubject<Void, Never>()
    let showWrongAnswer = PassthroughSubject<Void, Never>()
    let showAnswer1 = PassthroughSubject<Void, Never>()
    let showAnswer2 = PassthroughSubject<Void, Never>()
    let showAnswer3 = PassthroughSubject<Void, Never>()
    let showAnswer4 = PassthroughSubject<Void, Never>()
    let showAnswer5 = PassthroughSubject<Void, Never>()
    let showAnswer6 = PassthroughSubject<Void, Never>()
    let showAnswer7 = PassthroughSubject<Void, Never>()
    let showAnswer8 = PassthroughSubject<Void, Never>()
    let resetGame = PassthroughSubject<Void, Never>()
}

struct ContentView : View {
    var currentGame: GameModel
    @Binding var isPresented: Bool
    @ObservedObject var model = AppModel()
    @State private var showHelp = false
    @State var currentAnswer = ""
    @State var showGameOver = false
    @State var showAlert = false
    var currentFound = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                ARViewContainer(currentGame: currentGame, model: model).edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    TextField("", text: $currentAnswer)
                        .placeholder(when: currentAnswer.isEmpty, placeholder: {
                            Text("Enter answer...")
                                .foregroundColor(.blue)
                        })
                    .foregroundColor(.white)
                    .onSubmit {
                        checkAnswer(answer: String(currentAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()))
                        currentAnswer = ""
                    }
                    .submitLabel(.done)
                    .multilineTextAlignment(.center)
                    .padding()
                }
            }
            
            
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button(action: {
                        showAlert = true
                    }, label: {
                        Text("Exit to main menu")
                    })
                    .alert("Are you sure you want to exit?", isPresented: $showAlert, actions: {
                        Button(role: .cancel, action: {}, label: {
                            Text("Cancel")
                        })
                        Button(role: .destructive, action: {
                            isPresented = false
                        }, label: {
                            Text("Exit")
                        })
                    }, message: {
                        Text("You will lose the current game")
                    })
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(action: {
                        showHelp.toggle()
                    }, label: {
                        Image(systemName: "questionmark.circle")
                    }).sheet(isPresented: $showHelp) {
                        HelpView()
                    }
                })
            }
            .sheet(isPresented: $showGameOver, onDismiss: {
                isPresented = false
            }, content: {
                GameOverView(currentGame: currentGame, showGameOver: $showGameOver)
            })
        }
    }
    
    func checkAnswer(answer: String) {
        if let index = currentGame.currentAnswers.firstIndex(where: { $0.answer == answer }) {
            switch index{
            case 0:
                model.showAnswer1.send()
            case 1:
                model.showAnswer2.send()
            case 2:
                model.showAnswer3.send()
            case 3:
                model.showAnswer4.send()
            case 4:
                model.showAnswer5.send()
            case 5:
                model.showAnswer6.send()
            case 6:
                model.showAnswer7.send()
            default:
                model.showAnswer8.send()
            }
            
            answerFound(score: currentGame.currentAnswers[index].score)
        }
    }
    
    func answerFound(score: Int) {
        currentGame.currentAnswered += 1
        currentGame.currentScore += score
        
        if currentGame.currentAnswered == currentGame.currentAnswers.count {
            currentGame.resetCurrentScore()
            
            if currentGame.isLastGame() {
                showGameOver = true
            } else {
                model.resetGame.send()
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .center,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    var currentGame: GameModel
    
    let model: AppModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        initiateGame(experience: boxAnchor)
        
        // MARK: - Combine triggers
        // TODO: Create timer/timer interactions
        model.showTimer.sink {
            boxAnchor.notifications.showTimer.post()
        }.store(in: &context.coordinator.subscriptions)
        
        // TODO: Create wrong answer trigger
        model.showWrongAnswer.sink {
        }.store(in: &context.coordinator.subscriptions)
        
        model.showAnswer1.sink {
            let answerAndScore = currentGame.currentAnswers[0]
            updateAnswerAndScore(answerBox: boxAnchor.answer1!, scoreBox: boxAnchor.score1!, answer: answerAndScore.answer, score: answerAndScore.score, scoreBoard: boxAnchor.currentScore!
                                 , totalScore: answerAndScore.score + currentGame.currentScore)
            boxAnchor.notifications.showMe1.post()
        }.store(in: &context.coordinator.subscriptions)
        
        model.showAnswer2.sink {
            let answerAndScore = currentGame.currentAnswers[1]
            updateAnswerAndScore(answerBox: boxAnchor.answer2!, scoreBox: boxAnchor.score2!, answer: answerAndScore.answer, score: answerAndScore.score, scoreBoard: boxAnchor.currentScore!, totalScore: answerAndScore.score + currentGame.currentScore)
            boxAnchor.notifications.showMe2.post()
        }.store(in: &context.coordinator.subscriptions)
        
        model.showAnswer3.sink {
            let answerAndScore = currentGame.currentAnswers[2]
            updateAnswerAndScore(answerBox: boxAnchor.answer3!, scoreBox: boxAnchor.score3!, answer: answerAndScore.answer, score: answerAndScore.score, scoreBoard: boxAnchor.currentScore!, totalScore: answerAndScore.score + currentGame.currentScore)
            boxAnchor.notifications.showMe3.post()
        }.store(in: &context.coordinator.subscriptions)
        
        model.showAnswer4.sink {
            let answerAndScore = currentGame.currentAnswers[3]
            updateAnswerAndScore(answerBox: boxAnchor.answer4!, scoreBox: boxAnchor.score4!, answer: answerAndScore.answer, score: answerAndScore.score, scoreBoard: boxAnchor.currentScore!, totalScore: answerAndScore.score + currentGame.currentScore)
            boxAnchor.notifications.showMe4.post()
        }.store(in: &context.coordinator.subscriptions)
        
        model.showAnswer5.sink {
            let answerAndScore = currentGame.currentAnswers[4]
            updateAnswerAndScore(answerBox: boxAnchor.answer5!, scoreBox: boxAnchor.score5!, answer: answerAndScore.answer, score: answerAndScore.score, scoreBoard: boxAnchor.currentScore!, totalScore: answerAndScore.score + currentGame.currentScore)
            boxAnchor.notifications.showMe5.post()
        }.store(in: &context.coordinator.subscriptions)
        
        model.showAnswer6.sink {
            let answerAndScore = currentGame.currentAnswers[5]
            updateAnswerAndScore(answerBox: boxAnchor.answer6!, scoreBox: boxAnchor.score6!, answer: answerAndScore.answer, score: answerAndScore.score, scoreBoard: boxAnchor.currentScore!, totalScore: answerAndScore.score + currentGame.currentScore)
            boxAnchor.notifications.showMe6.post()
        }.store(in: &context.coordinator.subscriptions)
        
        model.showAnswer7.sink {
            let answerAndScore = currentGame.currentAnswers[6]
            updateAnswerAndScore(answerBox: boxAnchor.answer7!, scoreBox: boxAnchor.score7!, answer: answerAndScore.answer, score: answerAndScore.score, scoreBoard: boxAnchor.currentScore!, totalScore: answerAndScore.score + currentGame.currentScore)
            boxAnchor.notifications.showMe7.post()
        }.store(in: &context.coordinator.subscriptions)
        
        model.showAnswer8.sink {
            let answerAndScore = currentGame.currentAnswers[7]
            updateAnswerAndScore(answerBox: boxAnchor.answer8!, scoreBox: boxAnchor.score8!, answer: answerAndScore.answer, score: answerAndScore.score, scoreBoard: boxAnchor.currentScore!, totalScore: answerAndScore.score + currentGame.currentScore)
            boxAnchor.notifications.showMe8.post()
        }.store(in: &context.coordinator.subscriptions)
        
        model.resetGame.sink {
            currentGame.nextGame()
            boxAnchor.notifications.resetGame.post()
            updateBoardsData(experience: boxAnchor)
        }.store(in: &context.coordinator.subscriptions)
        
        updateBoardsData(experience: boxAnchor)
        
        return arView
    }
    
    // MARK: - UI update methods
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func updateAnswerAndScore(answerBox: Entity, scoreBox: Entity, answer: String, score: Int, scoreBoard: Entity, totalScore: Int) {
        answerBox.children[3].children[0].children[0].components.removeAll()
        answerBox.children[3].children[0].children[0].children.removeAll()
        answerBox.children[3].children[0].children[0].addChild(TextEntity(text: answer, color: .white, isMetallic: false))
        
        scoreBox.children[3].children[0].children[0].components.removeAll()
        scoreBox.children[3].children[0].children[0].children.removeAll()
        scoreBox.children[3].children[0].children[0].addChild(TextEntity(text: String(score), color: .white, isMetallic: false))
        
        scoreBoard.children[3].children[0].children[0].components.removeAll()
        scoreBoard.children[3].children[0].children[0].children.removeAll()
        scoreBoard.children[3].children[0].children[0].addChild(TextEntity(text: String(totalScore), color: .white, isMetallic: false))
    }
    
    func updateBoardsData(experience: Experience.Box) {
        let boards = [experience.board1!, experience.board2!, experience.board3!, experience.board4!, experience.board5!, experience.board6!, experience.board7!, experience.board8!]
        
        experience.questionBoard?.children[3].children[0].children[0].components.removeAll()
        experience.questionBoard?.children[3].children[0].children[0].children.removeAll()
        experience.questionBoard?.children[3].children[0].children[0].addChild(TextEntity(text: currentGame.currentQuestion, color: .white, isMetallic: false))
        
        for (index, board) in boards.enumerated() {
            if currentGame.currentAnswers.count > index {
                board.children[3].children[0].children[0].components.removeAll()
                board.children[3].children[0].children[0].children.removeAll()
                board.children[3].children[0].children[0].addChild(TextEntity(text: String(index + 1), color: .white, isMetallic: false))
            } else {
                board.children[3].children[0].children[0].components.removeAll()
            }
        }
    }
    
    // Called once at the start of the game
    // Initiates currentScoreText and sets currentScore to 0
    func initiateGame(experience: Experience.Box) {
        experience.currentScoreText?.children[3].children[0].children[0].components.removeAll()
        experience.currentScoreText?.children[3].children[0].children[0].children.removeAll()
        experience.currentScoreText?.children[3].children[0].children[0].addChild(TextEntity(text: "Current Score:", color: .white, isMetallic: false, alignment: .left))
        
        experience.currentScore?.children[3].children[0].children[0].components.removeAll()
        experience.currentScore?.children[3].children[0].children[0].children.removeAll()
        experience.currentScore?.children[3].children[0].children[0].addChild(TextEntity(text: "0", color: .white, isMetallic: false))
    }
    
    class Coordinator: NSObject {
        var subscriptions = Set<AnyCancellable>()
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView(currentGame: GameModel(gameData: []), isPresented: .constant(true))
    }
}
#endif
