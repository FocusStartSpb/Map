//
//  MapInteractor.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import CoreLocation
import UIKit

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
	func setNotificationServiceDelegate(_ request: Map.SetNotificationServiceDelegate.Request)
	func notificationRequestAuthorization(_ request: Map.NotificationRequestAuthorization.Request)
	func addNotification(_ request: Map.AddNotification.Request)
	func removeNotification(_ request: Map.RemoveNotification.Request)
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

	private let notificationService = NotificationService.default

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
			self?.presenter.presentSaveSmartTarget(Map.SaveSmartTarget.Response(isSaved: isSaved))
		}
	}

	func removeSmartTarget(_ request: Map.RemoveSmartTarget.Request) {
		smartTargetCollection?.remove(atUID: request.uid)
		saveSmartTargetCollection { [weak self] isSaved in
			self?.presenter.presentRemoveSmartTarget(Map.RemoveSmartTarget.Response(isRemoved: isSaved))
		}
	}

	func setNotificationServiceDelegate(_ request: Map.SetNotificationServiceDelegate.Request) {
		notificationService.delegate = request.notificationDelegate
		let response = Map.SetNotificationServiceDelegate.Response(isSet: true)
		presenter.presentSetNotificationServiceDelegate(response)
	}

	func notificationRequestAuthorization(_ request: Map.NotificationRequestAuthorization.Request) {
		let center = notificationService.center
		center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
			if granted {
				DispatchQueue.main.async {
					UIApplication.shared.registerForRemoteNotifications()
				}
				let response = Map.NotificationRequestAuthorization.Response(iaAuthorized: true)
				self?.presenter.presentNotificationRequestAuthorization(response)
			}
			else {
				let response = Map.NotificationRequestAuthorization.Response(iaAuthorized: false)
				self?.presenter.presentNotificationRequestAuthorization(response)
			}
		}
	}

	private func notificationRequestAuthorization(completionHandler: @escaping (Bool) -> Void) {
		let center = notificationService.center
		center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
			if granted {
				DispatchQueue.main.async {
					UIApplication.shared.registerForRemoteNotifications()
					completionHandler(granted)
				}
			}
			else {
				completionHandler(granted)
			}
		}
	}

	private func addNotification(for smartTarget: SmartTarget) {
		if let smartTargetCollection = smartTargetCollection, smartTargetCollection.contains(smartTarget) {
			notificationService.updateLocationNotification(center: smartTarget.coordinates,
														   radius: smartTarget.radius ?? 100,
														   title: smartTarget.title,
														   subtitle: smartTarget.address ?? "",
														   body: "Какая-то строка",
														   uid: smartTarget.uid)
		}
		else {
			notificationService.addLocationNotificationWith(center: smartTarget.coordinates,
															radius: smartTarget.radius ?? 100,
															title: smartTarget.title,
															subtitle: smartTarget.address ?? "",
															body: "Какая-то строка",
															uid: smartTarget.uid)
		}
	}

	func addNotification(_ request: Map.AddNotification.Request) {
		notificationRequestAuthorization { [weak self] granted in
			if granted {
				self?.addNotification(for: request.smartTarget)
			}
			let response = Map.AddNotification.Response(isAdded: granted)
			self?.presenter.presentAddNotification(response)
		}
	}

	func removeNotification(_ request: Map.RemoveNotification.Request) {
		notificationService.removePendingNotification(at: request.uid)
		let response = Map.RemoveNotification.Response(isRemoved: true)
		presenter.presentRemoveNotification(response)
	}
}

// MARK: - Map data source
extension MapInteractor: MapDataStore { }
