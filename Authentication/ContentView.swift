//
//  ContentView.swift
//  Authentication
//
//  Created by Developer on 1/19/22.
//

import SwiftUI
import OAuth2Authentication

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Authentication Testbed")
                .padding()
            
            Button("Log In")
            {
                let message = authenticate()
                print(message)
            }
        }
    }
    
    
    func authenticate() -> String {
        let bundleIdentifier = Bundle.main.bundleIdentifier!
        let authDomain = "github.com/login/oauth"
        let authorizeURL = "https://\(authDomain)/authorize"
        let tokenURL = "https://\(authDomain)/access_token"
        let clientId = "b2621d4a34d934a4528e"
        let redirectUri = "\(bundleIdentifier)://\(authDomain)/ios/\(bundleIdentifier)/callback"
        
        let params =
            OAuth2PKCEParameters(authorizeUrl: authorizeURL, tokenUrl: tokenURL, clientId: clientId, redirectUri: redirectUri, callbackURLScheme: bundleIdentifier)
            
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let authenticator = OAuth2PKCEAuthenticator(window: window!)
        
        var message = ""
        authenticator.authenticate(parameters: params) { result in

            switch result {
            case .success(let AccessTokenResponse):
                message = AccessTokenResponse.accessToken
            case .failure(let error):
                message = error.localizedDescription
            }
        }
        return message
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
