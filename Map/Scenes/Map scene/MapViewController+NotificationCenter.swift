//
//  MapViewController+NotificationCenter.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 16.01.2020.
//

import UIKit

extension MapViewController
{
	var notificationCenter: NotificationCenter { .default }

	private var keyboardNotifications: [NSNotification.Name: Selector] {
		[
			UIResponder.keyboardWillShowNotification: #selector(keyboardWillAppear),
			UIResponder.keyboardWillHideNotification: #selector(keyboardWillDisappear),
			UIResponder.keyboardDidShowNotification: #selector(keyboardDidAppear),
			UIResponder.keyboardDidHideNotification: #selector(keyboardDidDisappear),
		]
	}

	private var applicationNotifications: [NSNotification.Name: Selector] {
		[
			UIApplication.willResignActiveNotification: #selector(appMovedToBackground),
			UIApplication.didBecomeActiveNotification: #selector(appMovedFromBackground),
		]
	}

	func setupNotifications() {
		notificationCenter.addObserver(self, notifications: applicationNotifications)
		if isObservableToKeyboard == false {
			notificationCenter.addObserver(self, notifications: keyboardNotifications)
			isObservableToKeyboard = true
		}
	}

	func removeNotifications() {
		notificationCenter.removeObserver(self, names: Set(applicationNotifications.keys))
		notificationCenter.removeObserver(self, names: Set(keyboardNotifications.keys))
		isObservableToKeyboard = false
	}
}

@objc private extension MapViewController
{
	func keyboardWillAppear(notification: NSNotification?) {
		guard keyboardIsVisible == false else { return }
		keyboardIsVisible = true
		willTranslateKeyboard = true
		guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
			return
		}
		let keyboardHeight = keyboardFrame.cgRectValue.height
		animateMapViewFrame(withBottomOffset: -keyboardHeight)
		let smartTargetMenuBottomConstant = -keyboardHeight / 3
		animateSmartTargetMenu(withBottomOffset: smartTargetMenuBottomConstant)
	}

	func keyboardWillDisappear(notification: NSNotification?) {
		guard keyboardIsVisible else { return }
		keyboardIsVisible = false
		willTranslateKeyboard = true
		let tabBarHeight = tabBarIsVisible ? 0 : tabBarController?.tabBar.frame.height ?? 0
		animateMapViewFrame(withBottomOffset: 0, layoutIfNeeded: false)
		let smartTargetMenuBottomConstant = -Constants.Offset.mapButton + tabBarHeight
		animateSmartTargetMenu(withBottomOffset: smartTargetMenuBottomConstant, layoutIfNeeded: false)
	}

	func keyboardDidAppear(notification: NSNotification?) {
		willTranslateKeyboard = false
	}

	func keyboardDidDisappear(notification: NSNotification?) {
		willTranslateKeyboard = false
	}

	func appMovedFromBackground() {
		let updateStatusRequest = Map.UpdateStatus.Request()
		interactor.configureLocationService(updateStatusRequest)

		if isObservableToKeyboard == false {
			notificationCenter.addObserver(self, notifications: keyboardNotifications)
			isObservableToKeyboard = true
		}

		if currentPointer != nil {
			smartTargetMenu?.translucent(false)
			smartTargetMenu?.isEditable = true
		}

		if mode == .edit {
			setTabBarVisible(false, duration: 0)
		}
	}

	func appMovedToBackground() {
		notificationCenter.removeObserver(self, names: Set(keyboardNotifications.keys))
		isObservableToKeyboard = false
	}
}
