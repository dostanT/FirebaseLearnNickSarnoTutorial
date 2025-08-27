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
            
            Button {
                Task{
                    do{
                        try await viewModel.signInAnonymous()
                        showSignInView = false
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } label: {
                Text("Sign in anonymously")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(25)
            }
            
            
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
            
            Button{
                Task{
                    do{
                        try await viewModel.signInWithApple()
                        showSignInView = false
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } label: {
            SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                .allowsHitTesting(false)
                .frame(height: 55)
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
