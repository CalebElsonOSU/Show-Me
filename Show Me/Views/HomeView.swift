//
//  HomeView.swift
//  Show Me
//
//  Created by Caleb Elson on 3/2/22.
//

import SwiftUI
import RealityKit

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
        let driveURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        
        // Create folder if it doesn't exist
        if !FileManager.default.fileExists(atPath: driveURL!.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: driveURL!, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        let fileURL = driveURL!.appendingPathComponent("io.json")
        let data = try? Data(contentsOf: fileURL)
        
        // Reset data to get a new currentGame
        if self.currentGame != nil {
            self.currentGame = nil
            do {
                try String(Int(numberOfRounds)).write(to: fileURL, atomically: true, encoding: .utf8)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        // If JSON decode fails, write number to file
        guard let gameData = try? JSONDecoder().decode([GameData].self, from: data!) else {
            do {
                try String(Int(numberOfRounds)).write(to: fileURL, atomically: true, encoding: .utf8)
            }
            catch {
                print(error.localizedDescription)
            }
            
            return
        }
        
        // Parse JSON, create currentGame object
        self.currentGame = GameModel(gameData: gameData)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

