//
//  Authenticator.swift
//  Authenticates acces via OAuth2 and PKCE
//
//  Created by Developer on 1/19/22.
//

import AuthenticationServices
import CommonCrypto
import Foundation
import SwiftUI


public class OAuth2PKCEAuthenticator: NSObject {
    public func authenticate(parameters: OAuth2PKCEParameters, completion: @escaping (Result<AccessTokenResponse, OAuth2PKCEAuthenticatorError>) -> Void) {
        // create crypto-random code verifier
        let codeVerifier = self.createCodeVerifier()
        
        // create challenge
        let codeChallenge = self.codeChallenge(for: codeVerifier)
        
        // redierct user to auth server (with challenge
        let authSession = ASWebAuthenticationSession(
            url:URL(string: "\(parameters.authorizeUrl)?response_type=code&code_challenge=\(codeChallenge)&code_challenge_method=S256&client_id=\(parameters.clientId)&redirect_uri=\(parameters.redirectUri)")!,
            callbackURLScheme: parameters.callbackURLScheme) { optionalUrl, optionalError in
                guard optionalError == nil else { completion(.failure(.authRequestFailed(optionalError!))); return }
                guard let url = optionalUrl else { completion(.failure(.authorizedResponseNoUrl)); return }
                guard let code = url.getQueryStringParameter("code") else { completion(.failure(.authorizedResponseNoCode)); return }
                          
                self.getAccessToken(authCode: code, codeVerifier: codeVerifier, parameters: parameters, completion: completion)
            }
        
        authSession.presentationContextProvider = self
        authSession.start()
    }

    
    private func createCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return Data(_: buffer)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
    
    
    private func codeChallenge(for verifier: String) -> String {
        guard let data = verifier.data(using: .utf8) else {fatalError() }
        var buffer = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &buffer)
        }
        let hash = Data(_: buffer)
        return hash.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
    
    
    private func getAccessToken(authCode: String, codeVerifier: String, parameters: OAuth2PKCEParameters, completion: @escaping (Result<AccessTokenResponse, OAuth2PKCEAuthenticatorError>) -> Void) {
        let request = URLRequest.createTokenRequest(
            parameters: parameters,
            code: authCode,
            codeVerifier: codeVerifier)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                completion(.failure(OAuth2PKCEAuthenticatorError.tokenRequestFailed(error!)))
                return
            } else {
                guard let data = data else {
                    completion(.failure(OAuth2PKCEAuthenticatorError.tokenResponseNoData))
                    return
                
                }
                
                do {
                    let tokenResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: data)
                    completion(.success(tokenResponse))
                } catch {
                        let reason = String(data: data, encoding: .utf8) ?? "Unknown"
                        completion(.failure(OAuth2PKCEAuthenticatorError.tokenReponseInvalidData(reason)))
                    }
                }
            })
            dataTask.resume()
        }
    
    
    private func getQueryStringPArameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param})?.value
    }
}


// Access token reponse
//
public struct AccessTokenResponse: Codable {
    public var accessToken: String
    public var expiresIn: Int
}


// Extension of authenticator
//
extension OAuth2PKCEAuthenticator: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        return window ?? ASPresentationAnchor()
    }
}


// Extension of URL
//
fileprivate extension URL {
    func getQueryStringParameter(_ parameter: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == parameter })?.value
    }
}
 

// Extension of URL Request
//
fileprivate extension URLRequest {
    static func createTokenRequest(parameters: OAuth2PKCEParameters, code: String, codeVerifier: String) -> URLRequest {
        let request = NSMutableURLRequest(url: NSURL(string: "\(parameters.tokenUrl)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["content-type": "application/x-www-form-urlencoded"]
        request.httpBody = NSMutableData(data: "grant_type=authorization_code&client_id=\(parameters.clientId)&code_verifier=\(codeVerifier)&code=\(code)&redirect_uri=\(parameters.redirectUri)".data(using: String.Encoding.utf8)!) as Data
        return request as URLRequest
    }
}
