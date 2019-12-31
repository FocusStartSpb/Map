//
//  TabBar.swift
//  Map
//
//  Created by Антон on 28.12.2019.
//

import UIKit

final class TabBarController: UITabBarController
{
	override func viewDidLoad() {
		super.viewDidLoad()
		let factory = SceneBuilder()
		let dataBaseService = DataBaseService<SmartTargetCollection>()
		let repository = SmartTargetRepository(dataBaseService: dataBaseService)
		let mapViewController = factory.getMapScene(withRepository: repository)
		let smartTargetListViewController = factory.getSmartTargetListScene(withRepository: repository)
		let settingsViewController = factory.getSettingsScene()
		let settingsNavigationViewController = UINavigationController(rootViewController: settingsViewController)
		mapViewController.tabBarItem = UITabBarItem(title: "Map", image: #imageLiteral(resourceName: "icons8-map-marker"), selectedImage: #imageLiteral(resourceName: "icons8-map-marker-fill"))
		smartTargetListViewController.tabBarItem = UITabBarItem(title: "List", image: #imageLiteral(resourceName: "icons8-table-of-content"), selectedImage: #imageLiteral(resourceName: "icons8-table-of-content-fill"))
		settingsNavigationViewController.tabBarItem = UITabBarItem(title: "Settings", image: #imageLiteral(resourceName: "icons8-settings"), selectedImage: #imageLiteral(resourceName: "icons8-settings-fill"))
		viewControllers = [
			mapViewController,
			smartTargetListViewController,
			settingsNavigationViewController,
		]
	}
}
