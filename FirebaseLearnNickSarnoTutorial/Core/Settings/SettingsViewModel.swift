//
//  SettingsViewModel.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 26.08.2025.
//
import Foundation
/**
 * SettingsViewModel - ViewModel для управления настройками пользователя
 *
 * Цель: Обрабатывать логику управления аккаунтом пользователя и его настройками
 * Полезность: Разделяет бизнес-логику от UI, обеспечивает централизованное управление настройками пользователя
 * Работа: Координирует взаимодействие между UI и AuthenticationManager для операций с аккаунтом
 */
@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    
    /**
     * loadAuthProviders() - Загрузка провайдеров аутентификации пользователя
     *
     * Цель: Определить, какими способами пользователь вошел в систему
     * Полезность: Позволяет показывать соответствующие опции управления аккаунтом
     * Работа: Получает список провайдеров из AuthenticationManager и обновляет UI
     */
    func loadAuthProviders()  {
        if let provaiders = try? AuthenticationManager.shared.getProviders() {
            authProviders = provaiders
        }
    }
    func loadAuthUser() {
        do {
            self.authUser = try? AuthenticationManager.shared.getAuthenticationUser()
            print(authUser?.isAnonymous.description ?? "None")
        }
    }
    /**
     * logOut() - Выход пользователя из системы
     *
     * Цель: Завершить сессию пользователя и вернуть к экрану входа
     * Полезность: Позволяет пользователю безопасно выйти из аккаунта
     * Работа: Вызывает signOut в AuthenticationManager для очистки данных сессии
     */
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    /**
     * resetPassword() - Сброс пароля пользователя
     *
     * Цель: Отправить email для сброса пароля текущему пользователю
     * Полезность: Помогает пользователям восстановить доступ к аккаунту при забытом пароле
     * Работа: Получает email текущего пользователя и отправляет запрос на сброс пароля
     */
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticationUser()
        
        guard let email = authUser.email else {
            fatalError("User email not found")
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    /**
     * updateEmail(email:) - Обновление email пользователя
     *
     * Цель: Изменить email адрес текущего пользователя
     * Полезность: Позволяет пользователям обновлять свои контактные данные
     * Работа: Отправляет запрос на обновление email через AuthenticationManager
     */
    func updateEmail(email: String) async throws {
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    /**
     * updatePassword(password:) - Обновление пароля пользователя
     *
     * Цель: Изменить пароль текущего пользователя
     * Полезность: Позволяет пользователям изменять свои пароли для безопасности
     * Работа: Отправляет запрос на обновление пароля через AuthenticationManager
     */
    func updatePassword(password: String) async throws {
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper.shared
        let tokens = try await helper.signInWithGoogle()
        self.authUser = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
    }
    
    func linkAppleAccount() async throws {
        let helper = SignInWithAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        self.authUser = try await AuthenticationManager.shared.linkApple(tokens: tokens)
    }
    
    func linkEmailAccount() async throws {
        let email = "anotherEmail@gmail.com"
        let password = "Hello123!"
        self.authUser = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
    }
    
    func deleteUser() async throws {
        try await AuthenticationManager.shared.deleteUser()
    }
}
