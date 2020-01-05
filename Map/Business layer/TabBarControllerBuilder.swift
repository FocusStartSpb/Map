//
//  TabBarControllerBuilder.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 02.01.2020.
//

import UIKit

@_functionBuilder enum TabBarControllerBuilder
{
	static func buildBlock(_ controllers: UIViewController...) -> UITabBarController {
		let tabBarController = UITabBarController()
		tabBarController.viewControllers = controllers
		return tabBarController
	}
}
