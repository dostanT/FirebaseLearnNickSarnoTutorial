//
//  SignInAppleHelper.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 18.08.2025.
//

import Foundation
import AuthenticationServices
import CryptoKit
import SwiftUI



struct SignInWithAppleResult {
    let token: String
    let nonce: String
    let name: String?
    let email: String?
}


struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
         
    }
}

typealias SignInAppleCompletionHandler = (Result<SignInWithAppleResult, Error>) -> Void

@MainActor
final class SignInWithAppleHelper: NSObject {
    
    private var currentNonce: String?
    private var completionHandler: SignInAppleCompletionHandler? = nil
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
    func startSignInWithAppleFlow() async throws -> SignInWithAppleResult {
        try await withCheckedThrowingContinuation { continuation in
            self.startSignInWithAppleFlow { result in
                switch result{
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    @available(iOS 13, *)
    func startSignInWithAppleFlow(completion: @escaping SignInAppleCompletionHandler) {
        guard let topVC = Utilities.shared.topViewController() else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        completionHandler = completion
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = topVC
        authorizationController.performRequests()
    }
}


@available(iOS 13.0, *)
extension SignInWithAppleHelper: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let nonce = currentNonce,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completionHandler?(.failure(URLError(.badServerResponse)))
            return
        }
        //Тут вроде нужно держать данные пользователя в анонимности(что-то, где-то помню в что Apple указывала что требует что пользователи могли держать полную анонимность, и мы никак не должны нарушать их)
        let name = appleIDCredential.fullName?.givenName
        let email = appleIDCredential.email
        
        let tokens = SignInWithAppleResult(token: idTokenString, nonce: nonce, name: name, email: email)
        completionHandler?(.success(tokens))
    }

      func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
          completionHandler?(.failure(URLError(.cannotFindHost)))
      }
}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window!
    }
}
