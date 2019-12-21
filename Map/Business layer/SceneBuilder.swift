//
//  SceneBuilder.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

final class SceneBuilder
{
	func getMapScene(
		withRepository repository: ISmartTargetRepository) -> MapViewController {

		let presenter = MapPresenter()
		let worker = DataBaseWorker(repository: repository)
		let interactor = MapInteractor(presenter: presenter, worker: worker)
		let viewController = MapViewController(interactor: interactor)

		presenter.viewController = viewController

		return viewController
	}

	func getSmartTargetListScene(
		withRepository repository: ISmartTargetRepository) -> SmartTargetListViewController {

		let presenter = SmartTargetListPresenter()
		let worker = DataBaseWorker(repository: repository)
		let interactor = SmartTargetListInteractor(presenter: presenter, worker: worker)
		let router = SmartTargetListRouter(factory: self)
		let viewController = SmartTargetListViewController(interactor: interactor, router: router)

		presenter.viewController = viewController
		router.viewController = viewController
		router.dataStore = interactor

		return viewController
	}
}
