//
//  HomeView.swift
//  Show Me
//
//  Created by Caleb Elson on 3/2/22.
//

import SwiftUI
import RealityKit
import Speech

struct HomeView: View {
    @StateObject var cameraManager = CameraManager()
    @State private var isPresented = false
    @State private var showHelp = false
    @State private var currentGame: GameModel? = nil
    @State private var currentAnswer = ""
    @State private var numberOfRounds = 5.0
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Button("Get game data (required to play game)") {
                    getData()
                }
                
                Spacer()
                
                Slider(value: $numberOfRounds, in: 1...10, step: 1) {
                    Text("Number of rounds: \(numberOfRounds)")
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("10")
                }
                Text("Number of rounds: \(numberOfRounds, specifier: "%.f")")
                
                Spacer()
                
                Button (action: {
                    if currentGame != nil {
                        isPresented.toggle()
                        //ContentView(currentGame: currentGame!)
                    }
                }, label: {
                    Text("Start Game")
                })
                .onTapGesture {
                    if !cameraManager.permissionGranted {
                        cameraManager.requestPermission()
                    }
                }
                .fullScreenCover(isPresented: $isPresented, content: {
                    ContentView(currentGame: currentGame!, isPresented: $isPresented)
                })
                .disabled(currentGame == nil)
            }
            .toolbar{
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
        }
        .padding()
    }
    
    // MARK: - Pull and parse JSON
    func getData() {
        requestTranscribePermissions()
        
        guard let path = Bundle.main.path(forResource: "dev.scraped", ofType: "json") else {
            print("json not found")
            return
        }
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let result = try! JSONDecoder().decode([GameData].self, from: data)
        
        // Parse JSON, create currentGame object
        self.currentGame = GameModel(gameData: result)
    }
    
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Good to go!")
                } else {
                    print("Transcription permission was declined.")
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

