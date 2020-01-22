//
//  MapPresenter.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import Foundation

// MARK: - MapPresentationLogic protocol
protocol MapPresentationLogic
{
	func presentAnnotations(_ response: Map.FetchAnnotations.Response)
	func presentSmartTarget(_ response: Map.GetSmartTarget.Response)
	func beginLocationUpdates(response: Map.UpdateStatus.Response)
	func presentAddress(_ response: Map.Address.Response)

	// Adding, updating, removing smart targets
	func presentAddSmartTarget(_ response: Map.AddSmartTarget.Response)
	func presentRemoveSmartTarget(_ response: Map.RemoveSmartTarget.Response)
	func presentUpdateSmartTarget(_ response: Map.UpdateSmartTarget.Response)

	func presentUpdateAnnotations(_ response: Map.UpdateAnnotations.Response)

	func presentCanCreateSmartTarget(_ response: Map.CanCreateSmartTarget.Response)

	// Notifications
	func presentSetNotificationServiceDelegate(_ response: Map.SetNotificationServiceDelegate.Response)

	// Monitoring Region
	func presentStartMonitoringRegion(_ response: Map.StartMonitoringRegion.Response)
	func presentStopMonitoringRegion(_ response: Map.StopMonitoringRegion.Response)

	// Settings
	func presentGetCurrentRadius(_ response: Map.GetCurrentRadius.Response)
	func presentGetRangeRadius(_ response: Map.GetRangeRadius.Response)
	func presentGetMeasurementSystem(_ response: Map.GetMeasurementSystem.Response)
	func presentGetRemovePinAlertSettings(_ response: Map.GetRemovePinAlertSettings.Response)
}

// MARK: - Class
final class MapPresenter
{
	// MARK: ...Internal properties
	weak var viewController: MapDisplayLogic?
}

// MARK: - Map presentation logic
extension MapPresenter: MapPresentationLogic
{

	func presentAnnotations(_ response: Map.FetchAnnotations.Response) {
		let annotationArray = response.smartTargetCollection.smartTargets.map { $0.annotation }
		let viewModel = Map.FetchAnnotations.ViewModel(annotations: annotationArray)
		viewController?.displayAnnotations(viewModel)
	}

	func presentSmartTarget(_ response: Map.GetSmartTarget.Response) {
		let viewModel = Map.GetSmartTarget.ViewModel(smartTarget: response.smartTarget)
		viewController?.displaySmartTarget(viewModel)
	}

	func beginLocationUpdates(response: Map.UpdateStatus.Response) {
		viewController?.showLocationUpdates(viewModel:
			.init(isShownUserPosition: response.accessToLocationApproved,
				  userCoordinate: response.userCoordinate))
	}

	func presentAddress(_ response: Map.Address.Response) {
		let result = response.result
			.map { $0.response?.geoCollection?.featureMember?.first?.geo?.metaDataProperty?.geocoderMetaData?.text ?? "" }

		let address: String
		if case .success(let string) = result {
			address = string
		}
		else {
			address = "\(response.coordinate)"
		}

		let viewModel = Map.Address.ViewModel(address: address)

		DispatchQueue.main.async { [weak self] in
			self?.viewController?.displayAddress(viewModel)
		}
	}

	func presentAddSmartTarget(_ response: Map.AddSmartTarget.Response) {
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.displayAddSmartTarget(Map.AddSmartTarget.ViewModel(isAdded: response.isAdded))
		}
	}

	func presentRemoveSmartTarget(_ response: Map.RemoveSmartTarget.Response) {
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.displayRemoveSmartTarget(Map.RemoveSmartTarget.ViewModel(isRemoved: response.isRemoved))
		}
	}

	func presentSetNotificationServiceDelegate(_ response: Map.SetNotificationServiceDelegate.Response) {
		let viewModel = Map.SetNotificationServiceDelegate.ViewModel(isSet: response.isSet)
		viewController?.displaySetNotificationServiceDelegate(viewModel)
	}

	func presentStartMonitoringRegion(_ response: Map.StartMonitoringRegion.Response) {
		let viewModel = Map.StartMonitoringRegion.ViewModel(isStarted: response.isStarted)
		viewController?.displayStartMonitoringRegion(viewModel)
	}

	func presentStopMonitoringRegion(_ response: Map.StopMonitoringRegion.Response) {
		let viewModel = Map.StopMonitoringRegion.ViewModel(isStoped: response.isStoped)
		viewController?.displayStopMonitoringRegion(viewModel)
	}

	func presentUpdateSmartTarget(_ response: Map.UpdateSmartTarget.Response) {
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.displayUpdateSmartTarget(Map.UpdateSmartTarget.ViewModel(isUpdated: response.isUpdated))
		}
	}

	func presentUpdateAnnotations(_ response: Map.UpdateAnnotations.Response) {

		var removedAnnotations = [SmartTargetAnnotation]()
		var addedAnnotations = [SmartTargetAnnotation]()

		defer {
			let viewModel = Map.UpdateAnnotations.ViewModel(needUpdate: response.difference.isEmpty == false,
															removedAnnotations: removedAnnotations,
															addedAnnotations: addedAnnotations)
			viewController?.displayUpdateAnnotations(viewModel)
		}

		guard response.difference.isEmpty == false else { return }

		removedAnnotations = response.annotations.filter { annotation in
			response.difference.removed.contains { annotation.uid == $0.uid } ||
			response.difference.updated.contains { annotation.uid == $0.uid }
		}

		addedAnnotations = (response.difference.added + response.difference.updated).reduce(into: addedAnnotations) {
			guard let annotation = response.collection[$1.uid]?.annotation else { return }
			$0.append(annotation)
		}
	}

	func presentCanCreateSmartTarget(_ response: Map.CanCreateSmartTarget.Response) {
		let viewModel =
			Map.CanCreateSmartTarget.ViewModel(canCreate: response.monitoredRegionsCount < Constants.maxSmartTargets)
		viewController?.displayCanCreateSmartTarget(viewModel)
	}

	func presentGetCurrentRadius(_ response: Map.GetCurrentRadius.Response) {

		let radius: Double
		switch response.currentRadius {
		case ..<response.userValues.lower: radius = response.userValues.lower
		case response.userValues.lower...response.userValues.upper: radius = response.currentRadius
		default: radius = response.userValues.upper
		}

		let viewModel = Map.GetCurrentRadius.ViewModel(radius: radius)
		viewController?.displayGetCurrentRadius(viewModel)
	}

	func presentGetRangeRadius(_ response: Map.GetRangeRadius.Response) {
		let viewModel = Map.GetRangeRadius.ViewModel(userValues: response.userValues)
		viewController?.displayGetRangeRadius(viewModel)
	}

	func presentGetMeasurementSystem(_ response: Map.GetMeasurementSystem.Response) {
		let symbol = response.measurementSystem.symbol
		let factor = response.measurementSystem.factor
		let viewModel = Map.GetMeasurementSystem.ViewModel(measurementSymbol: symbol,
														   measurementFactor: factor)
		viewController?.displayGetMeasurementSystem(viewModel)
	}

	func presentGetRemovePinAlertSettings(_ response: Map.GetRemovePinAlertSettings.Response) {
		let viewModel = Map.GetRemovePinAlertSettings.ViewModel(removePinAlertOn: response.removePinAlertOn)
		viewController?.displayGetRemovePinAlertSettings(viewModel)
	}
}
