//
//  AuthenticationManager.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 23.06.2025.
//
import Foundation
import FirebaseAuth

/**
 * AuthDataResultModel - Модель данных для хранения информации о пользователе
 * 
 * Цель: Предоставить структурированный доступ к данным аутентифицированного пользователя
 * Полезность: Упрощает работу с данными пользователя и обеспечивает типобезопасность
 * Работа: Инкапсулирует uid, email и photoURL пользователя в удобную структуру
 */
struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoURL: String?
    let isAnonymous: Bool
    /**
     * init(user:) - Инициализатор модели данных пользователя
     * 
     * Цель: Создать модель данных из Firebase User объекта
     * Полезность: Преобразует Firebase User в удобную для использования структуру
     * Работа: Извлекает uid, email и photoURL из Firebase User объекта
     */
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
    }
}

/**
 * AuthProviderOption - Перечисление провайдеров аутентификации
 * 
 * Цель: Определить поддерживаемые способы входа в приложение
 * Полезность: Обеспечивает типобезопасность при работе с различными провайдерами аутентификации
 * Работа: Содержит строковые идентификаторы для email/password и Google аутентификации
 */
enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

/**
 * AuthenticationManager - Главный менеджер аутентификации Firebase
 * 
 * Цель: Централизованное управление всеми операциями аутентификации
 * Полезность: Предоставляет единый интерфейс для работы с Firebase Auth, упрощает код и обеспечивает переиспользование
 * Работа: Использует паттерн Singleton для глобального доступа и инкапсулирует всю логику аутентификации
 */
final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init(){}
    
    /**
     * getAuthenticationUser() - Получение текущего аутентифицированного пользователя
     * 
     * Цель: Получить данные текущего пользователя из Firebase
     * Полезность: Позволяет проверить статус аутентификации и получить информацию о пользователе
     * Работа: Проверяет наличие текущего пользователя и возвращает его данные в виде AuthDataResultModel
     */
    func getAuthenticationUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
    
    /*
     if with Google -> google.com
     
     if with Email/password -> password
     */
    /**
     * getProviders() - Получение списка провайдеров аутентификации пользователя
     * 
     * Цель: Определить, какими способами пользователь вошел в систему
     * Полезность: Позволяет показывать соответствующие опции (например, сброс пароля только для email пользователей)
     * Работа: Анализирует providerData текущего пользователя и преобразует их в AuthProviderOption
     */
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure(#function + " provider not supported \(provider.providerID)")
            }
        }
        return providers
    }
    
    /**
     * signOut() - Выход пользователя из системы
     * 
     * Цель: Завершить сессию текущего пользователя
     * Полезность: Позволяет пользователю безопасно выйти из приложения
     * Работа: Вызывает Firebase Auth.signOut() для очистки данных сессии
     */
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
}

//MARK: Sign in EMAIL
/**
 * AuthenticationManager Email Extension - Расширение для работы с email аутентификацией
 * 
 * Цель: Предоставить методы для регистрации, входа и управления email пользователей
 * Полезность: Инкапсулирует всю логику работы с email/password аутентификацией в одном месте
 * Работа: Использует Firebase Auth методы для создания, входа и обновления email пользователей
 */
extension AuthenticationManager {
    /**
     * createUser(email:password:) - Создание нового пользователя с email и паролем
     * 
     * Цель: Зарегистрировать нового пользователя в Firebase
     * Полезность: Позволяет пользователям создавать аккаунты через email
     * Работа: Асинхронно создает пользователя в Firebase и возвращает данные созданного аккаунта
     */
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let result = AuthDataResultModel(user: authDataResult.user)
        return result
    }
    
    /**
     * signIn(email:password:) - Вход существующего пользователя с email и паролем
     * 
     * Цель: Аутентифицировать пользователя по email и паролю
     * Полезность: Позволяет пользователям входить в свои аккаунты
     * Работа: Асинхронно проверяет учетные данные и возвращает данные пользователя при успешном входе
     */
    @discardableResult
    func signIn(email: String, password: String) async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    /**
     * resetPassword(email:) - Сброс пароля пользователя
     * 
     * Цель: Отправить email для сброса пароля
     * Полезность: Помогает пользователям восстановить доступ к аккаунту при забытом пароле
     * Работа: Асинхронно отправляет email с инструкциями по сбросу пароля
     */
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    /**
     * updatePassword(password:) - Обновление пароля текущего пользователя
     * 
     * Цель: Изменить пароль аутентифицированного пользователя
     * Полезность: Позволяет пользователям изменять свои пароли для безопасности
     * Работа: Асинхронно обновляет пароль текущего пользователя в Firebase
     */
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else { throw URLError(.badServerResponse)}
        
        try await user.updatePassword(to: password)
    }
    
    /**
     * updateEmail(email:) - Обновление email текущего пользователя
     * 
     * Цель: Изменить email аутентифицированного пользователя
     * Полезность: Позволяет пользователям обновлять свои email адреса
     * Работа: Асинхронно отправляет email для верификации перед обновлением адреса
     */
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else { throw URLError(.badServerResponse)}
        
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
}

//MARK: Sign in SSO
/**
 * AuthenticationManager SSO Extension - Расширение для работы с Single Sign-On (Google)
 * 
 * Цель: Предоставить методы для аутентификации через Google
 * Полезность: Позволяет пользователям входить через Google аккаунт, упрощая процесс регистрации
 * Работа: Использует Google Sign-In SDK и Firebase Auth для обработки OAuth аутентификации
 */
extension AuthenticationManager {
    /**
     * signInWithGoogle(tokens:) - Вход пользователя через Google
     * 
     * Цель: Аутентифицировать пользователя используя Google токены
     * Полезность: Обеспечивает быстрый и безопасный вход через Google аккаунт
     * Работа: Создает Firebase credential из Google токенов и выполняет аутентификацию
     */
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel{
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    @discardableResult
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel{
        let credential = OAuthProvider.credential(providerID: AuthProviderID.apple, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await signIn(credential: credential)
    }
    
    /**
     * signIn(credential:) - Универсальный метод входа с любым Firebase credential
     * 
     * Цель: Обработать аутентификацию с любым типом Firebase credential
     * Полезность: Позволяет поддерживать различные провайдеры аутентификации через единый интерфейс
     * Работа: Асинхронно выполняет аутентификацию с переданным credential и возвращает данные пользователя
     */
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}


// MARK: Sign with Anonymous
extension AuthenticationManager {
    @discardableResult
    func signInAnonymous() async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func linkGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel{
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await linkCredntial(credential: credential)
    }
    
    func linkEmail(email: String, password: String) async throws -> AuthDataResultModel{
        let credential = EmailAuthProvider.credential(withEmail: email, link: password)
        return try await linkCredntial(credential: credential)
    }
    
    func linkApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel{
        let credential = OAuthProvider.credential(providerID: AuthProviderID.apple, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await linkCredntial(credential: credential)
        
    }
    
    private func linkCredntial(credential: AuthCredential) async throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        let authDataResult = try await user.link(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
