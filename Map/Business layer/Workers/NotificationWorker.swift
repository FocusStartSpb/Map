//
//  NotificationWorker.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 05.01.2020.
//

import UIKit

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
	private func requestNotificationAuthorized(completionHandler: @escaping (Bool) -> Void) {
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

	private func addNotifications(for smartTargets: [SmartTarget]) {
		smartTargets.forEach { [weak self] in
			self?.notificationService.addLocationNotificationWith(center: $0.coordinates,
																  radius: $0.radius ?? 100,
																  title: $0.title,
																  body: $0.address ?? "",
																  visit: .entry,
																  uid: $0.uid)
			self?.notificationService.addLocationNotificationWith(center: $0.coordinates,
																  radius: $0.radius ?? 100,
																  title: $0.title,
																  body: $0.address ?? "",
																  visit: .exit,
																  uid: $0.uid)
		}
	}

	private func removeNotification(at uid: String) {
		notificationService.removePendingNotification(at: uid, visit: .entry)
		notificationService.removePendingNotification(at: uid, visit: .exit)
	}

	private func updateNotification(for smartTarget: SmartTarget) {
		notificationService.updateLocationNotification(center: smartTarget.coordinates,
													   radius: smartTarget.radius ?? 100,
													   title: smartTarget.title,
													   body: smartTarget.address ?? "",
													   visit: .entry,
													   uid: smartTarget.uid)
		notificationService.updateLocationNotification(center: smartTarget.coordinates,
													   radius: smartTarget.radius ?? 100,
													   title: smartTarget.title,
													   body: smartTarget.address ?? "",
													   visit: .exit,
													   uid: smartTarget.uid)
	}

	private func replaceAllNotifications(with smartTargets: [SmartTarget]) {
		notificationService.removeAllNotifications()
		addNotifications(for: smartTargets)
		Self.isVerificationRequired = false
	}

	// MARK: ...Internal methods
	func setDelegate(_ delegate: NotificationServiceDelegate?) {
		notificationService.delegate = delegate
	}

	func addNotifications(for smartTargets: [SmartTarget], updatesIfNeeded: @escaping UpdateNotificationsIfNeeded) {
		checkRequestNotificationAllowed { [weak self] granted in
			guard granted else { return }
			if Self.isVerificationRequired ?? false {
				self?.replaceAllNotifications(with: updatesIfNeeded(true))
			}
			else {
				_ = updatesIfNeeded(false)
				self?.notificationService.getPendingNotificationUIDs { uids in
					let targetsContainedInPendingNotifications = smartTargets.filter { uids.contains($0.uid) }
					// Обновляем
					targetsContainedInPendingNotifications.forEach {
						self?.updateNotification(for: $0)
					}
					// Добавляем
					self?.addNotifications(for: smartTargets.difference(from: targetsContainedInPendingNotifications))
				}
			}
		}
	}

	func removeNotification(at uid: String, updatesIfNeeded: @escaping UpdateNotificationsIfNeeded) {
		checkRequestNotificationAllowed { [weak self] granted in
			guard granted else { return }
			if Self.isVerificationRequired ?? false {
				self?.replaceAllNotifications(with: updatesIfNeeded(true))
			}
			else {
				_ = updatesIfNeeded(false)
				self?.removeNotification(at: uid)
			}
		}
	}

	func updateNotification(for smartTarget: SmartTarget, updatesIfNeeded: @escaping UpdateNotificationsIfNeeded) {
		checkRequestNotificationAllowed { [weak self] granted in
			guard granted else { return }
			if Self.isVerificationRequired ?? false {
				self?.replaceAllNotifications(with: updatesIfNeeded(true))
			}
			else {
				_ = updatesIfNeeded(false)
				self?.updateNotification(for: smartTarget)
			}
		}
	}

	func checkNotifications(for smartTargets: [SmartTarget]) {
		checkRequestNotificationAllowed { [weak self] granted in
			guard granted else { return }
			if Self.isVerificationRequired ?? false {
				self?.replaceAllNotifications(with: smartTargets)
			}
		}
	}

	func getDeliveredNotifications(completionHandler: @escaping ([UNNotification], [String]) -> Void) {
		notificationService.getDeliveredNotifications(completionHandler: completionHandler)
	}

	func removeAllDeliveredNotifications() {
		notificationService.removeAllDeliveredNotifications()
	}
}
