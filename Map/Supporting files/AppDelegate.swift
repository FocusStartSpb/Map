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

	func applicationWillResignActive(_ application: UIApplication) {
		window?.endEditing(true)
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		updateNotifications()
		updateAttendanceOfSmartTargets()
	}
}

extension AppDelegate
{
	private func updateNotifications() {
		guard let collection = try? DataBaseService<SmartTargetCollection>().read() else { return }
		notificationWorker.checkNotifications(for: collection.smartTargets)
	}

	private func updateAttendanceOfSmartTargets() {
		notificationWorker.getDeliveredNotifications { [weak self] notifications, uids in
			guard notifications.isEmpty == false else { return }
			guard let collection = try? DataBaseService<SmartTargetCollection>().read() else { return }
			var smartTargets = collection.smartTargets(at: uids)
			for index in 0..<uids.count {
				smartTargets[index].inside.toggle()
				if smartTargets[index].inside {
					smartTargets[index].entryDate = notifications[index].date
				}
				else {
					smartTargets[index].exitDate = notifications[index].date
				}
				collection.put(smartTargets[index])
			}
			try? DataBaseService<SmartTargetCollection>().write(collection)
			self?.notificationWorker.removeAllDeliveredNotifications()
		}
	}
}
