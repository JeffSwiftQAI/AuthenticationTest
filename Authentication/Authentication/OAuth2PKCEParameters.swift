//
//  OAuth2PKCEParameters.swift
//  Authentication
//
//  Created by Developer on 1/20/22.
//

import Foundation

public struct OAuth2PKCEParameters {
    public var authorizeUrl: String
    public var tokenUrl: String
    public var clientId: String
    public var redirectUri: String
    public var callbackURLScheme: String
}
