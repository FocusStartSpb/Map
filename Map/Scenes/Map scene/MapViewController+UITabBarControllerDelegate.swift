//
//  MapViewController+UITabBarControllerDelegate.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 16.01.2020.
//

import UIKit

extension MapViewController: UITabBarControllerDelegate
{
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		tabBarController.delegate = nil
		guard let navigationController = tabBarController
			.viewControllers?
			.first(where: { $0 is UINavigationController }) as? UINavigationController,
			let smartTargetListViewController = navigationController.topViewController as? SmartTargetListViewController else {
				return false
		}
		smartTargetListViewController.router.dataStore?.didUpdateAllSmartTargets = false
		return true
	}
}
