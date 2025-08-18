//
//  ContentView.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 22.06.2025.
//

import SwiftUI

/**
 * ContentView - Базовая структура представления для демонстрации
 * 
 * Цель: Предоставить простой интерфейс для тестирования и демонстрации
 * Полезность: Служит шаблоном для создания новых экранов и проверки работы SwiftUI
 * Работа: Отображает иконку глобуса и текст "Hello, world!" в вертикальном стеке
 */
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
