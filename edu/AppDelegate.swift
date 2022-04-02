//
//  AppDelegate.swift
//  edu
//
//  Created by Donatio Nikolashin on 15.03.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private lazy var appViewController = UINavigationController(rootViewController: FeedTableViewController())

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupWindow()
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        .init(rawValue: UIInterfaceOrientationMask.portrait.rawValue)
    }

    func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = appViewController
        window?.makeKeyAndVisible()
    }

}

