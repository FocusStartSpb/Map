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

		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = getInitialController()
		window?.makeKeyAndVisible()
		return true
	}

	private func getInitialController() -> UIViewController {
		let service = DataBaseService<SmartTargetCollection>()
		let repository = SmartTargetRepository(dataBaseService: service)
		let dataBaseWorker = DataBaseWorker(repository: repository)
		let collection = (try? service.read()) ?? SmartTargetCollection()
		return SceneBuilder().getInitialController(dataBaseWorker: dataBaseWorker,
												   withCollection: collection,
												   temptCollection: collection.copy())
	}
}
