//
//  AppDelegate.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 16.12.2019.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate
{
	var window: UIWindow?

	func application(_ application: UIApplication,
					didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		let tabBarController = TabBarController()
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = tabBarController
		window?.makeKeyAndVisible()
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		window?.endEditing(true)
	}
}
