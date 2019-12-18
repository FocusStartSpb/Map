//
//  MapInteractor.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import CoreLocation
// MARK: MapBusinessLogic protocol
protocol MapBusinessLogic
{
	func getSmartTargets(request: Map.SmartTargets.Request)
	func getCurrentCoordinate(request: Map.UpdateLocation.Request)
}

// MARK: Class
final class MapInteractor
{
	// MARK: ...Private properties
	private var presenter: MapPresentationLogic
	private var worker: DataWorker

	private var currentCoordinate: CLLocationCoordinate2D?

	// MARK: ...Initialization
	init(presenter: MapPresentationLogic, worker: DataWorker) {
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
				let response = Map.SmartTargets.Response(smartTargets: targets)
				//
				self?.presenter.presentSmartTargets(response: response)
			case .failure(let error):
				print(error)
			}
		}
	}

	func getCurrentCoordinate(request: Map.UpdateLocation.Request) {
		guard let latestLocation = request.locations.first else { return }
		if currentCoordinate == nil {
			presenter.takeCurrentCoordinate(response: Map.UpdateLocation.Response(coordinate: latestLocation.coordinate))
		}
		currentCoordinate = latestLocation.coordinate
	}
}
