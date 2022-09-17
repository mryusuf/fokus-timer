//
//  AppDelegate.swift
//  Fokus Timer
//
//  Created by Indra Permana on 20/08/20.
//

import UIKit
import UserNotifications
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - User Notifications
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let timeRecieved = Date()
        let id = response.notification.request.identifier
        print("Notification with id \(id) is received")
        if let unfinishedTask = DataManager.shared.fetchUnfinishedTask() {
            DataManager.shared.updateUnfinishedTask(for: unfinishedTask, timeStop: timeRecieved)
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let timeRecieved = Date()
        let id = notification.request.identifier
        print("Notification with id \(id) is received")
        if id == "main-timer", let unfinishedTask = DataManager.shared.fetchUnfinishedTask() {
            DataManager.shared.updateUnfinishedTask(for: unfinishedTask, timeStop: timeRecieved)
        }
        if #available(iOS 14, *) {
            completionHandler([.banner, .list, .badge, .sound])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }

    

}

