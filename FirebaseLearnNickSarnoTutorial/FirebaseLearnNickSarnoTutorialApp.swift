//
//  FirebaseLearnNickSarnoTutorialApp.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 22.06.2025.
//

import SwiftUI
import Firebase

/**
 * AppDelegate - Класс для настройки Firebase при запуске приложения
 * 
 * Цель: Инициализировать Firebase SDK при старте приложения
 * Полезность: Обеспечивает корректную работу всех Firebase сервисов (Authentication, Firestore, etc.)
 * Работа: Реализует протокол UIApplicationDelegate для обработки событий жизненного цикла приложения
 */
class AppDelegate: NSObject, UIApplicationDelegate {
  /**
   * application(_:didFinishLaunchingWithOptions:) - Метод инициализации приложения
   * 
   * Цель: Настроить Firebase при первом запуске приложения
   * Полезность: Без этой настройки Firebase сервисы не будут работать
   * Работа: Вызывает FirebaseApp.configure() для инициализации SDK
   */
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

/**
 * FirebaseLearnNickSarnoTutorialApp - Главная структура приложения SwiftUI
 * 
 * Цель: Точка входа в приложение и настройка основного интерфейса
 * Полезность: Определяет структуру приложения и связывает Firebase с UI
 * Работа: Использует @main для обозначения точки входа и @UIApplicationDelegateAdaptor для интеграции с AppDelegate
 */
@main
struct FirebaseLearnNickSarnoTutorialApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
