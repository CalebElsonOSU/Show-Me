//
//  HelpView.swift
//  Show Me
//
//  Created by Caleb Elson on 3/2/22.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack {
            Text("""
**Getting started:**

    Choose how many rounds you would like to play and tap \"Get game data\" button to get the questions and answers for this game. You will not be able to start a game until data is retrieved
            
    Once data is retrieved, the \"Start Game\" button is enabled. Be sure to enable any requested permissions - tap below to confirm that all required permissions are allowed
""")
            Link("\nChange permissions", destination: URL(string: UIApplication.openSettingsURLString)!)
            
            Spacer()
            
            Text("""
**Playing the game:**

    Enter your best guess for what was the most popular response to the prompt - the more popular the answer, the more points you get!
            
    Your guess can either be typed by tapping on the \"Enter answer...\" button, or spoken by holding down the red record button

    Once all of the rounds have been played, you will be presented with your total score. Good luck!
""")
            
            Spacer()
        }
        .padding()
    }
    
    func openSettings(url: URL) {
        UIApplication.shared.open(url)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
