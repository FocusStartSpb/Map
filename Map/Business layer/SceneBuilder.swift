//
//  SceneBuilder.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

final class SceneBuilder
{
	func getMapScene<T: ISmartTargetRepository>(withRepository repository: T) -> MapViewController
		where T.Element: ISmartTargetCollection {

		let presenter = MapPresenter()
		let dataBaseWorker = DataBaseWorker(repository: repository)
		let decoderService = DecoderService()
		let geocoderService = GeocoderService()
		let geocoderWorker = GeocoderWorker(service: geocoderService,
											decoder: decoderService)
		let interactor = MapInteractor(presenter: presenter,
									   dataBaseWorker: dataBaseWorker,
									   geocoderWorker: geocoderWorker)
		let viewController = MapViewController(interactor: interactor)

		presenter.viewController = viewController

		return viewController
	}

	func getSmartTargetListScene<T: ISmartTargetRepository>(withRepository repository: T) -> SmartTargetListViewController
		where T.Element: ISmartTargetCollection {

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
