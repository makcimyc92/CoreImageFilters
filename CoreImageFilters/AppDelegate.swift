//
//  AppDelegate.swift
//  CoreImageFilters
//
//  Created by Max Vasilevsky on 5/26/20.
//  Copyright © 2020 Max Vasilevsky. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        app.router.window = self.window
        app.router.launchRootNavigation()
        return true
    }


}

