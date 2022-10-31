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
    let showAnswer = PassthroughSubject<Int?, Never>()
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
    @FocusState private var isTextFieldFocused: Bool
    var currentFound = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                ARViewContainer(currentGame: currentGame, model: model).edgesIgnoringSafeArea(.all)
                
                HStack(alignment: .bottom) {
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            //Place your action here
                        }) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.red)
                                .padding()
                        }
                        .disabled(isTextFieldFocused)
                        .opacity(isTextFieldFocused ? 0 : 1)
                        
                        TextField("", text: $currentAnswer)
                            .placeholder(when: currentAnswer.isEmpty, placeholder: {
                                Text("Enter answer...")
                                    .foregroundColor(.blue)
                            })
                        .foregroundColor(.white)
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            checkAnswer(answer: String(currentAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()))
                            currentAnswer = ""
                        }
                        .submitLabel(.done)
                        .multilineTextAlignment(.center)
                        .padding()
                    }

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
        let answerNumber = currentGame.currentAnswers.firstIndex(where: { $0.answer == answer })
        
        model.showAnswer.send(answerNumber)
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
        
        let answerBoards = [boxAnchor.answer1!, boxAnchor.answer2!, boxAnchor.answer3!, boxAnchor.answer4!, boxAnchor.answer5!, boxAnchor.answer6!, boxAnchor.answer7!, boxAnchor.answer8!]
        let scoreBoards = [boxAnchor.score1!, boxAnchor.score2!, boxAnchor.score3!, boxAnchor.score4!, boxAnchor.score5!, boxAnchor.score6!, boxAnchor.score7!, boxAnchor.score8!]
        let notifications = [boxAnchor.notifications.showMe1, boxAnchor.notifications.showMe2, boxAnchor.notifications.showMe3, boxAnchor.notifications.showMe4, boxAnchor.notifications.showMe5, boxAnchor.notifications.showMe6, boxAnchor.notifications.showMe7, boxAnchor.notifications.showMe8]
        
        // MARK: - Combine triggers
        // TODO: Create timer/timer interactions
        model.showTimer.sink {
            boxAnchor.notifications.showTimer.post()
        }.store(in: &context.coordinator.subscriptions)
        
        model.showAnswer.sink { answer in
            updateHostBoard(hostBoard: boxAnchor.hostBoard!, correctAnswer: answer != nil)
            
            if let answerNumber = answer {
                print("answer number: ", answerNumber)
                let answerAndScore = currentGame.currentAnswers[answerNumber]
                
                updateAnswerAndScore(answerBox: answerBoards[answerNumber], scoreBox: scoreBoards[answerNumber], answer: answerAndScore.answer, score: answerAndScore.score)
                updateScoreBoard(scoreBoard: boxAnchor.currentScore!, totalScore: answerAndScore.score + currentGame.currentScore)
                notifications[answerNumber].post()
            }

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
    
    func updateAnswerAndScore(answerBox: Entity, scoreBox: Entity, answer: String, score: Int) {
        answerBox.children[3].children[0].children[0].components.removeAll()
        answerBox.children[3].children[0].children[0].children.removeAll()
        answerBox.children[3].children[0].children[0].addChild(TextEntity(text: answer, color: .white, isMetallic: false))
        
        scoreBox.children[3].children[0].children[0].components.removeAll()
        scoreBox.children[3].children[0].children[0].children.removeAll()
        scoreBox.children[3].children[0].children[0].addChild(TextEntity(text: String(score), color: .white, isMetallic: false))
    }
    
    func updateHostBoard(hostBoard: Entity, correctAnswer: Bool) {
        hostBoard.children[5].children[0].children[0].components.removeAll()
        hostBoard.children[5].children[0].children[0].children.removeAll()
        
        let hostText = correctAnswer ? "That's a valid answer, good work!" : "Wrong answer, try again!"
        
        hostBoard.children[5].children[0].children[0].addChild(TextEntity(text: hostText, color: .white, isMetallic: false))
    }
    
    func updateScoreBoard(scoreBoard: Entity, totalScore: Int) {
        scoreBoard.children[4].children[0].children[0].components.removeAll()
        scoreBoard.children[4].children[0].children[0].children.removeAll()
        scoreBoard.children[4].children[0].children[0].addChild(TextEntity(text: String(totalScore), color: .white, isMetallic: false))
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
        experience.currentScoreText?.children[5].children[0].children[0].components.removeAll()
        experience.currentScoreText?.children[5].children[0].children[0].children.removeAll()
        experience.currentScoreText?.children[5].children[0].children[0].addChild(TextEntity(text: "Current Score:", color: .white, isMetallic: false, alignment: .left))
        
        experience.currentScore?.children[4].children[0].children[0].components.removeAll()
        experience.currentScore?.children[4].children[0].children[0].children.removeAll()
        experience.currentScore?.children[4].children[0].children[0].addChild(TextEntity(text: "0", color: .white, isMetallic: false))
        
        experience.hostBoard?.children[5].children[0].children[0].components.removeAll()
        experience.hostBoard?.children[5].children[0].children[0].children.removeAll()
        experience.hostBoard?.children[5].children[0].children[0].addChild(TextEntity(text: "Greetings, welcome to Show Me!", color: .white, isMetallic: false))
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
