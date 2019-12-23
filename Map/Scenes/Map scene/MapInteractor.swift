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
	func configureLocationService(request: Map.UpdateStatus.Request)
	func returnToCurrentLocation(request: Map.UpdateStatus.Request)
}

// MARK: Class
final class MapInteractor<T: ISmartTargetRepository>: NSObject, CLLocationManagerDelegate
{
	// MARK: ...Private properties
	private var presenter: MapPresentationLogic
	private var worker: DataBaseWorker<T>

	private let locationManager = CLLocationManager()

	private var currentCoordinate: CLLocationCoordinate2D?

	// MARK: ...Initialization
	init(presenter: MapPresentationLogic, worker: DataBaseWorker<T>) {
		self.presenter = presenter
		self.worker = worker
	}

	// MARK: ...Private methods
	private func checkAuthorizationService() {
		let status = CLLocationManager.authorizationStatus()
		switch status {
		case .notDetermined: locationManager.requestAlwaysAuthorization()
		case .authorizedAlways, .authorizedWhenInUse:
			locationManager.startUpdatingLocation()
			presenter.beginLocationUpdates(response: Map.UpdateStatus.Response(accessToLocationApproved: true,
																			   userCoordinate: currentCoordinate))
		default:
			locationManager.requestAlwaysAuthorization()
		}
	}
	// MARK: - CLLocationDelegate

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let latestCoordinate = locations.first?.coordinate else { return }
		if currentCoordinate == nil {
			presenter.beginLocationUpdates(response: Map.UpdateStatus.Response(accessToLocationApproved: true,
																			   userCoordinate: latestCoordinate))
		}
		currentCoordinate = locations.first?.coordinate
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkAuthorizationService()
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

	func configureLocationService(request: Map.UpdateStatus.Request) {
		locationManager.delegate = self
		checkAuthorizationService()
	}

	func returnToCurrentLocation(request: Map.UpdateStatus.Request) {
		checkAuthorizationService()
	}
}
