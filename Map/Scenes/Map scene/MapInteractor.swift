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
	func getSmartTargets(_ request: Map.FetchSmartTargets.Request)
	func configureLocationService(request: Map.UpdateStatus.Request)
	func returnToCurrentLocation(request: Map.UpdateStatus.Request)
	func saveSmartTarget(_ request: Map.SaveSmartTarget.Request)
	func getAddress(_ request: Map.Address.Request)
}

// MARK: - MapDataStore protocol
protocol MapDataStore
{
	var temptSmartTarget: SmartTarget? { get set }
}

// MARK: Class
final class MapInteractor<T: ISmartTargetRepository, G: IDecoderGeocoder>: NSObject, CLLocationManagerDelegate
	where T.Element: ISmartTargetCollection
{
	// MARK: ...Private properties
	private var presenter: MapPresentationLogic
	private var dataBaseWorker: DataBaseWorker<T>
	private var geocoderWorker: GeocoderWorker<G>

	private let locationManager = CLLocationManager()

	private var currentCoordinate: CLLocationCoordinate2D?

	private var smartTargetCollection: T.Element? = SmartTargetCollection() as? T.Element

	private let dispatchQueueGetAddress =
		DispatchQueue(label: "com.map.getAddress",
					  qos: .userInitiated,
					  attributes: .concurrent)

	private let dispatchQueueSaveSmartTargets =
		DispatchQueue(label: "com.map.saveSmartTargets",
					  qos: .userInitiated,
					  attributes: .concurrent)

	// MARK: ...Map data store
	var temptSmartTarget: SmartTarget?

	// MARK: ...Initialization
	init(presenter: MapPresentationLogic,
		 dataBaseWorker: DataBaseWorker<T>,
		 geocoderWorker: GeocoderWorker<G>) {
		self.presenter = presenter
		self.dataBaseWorker = dataBaseWorker
		self.geocoderWorker = geocoderWorker
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
		case .restricted, .denied:
			presenter.beginLocationUpdates(response: Map.UpdateStatus.Response(accessToLocationApproved: false,
																			   userCoordinate: nil))
		default:
			locationManager.requestAlwaysAuthorization()
		}
	}

	private func saveSmartTargetCollection(_ completion: @escaping (Bool) -> Void) {
		dispatchQueueSaveSmartTargets.async { [weak self] in
			guard let smartTargetCollection = self?.smartTargetCollection else { return }
			self?.dataBaseWorker.saveSmartTargets(smartTargetCollection) { result in
				let isSaved: Bool
				if case .success = result {
					isSaved = true
				}
				else {
					isSaved = false
				}
				completion(isSaved)
			}
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
	func getSmartTargets(_ request: Map.FetchSmartTargets.Request) {
		dataBaseWorker.fetchSmartTargets { [weak self] result in
			switch result {
			case .success(let collection):
				self?.smartTargetCollection = collection
				let response = Map.FetchSmartTargets.Response(smartTargetCollection: collection)
				self?.presenter.presentSmartTargets(response)
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

	func getAddress(_ request: Map.Address.Request) {
		dispatchQueueGetAddress.async { [weak self] in
			self?.geocoderWorker.getGeocoderMetaData(by: request.coordinate.geocode) { result in
				let response = Map.Address.Response(result: result,
													coordinate: request.coordinate)
				self?.presenter.presentAddress(response)
			}
		}
	}

	func saveSmartTarget(_ request: Map.SaveSmartTarget.Request) {
		smartTargetCollection?.put(request.smartTarget)
		saveSmartTargetCollection { [weak self] isSaved in
			self?.presenter.presentSaveSmartTarget(Map.SaveSmartTarget.Response(isSaved: isSaved))
		}
	}
		}
	}
}

// MARK: - Map data source
extension MapInteractor: MapDataStore { }
