//
//  AuthenticationViewModel.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 26.08.2025.
//
import Foundation
/**
 * AuthenticationViewModel - ViewModel для управления аутентификацией
 *
 * Цель: Обрабатывать логику аутентификации и управлять состоянием UI
 * Полезность: Разделяет бизнес-логику от UI, упрощает тестирование и поддерживает MVVM архитектуру
 * Работа: Координирует взаимодействие между UI и AuthenticationManager для Google Sign-In
 */

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    /**
     * signInWithGoogle() - Выполнение входа через Google
     *
     * Цель: Обработать процесс аутентификации через Google
     * Полезность: Предоставляет простой интерфейс для Google Sign-In в UI
     * Работа: Получает токены через SignInGoogleHelper и аутентифицирует пользователя через AuthenticationManager
     */
    func signInWithGoogle() async throws {
        let helper = SignInGoogleHelper.shared
        let tokens = try await helper.signInWithGoogle()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens )
        try await UserManager.shared.createNewUser(auth: authDataResult)
    }
    
    func signInWithApple() async throws {
        let helper = SignInWithAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        let authDataResult = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
        try await UserManager.shared.createNewUser(auth: authDataResult)
        
//        signInWithAppleHelper.startSignInWithAppleFlow { result in
//            switch result {
//                case .success(let tokens):
//                Task {
//                    do {
//                        try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
//                        self.didSignInWithApple = true
//                    } catch {
//
//                    }
//
//                }
//            case .failure(let error):
//                print("Error signing in: \(error)")
//            }
//        }
        
        
        /*
         
         */
    }
    
    func signInAnonymous() async throws {
        let authDataResult = try await AuthenticationManager.shared.signInAnonymous()
        try await UserManager.shared.createNewUser(auth: authDataResult)
    }
    
}
