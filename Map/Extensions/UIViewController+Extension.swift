//
//  UIViewController+Extension.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 07.01.2020.
//

import UIKit

extension UIViewController
{
	func setTabBarHidden(_ hidden: Bool, animated: Bool = true, duration: TimeInterval = 0.5) {
		guard let tabBar = tabBarController?.tabBar, tabBar.isHidden != hidden, animated else { return }
		if tabBar.isHidden {
			tabBar.isHidden = hidden
		}
		let frame = tabBar.frame
		let factor: CGFloat = hidden ? 1 : -1
		// swiftlint:disable:next identifier_name
		let y = frame.origin.y + (frame.size.height * factor)
		UIView.transition(with: tabBar, duration: duration, options: .transitionCrossDissolve, animations: {
			tabBar.frame = CGRect(x: frame.origin.x, y: y, width: frame.width, height: frame.height)
		}, completion: { _ in
			if tabBar.isHidden == false {
				tabBar.isHidden = hidden
			}
		})
	}
}
