//
//  AuthenticationView.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 23.06.2025.
//
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

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
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens )
    }
}

/**
 * AuthenticationView - Представление для выбора способа аутентификации
 * 
 * Цель: Предоставить пользователю интерфейс для входа в приложение
 * Полезность: Центральный экран аутентификации с поддержкой email и Google входа
 * Работа: Отображает кнопки для различных способов входа и управляет навигацией к соответствующим экранам
 */
struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View{
        VStack{
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign in with email")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task{
                    do{
                        try await viewModel.signInWithGoogle()
                        showSignInView = false
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign in")
    }
}

/**
 * AuthenticationView_Previews - Предварительный просмотр для AuthenticationView
 * 
 * Цель: Обеспечить предварительный просмотр в Xcode для разработки UI
 * Полезность: Позволяет видеть изменения в UI без запуска приложения
 * Работа: Создает тестовую среду с NavigationStack для корректного отображения
 */
struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            AuthenticationView(showSignInView: .constant(false))
        }
    }
}
