//
//  ContentView.swift
//  Authentication
//
//  Created by Developer on 1/19/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Authentication Testbed")
                .padding()
            
            Button("Log In")
            {
                //Authenticate()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
