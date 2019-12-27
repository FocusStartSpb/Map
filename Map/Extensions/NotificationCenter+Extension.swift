//
//  NotificationCenter+Extension.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 26.12.2019.
//

import Foundation

extension NotificationCenter
{
	func addObserver(_ observer: Any, notifications: [NSNotification.Name: Selector]) {
		notifications.forEach {
			addObserver(observer, selector: $0.value, name: $0.key, object: nil)
		}
	}

	func removeObserver(_ observer: Any, names: Set<NSNotification.Name>) {
		names.forEach {
			removeObserver(observer, name: $0, object: nil)
		}
	}
}
