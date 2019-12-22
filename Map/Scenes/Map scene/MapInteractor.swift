//
//  MapInteractor.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

// MARK: MapBusinessLogic protocol
protocol MapBusinessLogic
{
	func getSmartTargets(request: Map.SmartTargets.Request)
}

// MARK: Class
final class MapInteractor<T: ISmartTargetRepository>
{
	// MARK: ...Private properties
	private var presenter: MapPresentationLogic
	private var worker: DataBaseWorker<T>

	// MARK: ...Initialization
	init(presenter: MapPresentationLogic, worker: DataBaseWorker<T>) {
		self.presenter = presenter
		self.worker = worker
	}
}

// MARK: - Map display logic
extension MapInteractor: MapBusinessLogic
{
	func getSmartTargets(request: Map.SmartTargets.Request) {
		worker.fetchSmartTargets { [weak self] result in
			switch result {
			case .success(let targets):
				// Создаем респонс
				let response = Map.SmartTargets.Response(smartTargetCollection: targets)
				//
				self?.presenter.presentSmartTargets(response: response)
			case .failure(let error):
				print(error)
			}
		}
	}
}
