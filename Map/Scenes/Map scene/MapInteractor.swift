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
	func getSmartTarget(_ request: Map.GetSmartTarget.Request)
	func configureLocationService(request: Map.UpdateStatus.Request)
	func returnToCurrentLocation(request: Map.UpdateStatus.Request)
	func saveSmartTarget(_ request: Map.SaveSmartTarget.Request)
	func removeSmartTarget(_ request: Map.RemoveSmartTarget.Request)
	func getAddress(_ request: Map.Address.Request)
	func getCurrentRadius(_ request: Map.GetCurrentRadius.Request)
	func getRangeRadius(_ request: Map.GetRangeRadius.Request)
	func getMeasuringSystem(_ request: Map.GetMeasuringSystem.Request)
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
	private var settingsWorker: SettingsWorker

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

	private var userValues: (lower: Double, upper: Double) {
		(lower: settingsWorker.lowerValueOfRadius ?? 0,
		 upper: settingsWorker.upperValueOfRadius ?? 0)
	}

	// MARK: ...Map data store
	var temptSmartTarget: SmartTarget?

	// MARK: ...Initialization
	init(presenter: MapPresentationLogic,
		 dataBaseWorker: DataBaseWorker<T>,
		 geocoderWorker: GeocoderWorker<G>,
		 settingsWorker: SettingsWorker) {
		self.presenter = presenter
		self.dataBaseWorker = dataBaseWorker
		self.geocoderWorker = geocoderWorker
		self.settingsWorker = settingsWorker
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
	func getSmartTarget(_ request: Map.GetSmartTarget.Request) {
		guard let smartTarget = smartTargetCollection?[request.uid] else { return }
		let response = Map.GetSmartTarget.Response(smartTarget: smartTarget)
		presenter.presentSmartTarget(response)
	}

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
			let response = Map.SaveSmartTarget.Response(isSaved: isSaved)
			self?.presenter.presentSaveSmartTarget(response)
		}
	}

	func removeSmartTarget(_ request: Map.RemoveSmartTarget.Request) {
		smartTargetCollection?.remove(atUID: request.uid)
		saveSmartTargetCollection { [weak self] isSaved in
			let response = Map.RemoveSmartTarget.Response(isRemoved: isSaved)
			self?.presenter.presentRemoveSmartTarget(response)
		}
	}

	func getCurrentRadius(_ request: Map.GetCurrentRadius.Request) {
		let response = Map.GetCurrentRadius.Response(currentRadius: request.currentRadius,
													 userValues: userValues)
		presenter.presentGetCurrentRadius(response)
	}

	func getRangeRadius(_ request: Map.GetRangeRadius.Request) {
		let response = Map.GetRangeRadius.Response(userValues: userValues)
		presenter.presentGetRangeRadius(response)
	}

	func getMeasuringSystem(_ request: Map.GetMeasuringSystem.Request) {
		let measuringSystem = settingsWorker.measuringSystem ?? .kilometer
		let response = Map.GetMeasuringSystem.Response(measuringSystem: measuringSystem)
		presenter.presentGetMeasuringSystem(response)
	}
}

// MARK: - Map data source
extension MapInteractor: MapDataStore { }
