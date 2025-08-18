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

/**
 * GoogleSignInResultModel - Модель данных для Google токенов аутентификации
 * 
 * Цель: Инкапсулировать токены, полученные от Google Sign-In
 * Полезность: Обеспечивает типобезопасность и структурированный доступ к Google токенам
 * Работа: Хранит idToken и accessToken, необходимые для аутентификации через Firebase
 */
struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}

/**
 * SignInGoogleHelper - Вспомогательный класс для Google Sign-In
 * 
 * Цель: Упростить процесс аутентификации через Google
 * Полезность: Инкапсулирует сложную логику Google Sign-In и предоставляет простой интерфейс
 * Работа: Использует паттерн Singleton для глобального доступа и координирует взаимодействие с Google SDK
 */
final class SignInGoogleHelper {
    
    static let shared = SignInGoogleHelper()
    private init() {}
 
    /**
     * signInWithGoogle() - Выполнение входа через Google
     * 
     * Цель: Получить токены аутентификации от Google
     * Полезность: Обеспечивает безопасный и удобный вход через Google аккаунт
     * Работа: Настраивает Google Sign-In, отображает диалог входа и возвращает токены для Firebase
     */
    @MainActor
    func signInWithGoogle() async throws -> GoogleSignInResultModel {
        guard let clientID = FirebaseApp.app()?.options.clientID else { throw URLError(.badServerResponse) }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        //how we get top most viewController in swiftUI
        guard let topVC = Utilities.shared.topViewController() else { throw URLError(.cannotFindHost) }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken: String = gidSignInResult.user.idToken?.tokenString else {throw URLError(.badServerResponse)}
        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        return tokens
    }
    
}
