//
//  OAuth2PKCEAuthenticatorError.swift
//  Authentication
//
//  Created by Developer on 1/20/22.
//

import Foundation

public enum OAuth2PKCEAuthenticatorError : LocalizedError {
    case authRequestFailed(Error)
    case authorizedResponseNoUrl
    case authorizedResponseNoCode
    case tokenRequestFailed(Error)
    case tokenResponseNoData
    case tokenReponseInvalidData(String)
    
    var localizedDescription: String {
        switch self {
        case .authRequestFailed(let error):
            return "authorization request failed: \(error.localizedDescription)"
        case .authorizedResponseNoUrl:
            return "authorization reponse does not include a url"
        case .authorizedResponseNoCode:
            return "authorization reponse does not include a code"
        case .tokenRequestFailed(let error):
            return "token request failed: \(error.localizedDescription)"
        case .tokenResponseNoData:
            return "no data received as part of token response"
        case .tokenReponseInvalidData(let reason):
            return "invlaid data recieved as part of token reponse: \(reason)"
        }
    }
}
