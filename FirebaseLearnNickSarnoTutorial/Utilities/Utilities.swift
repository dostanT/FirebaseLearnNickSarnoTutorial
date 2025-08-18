//
//  Utilities.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 24.06.2025.
//
import Foundation
import UIKit

/**
 * Utilities - Утилитарный класс для общих вспомогательных функций
 * 
 * Цель: Предоставить переиспользуемые утилиты для работы с UI и системными функциями
 * Полезность: Централизует общие функции, упрощает код и обеспечивает переиспользование
 * Работа: Использует паттерн Singleton для глобального доступа к утилитарным функциям
 */
final class Utilities {
    static let shared = Utilities()
    
    private init() {}
    
    /**
     * topViewController(controller:) - Получение самого верхнего ViewController в иерархии
     * 
     * Цель: Найти активный ViewController для отображения модальных окон и диалогов
     * Полезность: Необходим для корректного отображения Google Sign-In диалога в SwiftUI приложениях
     * Работа: Рекурсивно проходит по иерархии ViewController'ов (NavigationController, TabBarController, presented) для поиска самого верхнего
     */
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        //'keyWindow' was deprecated in iOS 13.0: Should not be used for applications that support multiple scenes as it returns a key window across all connected scenes - это предупреждение не влияет на нас так как мы не делаем игру. Тут у нас нету Multiple Scenes.
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


