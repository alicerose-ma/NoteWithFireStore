//
//  AppDelegate.swift
//  NoteWithFireStore
//
//  Created by Ma Alice on 2/23/20.
//  Copyright © 2020 Ma Alice. All rights reserved.
//  Alice

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    //    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        //      change appearance of nav bar
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black
            appearance.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white
            ]
            
            let buttonAppearance = UIBarButtonItemAppearance()
            buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.buttonAppearance = buttonAppearance
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            
            UIBarButtonItem.appearance().tintColor = UIColor.white
        } else {
            UINavigationBar.appearance().barTintColor = UIColor.black
            UINavigationBar.appearance().titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
            UINavigationBar.appearance().tintColor = UIColor.white
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

// change color of nav controller battery icon, time, wifi connection
extension UINavigationController {
    @objc override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

