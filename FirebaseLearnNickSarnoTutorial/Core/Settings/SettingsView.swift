//
//  SettingsView.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 23.06.2025.
//
import SwiftUI

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
            Button(role: .destructive) {
                Task{
                    do {
                        try await viewModel.deleteUser()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } label: {
                Text("Delete User")
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
            
            if viewModel.authUser?.isAnonymous == nil {
                anonymousSection
            }
            
        }
        .onAppear{
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
        .navigationTitle(Text("Settings"))
    }
}

extension SettingsView {
    private var anonymousSection: some View {
        Section {
            Button("Link Google Account") {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("GOOGLE LINKED!")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Link Apple Account") {
                Task {
                    do {
                        try await viewModel.linkAppleAccount()
                        print("APPLE LINKED!")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Link Email Account") {
                Task {
                    do {
                        try await viewModel.linkEmailAccount()
                        print("EMAIL LINKED!")
                    } catch {
                        print(error)
                    }
                }
            }
        } header: {
            Text("Create account")
        }
    }
}

