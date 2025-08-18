//
//  SettingsView.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 23.06.2025.
//
import SwiftUI

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
}

/**
 * SettingsView - Представление настроек пользователя
 * 
 * Цель: Предоставить интерфейс для управления аккаунтом пользователя
 * Полезность: Центральный экран для всех операций с аккаунтом (выход, сброс пароля, обновление данных)
 * Работа: Отображает список настроек в зависимости от провайдеров аутентификации пользователя
 */
struct SettingsView: View {
    
    @State private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    @State private var password: String = ""
    
    var body: some View {
        List {
            Button("Log out") {
                do{
                    try viewModel.logOut()
                    showSignInView = true
                } catch {
                    print(error)
                }
            }
            
            if viewModel.authProviders.contains(where: { $0 == .email }) {
                Button("Reset Password") {
                    Task{
                        do{
                            try await viewModel.resetPassword()
                            print("Password reset")
                        } catch {
                            print(error)
                        }
                    }
                }
                
                Section{
                    TextField("password", text: $password)
                    
                    Button("Update Password") {
                        Task{
                            do{
                                try await viewModel.updatePassword(password: password)
                                print("Password updated")
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            }
        }
        .onAppear{
            viewModel.loadAuthProviders()
        }
        .navigationTitle(Text("Settings"))
    }
}

/**
 * SettingsView_Previews - Предварительный просмотр для SettingsView
 * 
 * Цель: Обеспечить предварительный просмотр в Xcode для разработки UI
 * Полезность: Позволяет видеть изменения в UI без запуска приложения
 * Работа: Создает тестовую среду с NavigationStack для корректного отображения
 */
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            SettingsView(showSignInView: .constant(false))
        }
        
    }
}


