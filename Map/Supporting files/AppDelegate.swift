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

		let factory = SceneBuilder()
		let dataBaseService = DataBaseService<SmartTargetCollection>()
		let repository = SmartTargetRepository(dataBaseService: dataBaseService)
		let mapViewController = factory.getMapScene(withRepository: repository)
		let smartTargetListViewController = factory.getSmartTargetListScene(withRepository: repository)
		let tabBarController = UITabBarController()
		mapViewController.tabBarItem = UITabBarItem(title: "Map", image: #imageLiteral(resourceName: "icons8-map-64"), tag: 0)
		smartTargetListViewController.tabBarItem = UITabBarItem(title: "List", image: #imageLiteral(resourceName: "icons8-table-of-content-80"), tag: 1)
		tabBarController.viewControllers = [
			mapViewController,
			smartTargetListViewController,
		]

		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = tabBarController
		window?.makeKeyAndVisible()

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		window?.endEditing(true)
	}
}
