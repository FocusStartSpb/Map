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
	func getAnnotations(_ request: Map.FetchAnnotations.Request)
	func getSmartTarget(_ request: Map.GetSmartTarget.Request)
	func configureLocationService(_ request: Map.UpdateStatus.Request)
	func getAddress(_ request: Map.Address.Request)

	// Adding, updating, removing smart targets
	func addSmartTarget(_ request: Map.AddSmartTarget.Request)
	func updateSmartTarget(_ request: Map.UpdateSmartTarget.Request)
	func removeSmartTarget(_ request: Map.RemoveSmartTarget.Request)

	func updateAnnotations(_ request: Map.UpdateAnnotations.Request)

	// Notifications
	func setNotificationServiceDelegate(_ request: Map.SetNotificationServiceDelegate.Request)

	// Monitoring Region
	func startMonitoringRegion(_ request: Map.StartMonitoringRegion.Request)
	func stopMonitoringRegion(_ request: Map.StopMonitoringRegion.Request)

	// Settings
	func getCurrentRadius(_ request: Map.GetCurrentRadius.Request)
	func getRangeRadius(_ request: Map.GetRangeRadius.Request)
	func measurementSystem(_ request: Map.GetMeasurementSystem.Request)
	func getRemovePinAlertSettings(_ request: Map.GetRemovePinAlertSettings.Request)
}

// MARK: - MapDataStore protocol
protocol MapDataStore
{
	var temptSmartTarget: SmartTarget? { get set }
	var didUpdateAllAnnotations: Bool { get set }
}

// MARK: Class
final class MapInteractor<T: ISmartTargetRepository, G: IDecoderGeocoder>: NSObject, CLLocationManagerDelegate
	where T.Element: ISmartTargetCollection
{
	// MARK: ...Private properties
	private let presenter: MapPresentationLogic
	private let dataBaseWorker: DataBaseWorker<T>
	private let geocoderWorker: GeocoderWorker<G>
	private let settingsWorker: SettingsWorker
	private let notificationWorker: NotificationWorker
	private lazy var locationManager: CLLocationManager = {
		let locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.allowsBackgroundLocationUpdates = true
		locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
		return locationManager
	}()

	private var currentCoordinate: CLLocationCoordinate2D?

	private let temptSmartTargetCollection: T.Element
	private let smartTargetCollection: T.Element

	private var pendingRequesrWorkItem: DispatchWorkItem?
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
	var didUpdateAllAnnotations = false

	// MARK: ...Initialization
	init(presenter: MapPresentationLogic,
		 dataBaseWorker: DataBaseWorker<T>,
		 geocoderWorker: GeocoderWorker<G>,
		 settingsWorker: SettingsWorker,
		 notificationWorker: NotificationWorker,
		 collection: T.Element,
		 temptCollection: T.Element) {
		self.presenter = presenter
		self.dataBaseWorker = dataBaseWorker
		self.geocoderWorker = geocoderWorker
		self.settingsWorker = settingsWorker
		self.notificationWorker = notificationWorker
		self.smartTargetCollection = collection
		self.temptSmartTargetCollection = temptCollection
	}

	// MARK: ...Private methods
	private func authorizationLocationResponse(_ isApproved: Bool, coordinate: CLLocationCoordinate2D?) {
		let response = Map.UpdateStatus.Response(accessToLocationApproved: isApproved,
												 userCoordinate: coordinate)
		presenter.beginLocationUpdates(response: response)
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

	private func performGetAddress(after: TimeInterval, _ block: @escaping () -> Void) {
		pendingRequesrWorkItem?.cancel()

		let requestWorkItem = DispatchWorkItem(block: block)

		pendingRequesrWorkItem = requestWorkItem

		dispatchQueueGetAddress.asyncAfter(deadline: .now() + after, execute: requestWorkItem)
	}

	// MARK: ...CLLocationDelegate
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .notDetermined, .restricted, .denied:
			authorizationLocationResponse(false, coordinate: nil)
		case .authorizedAlways, .authorizedWhenInUse:
			authorizationLocationResponse(true, coordinate: locationManager.location?.coordinate)
		@unknown default:
			fatalError("Unknown case")
		}
	}

	func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
		notificationWorker.requestNotificationAuthorized { _ in }
		let response = Map.StartMonitoringRegion.Response(isStarted: true)
		presenter.presentStartMonitoringRegion(response)
	}

	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		guard var smartTarget = smartTargetCollection[region.identifier] else { return }
		smartTarget.entryDate = Date()
		smartTargetCollection.put(smartTarget)
		saveSmartTargetCollection { _ in }
		notificationWorker.addNotifications(for: [smartTarget])
	}

	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		guard var smartTarget = smartTargetCollection[region.identifier] else { return }
		smartTarget.exitDate = Date()
		smartTargetCollection.put(smartTarget)
		saveSmartTargetCollection { _ in }
		notificationWorker.addNotifications(for: [smartTarget])
	}

	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		let response = Map.StartMonitoringRegion.Response(isStarted: false)
		presenter.presentStartMonitoringRegion(response)
	}
}

