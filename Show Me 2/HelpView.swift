//
//  HelpView.swift
//  Show Me 2
//
//  Created by Caleb Elson on 2/14/22.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        Form {
            
            Section {
                Text("Enter your best guess for what was the most popular response to the prompt")
            }
            Section {
                Text("The more popular the answer, the more points you get")
            }
            Section {
                Text("Whoever gets the most points wins!")
            }
            
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
