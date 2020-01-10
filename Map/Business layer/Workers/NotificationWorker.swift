//
//  NotificationWorker.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 05.01.2020.
//

import UIKit
import CoreLocation

typealias UpdateNotificationsIfNeeded = (Bool) -> [SmartTarget]

final class NotificationWorker
{
	private enum Key: String
	{
		case isVerificationRequired

		static subscript(key: Self) -> String {
			key.rawValue
		}
	}

	// MARK: ...Private properties
	private let notificationService: NotificationService
	private let userDefaults = UserDefaults.standard

	// MARK: ...Internal properties
	@SettingWrapper(key: Key[.isVerificationRequired], defaultValue: false)
	private(set) static var isVerificationRequired: Bool?

	// MARK: ...Initialization
	init(service: NotificationService) {
		self.notificationService = service
	}

	// MARK: ...Private methods
	private func checkRequestNotificationAllowed(completionHandler: @escaping (Bool) -> Void) {
		notificationService.center.getNotificationSettings { [weak self] settings in
			switch settings.authorizationStatus {
			case .notDetermined:
				self?.requestNotificationAuthorized(completionHandler: completionHandler)
			case .denied:
				Self.isVerificationRequired = true
				completionHandler(false)
			case .authorized, .provisional:
				completionHandler(true)
			@unknown default:
				fatalError("@unknown default")
			}
		}
	}

	private func configureBody(by smartTarget: SmartTarget) -> String {
		let body: String
		if let entryDate = smartTarget.entryDate {
			body = """
			Вы находитесь в радиусе \(smartTarget.radius ?? 100)м от \(smartTarget.address ?? "")
			Время прибытия: \(Formatter.medium.string(from: entryDate))
			Количество посещения данного места: \(smartTarget.numberOfVisits)
			"""
		}
		else if let exitDate = smartTarget.exitDate {
			body = """
			Вы находитесь в радиусе \(smartTarget.radius ?? 100)м от \(smartTarget.address ?? "")
			Время убытия: \(Formatter.medium.string(from: exitDate))
			Общее количество проведенного времени: \(Int(smartTarget.timeInside))с
			"""
		}
		else {
			body = ""
		}
		return body
	}

	// MARK: ...Internal methods
	func setDelegate(_ delegate: NotificationServiceDelegate?) {
		notificationService.delegate = delegate
	}

	func requestNotificationAuthorized(completionHandler: @escaping (Bool) -> Void) {
		notificationService.center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
			if granted {
				DispatchQueue.main.async {
					Self.isVerificationRequired = false
					UIApplication.shared.registerForRemoteNotifications()
					completionHandler(granted)
				}
			}
			else {
				Self.isVerificationRequired = true
				completionHandler(granted)
			}
		}
	}

	func addNotifications(for smartTargets: [SmartTarget]) {
		checkRequestNotificationAllowed { [weak self] granted in
			guard granted else { return }
			smartTargets.forEach { target in
				self?.notificationService.addLocationNotification(for: target.region,
																  title: target.title,
																  body: self?.configureBody(by: target) ?? "",
																  uid: target.uid)
			}
		}
	}

	func removeNotification(at uid: String) {
		checkRequestNotificationAllowed { [weak self] granted in
			guard granted else { return }
			self?.notificationService.removePendingNotification(at: uid)
		}
	}

	func updateNotification(for smartTarget: SmartTarget) {
		checkRequestNotificationAllowed { [weak self] granted in
			guard granted else { return }
			self?.removeNotification(at: smartTarget.uid)
			self?.addNotifications(for: [smartTarget])
		}
	}

	func getDeliveredNotifications(completionHandler: @escaping ([UNNotification], [String]) -> Void) {
		notificationService.getDeliveredNotifications(completionHandler: completionHandler)
	}

	func removeAllDeliveredNotifications() {
		notificationService.removeAllDeliveredNotifications()
	}
}
