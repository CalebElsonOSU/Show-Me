//
//  GameView.swift
//  Show Me 2
//
//  Created by Caleb Elson on 2/14/22.
//

import SwiftUI

struct GameView: View {
    @State var answer = ""
    @State var box1 = "???"
    @State var showHelp = false
    
    var body: some View {
        List {
            VStack {
                Text("Question prompt here")
                    .font(.system(size: 35))
                HStack {
                    Button(action: {}, label: {Text(box1)})
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        
                    Button(action: {}, label: {Text("???")})
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .background(.blue)
                .font(.system(size: 32))
                .buttonStyle(.borderedProminent)
                HStack {
                    Button(action: {}, label: {Text("???")})
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        
                    Button(action: {}, label: {Text("???")})
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .background(.blue)
                .font(.system(size: 32))
                .buttonStyle(.borderedProminent)
                HStack {
                    Button(action: {}, label: {Text("???")})
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        
                    Button(action: {}, label: {Text("???")})
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .background(.blue)
                .font(.system(size: 32))
                .buttonStyle(.borderedProminent)
                HStack {
                    Button(action: {}, label: {Text("???")})
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        
                    Button(action: {}, label: {Text("???")})
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .background(.blue)
                .font(.system(size: 32))
                .buttonStyle(.borderedProminent)
            }
            
            Section {
                TextField(
                    "Enter answer here...",
                    text: $answer
                )
                    .onSubmit {
                        box1 = "\(answer)   35"
                        answer = ""
                    }
            }
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
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
