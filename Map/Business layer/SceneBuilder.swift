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
	private func getMapScene<T: ISmartTargetRepository>
		(dataBaseWorker: DataBaseWorker<T>,
		 collection: T.Element,
		 temptCollection: T.Element)
		-> MapViewController where T.Element: ISmartTargetCollection {

		let presenter = MapPresenter()
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
									   notificationWorker: notificationWorker,
									   collection: collection,
									   temptCollection: temptCollection)
		let router = MapRouter()
		let viewController = MapViewController(interactor: interactor, router: router)

		presenter.viewController = viewController
		router.viewController = viewController
		router.dataStore = interactor

		viewController.tabBarItem = UITabBarItem(title: "Карта", image: #imageLiteral(resourceName: "icons8-map-marker"), selectedImage: #imageLiteral(resourceName: "icons8-map-marker-fill"))

		return viewController
	}

	private func getSmartTargetListScene<T: ISmartTargetRepository>
		(dataBaseWorker: DataBaseWorker<T>,
		 collection: T.Element,
		 temptCollection: T.Element)
		-> SmartTargetListViewController where T.Element: ISmartTargetCollection {

		let presenter = SmartTargetListPresenter()
		let settingsWorker = SettingsWorker()
		let interactor = SmartTargetListInteractor(presenter: presenter,
												   dataBaseWorker: dataBaseWorker,
												   settingsWorker: settingsWorker,
												   collection: collection,
												   oldCollection: temptCollection)
		let router = SmartTargetListRouter(factory: self)
		let viewController = SmartTargetListViewController(interactor: interactor, router: router)

		_ = UINavigationController(rootViewController: viewController)

		presenter.viewController = viewController
		router.viewController = viewController
		router.dataStore = interactor
		viewController.tabBarItem = UITabBarItem(title: "Список", image: #imageLiteral(resourceName: "icons8-table-of-content"), selectedImage: #imageLiteral(resourceName: "icons8-table-of-content-fill"))

		return viewController
	}

	private func getSettingsScene() -> SettingsViewController {

		let presenter = SettingsPresenter()
		let settingsWorker = SettingsSceneWorker()
		let interactor = SettingsInteractor(presenter: presenter, settingsWorker: settingsWorker)
		let viewController = SettingsViewController(interactor: interactor)

		_ = UINavigationController(rootViewController: viewController)

		presenter.viewController = viewController
		viewController.tabBarItem = UITabBarItem(title: "Настройки", image: #imageLiteral(resourceName: "icons8-settings"), selectedImage: #imageLiteral(resourceName: "icons8-settings-fill"))

		return viewController
	}

	func getInitialController<T: ISmartTargetRepository>
		(dataBaseWorker: DataBaseWorker<T>,
		 withCollection collection: T.Element,
		 temptCollection: T.Element)
		-> UIViewController where T.Element: ISmartTargetCollection {

		let mapViewController =
			getMapScene(dataBaseWorker: dataBaseWorker,
						collection: collection,
						temptCollection: temptCollection)
		let smartTargetListViewController =
			getSmartTargetListScene(dataBaseWorker: dataBaseWorker,
									collection: collection,
									temptCollection: temptCollection)
		let settingsViewController = getSettingsScene()

		return getTabBarController {
			mapViewController.navigationController ?? mapViewController
			smartTargetListViewController.navigationController ?? smartTargetListViewController
			settingsViewController.navigationController ?? settingsViewController
		}
	}

	func getDetailTargetScene(smartTarget: SmartTarget) -> DetailTargetViewController {
		let router = DetailTargetRouter()
		let decoderService = DecoderService()
		let geocoderService = GeocoderService()
		let geocoderWorker = GeocoderWorker(service: geocoderService,
											decoder: decoderService)
		let presenter = DetailTargetPresenter(smartTarget: smartTarget,
											  geocoderWorker: geocoderWorker)
		let viewController = DetailTargetViewController(presenter: presenter,
														router: router)
		presenter.attachViewController(detailTargetViewController: viewController)
		router.attachViewController(detailTargetViewController: viewController)
		return viewController
	}
}
