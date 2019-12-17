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
		let decoderService = DecoderService()
		let repository = SmartTargetRepository(decoderService: decoderService)
		let mapViewController = factory.getMapScene(withRepository: repository)
		let smartTargetListViewVontroller = factory.getSmartTargetListScene(withRepository: repository)
		let tabBarController = UITabBarController()

		tabBarController.viewControllers = [
			mapViewController,
			smartTargetListViewVontroller,
		]

		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = tabBarController
		window?.makeKeyAndVisible()

		return true
	}
}
