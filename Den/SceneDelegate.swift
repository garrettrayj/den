//
//  SceneDelegate.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private(set) static var shared: SceneDelegate?
    
    var window: UIWindow?
    var subscriptionManager: SubscriptionManager = SubscriptionManager()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Self.shared = self
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Get the managed object context from the shared persistent container
        guard let persistentContainer = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer else {
            fatalError("Unable to read shared persistent container")
        }

        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.undoManager = nil
        
        // Setup initial workspace if needed
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Workspace")
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest) as! [Workspace]
            
            print("WORKSPACE RESULTS: \(results.count)")
            print(results)
            
            if results.count == 0 {
                let _ = Workspace.create(in: persistentContainer.viewContext)
                do {
                    try persistentContainer.viewContext.save()
                } catch {
                    fatalError("Unable to create workspace: \(error)")
                }
            }
        } catch {
            fatalError("Failed to fetch workspace: \(error)")
        }
        
        // Create manager services
        let refreshManager = RefreshManager(persistentContainer: persistentContainer)
        let cacheManager = CacheManager(persistentContainer: persistentContainer)
        let importManager = ImportManager(viewContext: persistentContainer.viewContext)
        let userDefaultsManager = UserDefaultsManager()
        
        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath
        let contentView = ContentView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
            .environmentObject(refreshManager)
            .environmentObject(cacheManager)
            .environmentObject(importManager)
            .environmentObject(userDefaultsManager)
            .environmentObject(subscriptionManager)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            // Restore from defaults initial or previously stored style          
            window.overrideUserInterfaceStyle = userDefaultsManager.uiStyle.wrappedValue
            
            // Add SwiftUI content to window
            window.rootViewController = DenHostingController(rootView: contentView)

            #if targetEnvironment(macCatalyst)
            if let titlebar = windowScene.titlebar {
                titlebar.titleVisibility = .hidden
                titlebar.toolbar = nil
            }
            #endif
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
        subscriptionManager.subscribe(to: urlContexts.first?.url)
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
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
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