// MARK: - Map display logic
extension MapInteractor: MapBusinessLogic
{

	func getSmartTarget(_ request: Map.GetSmartTarget.Request) {
		guard let smartTarget = smartTargetCollection[request.uid] else { return }
		let response = Map.GetSmartTarget.Response(smartTarget: smartTarget)
		presenter.presentSmartTarget(response)
	}

	func getAnnotations(_ request: Map.FetchAnnotations.Request) {
		let response = Map.FetchAnnotations.Response(smartTargetCollection: smartTargetCollection.copy())
			presenter.presentAnnotations(response)
	}

	func configureLocationService(_ request: Map.UpdateStatus.Request) {
		switch CLLocationManager.authorizationStatus() {
		case .notDetermined:
			locationManager.requestAlwaysAuthorization()
		case .authorizedAlways, .authorizedWhenInUse:
			authorizationLocationResponse(true, coordinate: nil)
		case .restricted, .denied:
			authorizationLocationResponse(false, coordinate: nil)
		@unknown default:
			fatalError("Unknown case")
		}
	}

	func getAddress(_ request: Map.Address.Request) {
		performGetAddress(after: 0.35) { [weak self] in
			self?.geocoderWorker.getGeocoderMetaData(by: request.coordinate.geocode) { result in
				let response = Map.Address.Response(result: result,
													coordinate: request.coordinate)
				self?.presenter.presentAddress(response)
			}
		}
	}

	func addSmartTarget(_ request: Map.AddSmartTarget.Request) {
		smartTargetCollection.put(request.smartTarget)
		saveSmartTargetCollection { [weak self] isSaved in
			let response = Map.AddSmartTarget.Response(isAdded: isSaved)
			self?.presenter.presentAddSmartTarget(response)
		}
	}

	func removeSmartTarget(_ request: Map.RemoveSmartTarget.Request) {
		smartTargetCollection.remove(atUID: request.uid)
		saveSmartTargetCollection { [weak self] isSaved in
			let response = Map.RemoveSmartTarget.Response(isRemoved: isSaved)
			self?.presenter.presentRemoveSmartTarget(response)
		}
	}

	func updateSmartTarget(_ request: Map.UpdateSmartTarget.Request) {
		smartTargetCollection.put(request.smartTarget)
		saveSmartTargetCollection { [weak self] isSaved in
			let response = Map.UpdateSmartTarget.Response(isUpdated: isSaved)
			self?.presenter.presentUpdateSmartTarget(response)
		}
	}

	func setNotificationServiceDelegate(_ request: Map.SetNotificationServiceDelegate.Request) {
		notificationWorker.setDelegate(request.notificationDelegate)
		let response = Map.SetNotificationServiceDelegate.Response(isSet: true)
		presenter.presentSetNotificationServiceDelegate(response)
	}

	func startMonitoringRegion(_ request: Map.StartMonitoringRegion.Request) {
		locationManager.startMonitoring(for: request.smartTarget.region)
	}

	func stopMonitoringRegion(_ request: Map.StopMonitoringRegion.Request) {
		var isStoped = true
		defer {
			let response = Map.StopMonitoringRegion.Response(isStoped: isStoped)
			presenter.presentStopMonitoringRegion(response)
		}
		guard let region = locationManager.monitoredRegions.first(where: { $0.identifier == request.uid }) else {
			isStoped = false
			return
		}
		locationManager.stopMonitoring(for: region)
		notificationWorker.removeNotification(at: request.uid)
	}

	func updateAnnotations(_ request: Map.UpdateAnnotations.Request) {
		guard didUpdateAllAnnotations == false else { return }
		let oldCollection = temptSmartTargetCollection.copy()
		let difference = smartTargetCollection.smartTargetsOfDifference(from: oldCollection)
		let response = Map.UpdateAnnotations.Response(annotations: request.annotations,
													  collection: smartTargetCollection.copy(),
													  difference: difference)
		temptSmartTargetCollection.replaceSmartTargets(with: smartTargetCollection.smartTargets)
		presenter.presentUpdateAnnotations(response)
		didUpdateAllAnnotations = true
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

	func measurementSystem(_ request: Map.GetMeasurementSystem.Request) {
		let measurementSystem = settingsWorker.measurementSystem ?? .metric
		let response = Map.GetMeasurementSystem.Response(measurementSystem: measurementSystem)
		presenter.presentGetMeasurementSystem(response)
	}

	func getRemovePinAlertSettings(_ request: Map.GetRemovePinAlertSettings.Request) {
		let alertOn = settingsWorker.forceRemovePin ?? true
		let response = Map.GetRemovePinAlertSettings.Response(removePinAlertOn: alertOn)
		presenter.presentGetRemovePinAlertSettings(response)
	}
}

// MARK: - Map data source
extension MapInteractor: MapDataStore { }
