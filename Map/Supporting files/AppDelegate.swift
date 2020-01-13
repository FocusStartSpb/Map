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

	let notificationWorker = NotificationWorker(service: NotificationService.default)

	func application(_ application: UIApplication,
					didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		let tabBarController = SceneBuilder().getInitialController()
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = tabBarController
		window?.makeKeyAndVisible()
		return true
	}
}
