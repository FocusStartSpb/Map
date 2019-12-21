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
	//func getCurrentCoordinate(request: Map.UpdateLocation.Request)
	func configureLocationService(request: Map.UpdateStatus.Request)
}

// MARK: Class
final class MapInteractor: NSObject
{
	// MARK: ...Private properties
	private var presenter: MapPresentationLogic
	private var worker: DataBaseWorker

	let locationManager = CLLocationManager()

	private var currentCoordinate: CLLocationCoordinate2D?

	// MARK: ...Initialization
	init(presenter: MapPresentationLogic, worker: DataBaseWorker) {
		self.presenter = presenter
		self.worker = worker
	}

	// MARK: ...Private methods
	private func checkAuthorizationService() {
		let status = CLLocationManager.authorizationStatus()
		if status == .authorizedAlways || status == .authorizedWhenInUse {
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.startUpdatingLocation()
			presenter.beginLocationUpdates(response: Map.UpdateStatus.Response(accessToLocationApproved: true,
																			   userCoordinate: currentCoordinate))
		}
		else {
			locationManager.requestAlwaysAuthorization()
			presenter.beginLocationUpdates(response: Map.UpdateStatus.Response(accessToLocationApproved: false,
																			   userCoordinate: currentCoordinate))
		}
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

//	func getCurrentCoordinate(request: Map.UpdateLocation.Request) {
//		guard let latestLocation = request.locations.first else { return }
//		if currentCoordinate == nil {
//			presenter.takeCurrentCoordinate(response: Map.UpdateLocation.Response(coordinate: latestLocation.coordinate))
//		}
//		currentCoordinate = latestLocation.coordinate
//	}

	func configureLocationService(request: Map.UpdateStatus.Request) {
		locationManager.delegate = self
		checkAuthorizationService()
	}
}
// MARK: - CLLocationDelegate

extension MapInteractor: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		currentCoordinate = locations.first?.coordinate
		checkAuthorizationService()
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkAuthorizationService()
	}
}
