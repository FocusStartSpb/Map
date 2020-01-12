//
//  UIViewController+Extension.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 07.01.2020.
//

import UIKit

extension UIViewController
{
	var tabBarIsVisible: Bool {
		guard let tabBar = tabBarController?.tabBar else { return false }
		return tabBar.frame.minY < view.frame.maxY
	}

	func setTabBarVisible(_ visible: Bool,
						  duration: TimeInterval = 0.5,
						  completion: ((Bool) -> Void)? = nil) {
		guard let tabBar = tabBarController?.tabBar, tabBarIsVisible != visible else {
			completion?(true)
			return
		}

		let height = tabBar.frame.height
		let offsetY = visible ? -height : height

		UIView.transition(with: tabBar, duration: duration, options: .transitionCrossDissolve, animations: {
			tabBar.frame = tabBar.frame.offsetBy(dx: 0, dy: offsetY)
		}, completion: completion)
	}
}
