//
//  SignInEmailView.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 23.06.2025.
//

import SwiftUI
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
        print("Success")
        print(returnedUserData)
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

/**
 * SignInEmailView - Представление для входа через email
 * 
 * Цель: Предоставить интерфейс для регистрации и входа пользователей через email
 * Полезность: Основной экран для email аутентификации с поддержкой как регистрации, так и входа
 * Работа: Отображает поля для ввода email и пароля, обрабатывает как регистрацию новых, так и вход существующих пользователей
 */
struct SignInEmailView: View {
    @StateObject private var viewModel: SignInEmailViewModel = .init()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            TextField(
                "Email",
                text: $viewModel.email
            )
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
            
            SecureField(
                "Password",
                text: $viewModel.password
            )
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
            
            Button {
                Task{
                    do{
                        try await viewModel.signUp()
                        self.showSignInView = false
                        return
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    do{
                        try await viewModel.signIn()
                        self.showSignInView = false
                        return
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
            } label: {
                Text("Sign in")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            Spacer()
        }
        .padding()
        .navigationTitle(Text("Sign in with email"))
    }
}

/**
 * SignInEmailView_Previews - Предварительный просмотр для SignInEmailView
 * 
 * Цель: Обеспечить предварительный просмотр в Xcode для разработки UI
 * Полезность: Позволяет видеть изменения в UI без запуска приложения
 * Работа: Создает тестовую среду с NavigationStack для корректного отображения
 */
struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            SignInEmailView(showSignInView: .constant(false))
        }
    }
}
