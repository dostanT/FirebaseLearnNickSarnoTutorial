//
//  SignInGoogleHopper.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 24.06.2025.
//
import Foundation
import Firebase
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}


final class SignInGoogleHelper {
    
    static let shared = SignInGoogleHelper()
    private init() {}
 
    func signInWithGoogle() async throws -> GoogleSignInResultModel {
        guard let clientID = FirebaseApp.app()?.options.clientID else { throw URLError(.badServerResponse) }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        
        //how we get top most viewController in swiftUI
        guard let topVC = await Utilities.shared.topViewController() else { throw URLError(.cannotFindHost) }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken: String = gidSignInResult.user.idToken?.tokenString else {throw URLError(.badServerResponse)}
        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        return tokens
    }
    
}
