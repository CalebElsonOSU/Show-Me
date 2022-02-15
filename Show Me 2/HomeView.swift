//
//  HomeView.swift
//  Show Me
//
//  Created by Caleb Elson on 2/14/22.
//

import SwiftUI

struct HomeView: View {
    @State var startGame = false
    @State var slider = 5.0
    @State var showHelp = false
    
    var body: some View {
        NavigationView {
            VStack{
                Spacer()
                Spacer()
                
                Slider(value: $slider, in: 0...10, step: 1) {
                    Text("Slider value: \(slider)")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("10")
                }
                Text("Question count: \(slider, specifier: "%.f")")
                
                Spacer()
                
                NavigationLink {
                    GameView()
                } label: {
                    Text("Start Game")
                }
                
                .navigationTitle("Main Menu")
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
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            HomeView().preferredColorScheme($0)
        }
    }
}
