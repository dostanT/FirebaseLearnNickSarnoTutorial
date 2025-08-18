//
//  RootView.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 23.06.2025.
//
import SwiftUI

/**
 * RootView - Корневое представление приложения
 * 
 * Цель: Управлять навигацией между аутентифицированными и неаутентифицированными состояниями
 * Полезность: Обеспечивает автоматическое переключение между экранами в зависимости от статуса аутентификации
 * Работа: Проверяет статус аутентификации при запуске и показывает соответствующий экран (SettingsView или AuthenticationView)
 */
struct RootView: View {
    
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack{
            if !showSignInView{
                NavigationStack{
                    SettingsView(showSignInView: $showSignInView)
                }
            }
        }
        .onAppear {
            //try to fetch email from firebase
            let authUser = try? AuthenticationManager.shared.getAuthenticationUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack{
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}
