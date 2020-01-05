//
//  NotificationService.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 03.01.2020.
//

import CoreLocation
import UserNotifications

// MARK: - NotificationServiceDelegate protocol
protocol NotificationServiceDelegate: AnyObject
{
	func notificationService(_ notificationService: NotificationService, showButtonTappedForUID uid: String)
}

// MARK: - Class
final class NotificationService: NSObject
{
	private enum Identifier
	{
		case location(String)
		case notification(String)
		case showAction
		case cancelAction
		case category

		private static let base = "com.map."

		var value: String {
			switch self {
			case .location(let uid): return Self.base.appending("location.").appending("uid:" + uid)
			case .notification(let uid): return Self.base.appending("locationotificationn.").appending("uid:" + uid)
			case .showAction: return Self.base.appending("action.show")
			case .cancelAction: return Self.base.appending("action.cancel")
			case .category: return Self.base.appending("category")
			}
		}

		static func fetchUID(from identifier: String) -> String {
			String(identifier[identifier.index(after: identifier.firstIndex(of: ":") ?? identifier.startIndex)...])
		}
	}

	// MARK: ...Private properties
	private var defaultCategory: UNNotificationCategory {
		let showAction = UNNotificationAction(identifier: Identifier.showAction.value,
											  title: "Show pin on map",
											  options: [.foreground])
		let cancelAction = UNNotificationAction(identifier: Identifier.cancelAction.value,
												title: "Delete",
												options: [.authenticationRequired, .destructive])
		return UNNotificationCategory(identifier: Identifier.category.value,
									  actions: [showAction, cancelAction],
									  intentIdentifiers: [],
									  options: [])
	}

	// MARK: ...Internal properties
	static var `default` = NotificationService()

	weak var delegate: NotificationServiceDelegate?

	lazy var center: UNUserNotificationCenter = {
		let center = UNUserNotificationCenter.current()
		center.setNotificationCategories([defaultCategory])
		center.delegate = self
		return center
	}()

	// MARK: ...Internal methods
	// swiftlint:disable:next function_parameter_count
	func addLocationNotificationWith(center: CLLocationCoordinate2D,
									 radius: CLLocationDistance,
									 title: String,
									 subtitle: String,
									 body: String,
									 uid: String) {
		let identifier = Identifier.location(uid).value
		let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
		region.notifyOnEntry = true
		region.notifyOnExit = true
		let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
//		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
		let identifierNotification = Identifier.notification(uid).value
		let content = createContent(title: title, subtitle: subtitle, body: body)
		let request = UNNotificationRequest(identifier: identifierNotification, content: content, trigger: trigger)

		self.center.add(request) { error in
			if let error = error {
				print(error.localizedDescription)
			}
		}
	}

	func removePendingNotification(at uid: String) {
		let identifierNotification = Identifier.notification(uid).value
		center.removePendingNotificationRequests(withIdentifiers: [identifierNotification])
	}

	func removeDeliveredNotification(at uid: String) {
		let identifierNotification = Identifier.notification(uid).value
		center.removeDeliveredNotifications(withIdentifiers: [identifierNotification])
	}

	// swiftlint:disable:next function_parameter_count
	func updateLocationNotification(center: CLLocationCoordinate2D,
									radius: CLLocationDistance,
									title: String,
									subtitle: String,
									body: String,
									uid: String) {
		removePendingNotification(at: uid)
		addLocationNotificationWith(center: center, radius: radius, title: title, subtitle: subtitle, body: body, uid: uid)
	}

	func getPendingNotificationUIDs(completionHandler: @escaping ([String]) -> Void) {
		center.getPendingNotificationRequests { requests in
			completionHandler(requests.map { Identifier.fetchUID(from: $0.identifier) })
		}
	}

	// MARK: ...Private methods
	private func createContent(title: String, subtitle: String, body: String) -> UNMutableNotificationContent {
		let content = UNMutableNotificationContent()
		content.title = title
		content.subtitle = subtitle
		content.body = body
		content.sound = .default
		content.categoryIdentifier = Identifier.category.value
		return content
	}
}

// MARK: - User notification center delegate
extension NotificationService: UNUserNotificationCenterDelegate
{
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		//let content = notification.request.content
		completionHandler(.alert)
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {
		//let actionIdentifier = response.actionIdentifier
		//let content = response.notification.request.content

		switch response.actionIdentifier {
		case UNNotificationDismissActionIdentifier: break
		case UNNotificationDefaultActionIdentifier: break
		case Identifier.showAction.value:
			let uid = Identifier.fetchUID(from: response.notification.request.identifier)
			delegate?.notificationService(self, showButtonTappedForUID: uid)
		case Identifier.cancelAction.value: break
		default: break
		}

		completionHandler()
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
	}
}
