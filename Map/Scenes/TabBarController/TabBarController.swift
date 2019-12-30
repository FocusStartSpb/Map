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
		mapViewController.tabBarItem = UITabBarItem(title: "Map", image: #imageLiteral(resourceName: "icons8-map-64"), tag: 0)
		smartTargetListViewController.tabBarItem = UITabBarItem(title: "List", image: #imageLiteral(resourceName: "icons8-table-of-content-80"), tag: 1)
		settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: #imageLiteral(resourceName: "icons-add"), tag: 3)
		viewControllers = [
			mapViewController,
			smartTargetListViewController,
			settingsViewController,
		]
	}
}
