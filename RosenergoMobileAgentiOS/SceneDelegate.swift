//
//  SceneDelegate.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 09.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let sessionStore = SessionStore.shared

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let rootView = RootView()
            .environment(\.managedObjectContext, context)
            .environmentObject(sessionStore)
            .accentColor(.rosenergo)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: rootView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        switch shortcutItem.type {
        case "CreateVyplatnyeDela":
            self.sessionStore.openCreateVyplatnyeDela = true
            break
        case "ListInspections":
            self.sessionStore.openListInspections = true
            break
        case "CreateInspections":
            self.sessionStore.openCreateInspections = true
            break
        default:
            break
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        if SessionStore.shared.loginModel != nil {
            SessionStore.shared.validateToken()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        var shortcutItems = UIApplication.shared.shortcutItems ?? []
        if shortcutItems.isEmpty {
            shortcutItems += [
                UIApplicationShortcutItem(type: "CreateVyplatnyeDela", localizedTitle: "Выплатные дела", localizedSubtitle: "Создайте выплатное дело", icon: UIApplicationShortcutIcon.init(systemImageName: "tray")),
                UIApplicationShortcutItem(type: "ListInspections", localizedTitle: "Осмотры", localizedSubtitle: "Архив осмотров", icon: UIApplicationShortcutIcon.init(systemImageName: "list.bullet.below.rectangle")),
                UIApplicationShortcutItem(type: "CreateInspections", localizedTitle: "Новый осмотр", localizedSubtitle: "Создайте осмотр", icon: UIApplicationShortcutIcon.init(systemImageName: "car"))
            ]
        }
        UIApplication.shared.shortcutItems = shortcutItems
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

