//
//  SignInEmailViewModel.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 26.08.2025.
//
import Foundation
/**
 * SignInEmailViewModel - ViewModel для управления email аутентификацией
 *
 * Цель: Обрабатывать логику входа и регистрации пользователей через email
 * Полезность: Разделяет бизнес-логику от UI, обеспечивает валидацию данных и управление состоянием
 * Работа: Координирует взаимодействие между UI и AuthenticationManager для email операций
 */
@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    /**
     * signUp() - Регистрация нового пользователя
     *
     * Цель: Создать новый аккаунт пользователя с email и паролем
     * Полезность: Позволяет новым пользователям зарегистрироваться в приложении
     * Работа: Проверяет валидность данных и создает пользователя через AuthenticationManager
     */
    func signUp() async throws{
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
            return
        }
        
        let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(authData: returnedUserData)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    /**
     * signIn() - Вход существующего пользователя
     *
     * Цель: Аутентифицировать пользователя по email и паролю
     * Полезность: Позволяет существующим пользователям входить в свои аккаунты
     * Работа: Проверяет валидность данных и выполняет вход через AuthenticationManager
     */
    func signIn() async throws{
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
            return
        }
        
        let returnedUserData = try await AuthenticationManager.shared.signIn(email: email, password: password)
        print("Success")
        print(returnedUserData)
    }
}
