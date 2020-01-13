//
//  SceneBuilder.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import UIKit

final class SceneBuilder
{
	// MARK: ...Private methods
	private func getTabBarController(@TabBarControllerBuilder block: () -> UITabBarController) -> UITabBarController {
		block()
	}

	// MARK: ...Internal methods
	func getMapScene<T: ISmartTargetRepository>(withRepository repository: T) -> MapViewController
		where T.Element: ISmartTargetCollection {

		let presenter = MapPresenter()
		let dataBaseWorker = DataBaseWorker(repository: repository)
		let decoderService = DecoderService()
		let geocoderService = GeocoderService()
		let geocoderWorker = GeocoderWorker(service: geocoderService,
											decoder: decoderService)
		let notificationService = NotificationService.default
		let settingsWorker = SettingsWorker()
		let notificationWorker = NotificationWorker(service: notificationService)
		let interactor = MapInteractor(presenter: presenter,
									   dataBaseWorker: dataBaseWorker,
									   geocoderWorker: geocoderWorker,
									   settingsWorker: settingsWorker,
									   notificationWorker: notificationWorker)
		let router = MapRouter()
		let viewController = MapViewController(interactor: interactor, router: router)

		presenter.viewController = viewController
		router.viewController = viewController
		router.dataStore = interactor

		viewController.tabBarItem = UITabBarItem(title: "Map", image: #imageLiteral(resourceName: "icons8-map-marker"), selectedImage: #imageLiteral(resourceName: "icons8-map-marker-fill"))

		return viewController
	}

	func getSmartTargetListScene<T: ISmartTargetRepository>(withRepository repository: T) -> SmartTargetListViewController
		where T.Element: ISmartTargetCollection {

		let presenter = SmartTargetListPresenter()
		let worker = DataBaseWorker(repository: repository)
		let interactor = SmartTargetListInteractor(presenter: presenter, worker: worker)
		let router = SmartTargetListRouter(factory: self)
		let viewController = SmartTargetListViewController(interactor: interactor, router: router)
		_ = UINavigationController(rootViewController: viewController)
		presenter.viewController = viewController
		router.viewController = viewController
		router.dataStore = interactor
		viewController.tabBarItem = UITabBarItem(title: "List", image: #imageLiteral(resourceName: "icons8-table-of-content"), selectedImage: #imageLiteral(resourceName: "icons8-table-of-content-fill"))

		return viewController
	}

	func getSettingsScene() -> SettingsViewController {

		let presenter = SettingsPresenter()
		let settingsWorker = SettingsSceneWorker()
		let interactor = SettingsInteractor(presenter: presenter, settingsWorker: settingsWorker)
		let viewController = SettingsViewController(interactor: interactor)

		_ = UINavigationController(rootViewController: viewController)

		presenter.viewController = viewController

		viewController.tabBarItem = UITabBarItem(title: "Settings", image: #imageLiteral(resourceName: "icons8-settings"), selectedImage: #imageLiteral(resourceName: "icons8-settings-fill"))

		return viewController
	}

	func getInitialController() -> UIViewController {
		let dataBaseService = DataBaseService<SmartTargetCollection>()
		let repository = SmartTargetRepository(dataBaseService: dataBaseService)
		let mapViewController = getMapScene(withRepository: repository)
		let smartTargetListViewController = getSmartTargetListScene(withRepository: repository)
		let settingsViewController = getSettingsScene()

		return getTabBarController {
			mapViewController.navigationController ?? mapViewController
			smartTargetListViewController.navigationController ?? smartTargetListViewController
			settingsViewController.navigationController ?? settingsViewController
		}
	}

	func getDetailTargetScene(smartTargetListViewController: SmartTargetListViewController,
							  smartTarget: SmartTarget,
							  smartTargetCollection: ISmartTargetCollection) -> DetailTargetViewController {
		let router = DetailTargetRouter()
		let presenter = DetailTargetPresenter(smartTarget: smartTarget, smartTargetCollection: smartTargetCollection)
		let viewController = DetailTargetViewController(presenter: presenter,
														router: router,
														smartTargetEditable: smartTargetListViewController.isEditing)
		presenter.attachViewController(detailTargetViewController: viewController)
		router.attachViewController(detailTargetViewController: viewController)
		return viewController
	}
}
