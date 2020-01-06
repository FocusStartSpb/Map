//
//  MapPresenter.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import MapKit

// MARK: - MapPresentationLogic protocol
protocol MapPresentationLogic
{
	func presentSmartTargets(_ response: Map.FetchSmartTargets.Response)
	func presentSmartTarget(_ response: Map.GetSmartTarget.Response)
	func beginLocationUpdates(response: Map.UpdateStatus.Response)
	func presentAddress(_ response: Map.Address.Response)

	// Adding, updating, removing smart targets
	func presentAddSmartTarget(_ response: Map.AddSmartTarget.Response)
	func presentRemoveSmartTarget(_ response: Map.RemoveSmartTarget.Response)
	func presentUpdateSmartTarget(_ response: Map.UpdateSmartTarget.Response)

	func presentUpdateSmartTargets(_ response: Map.UpdateSmartTargets.Response)

	// Notifications
	func presentSetNotificationServiceDelegate(_ response: Map.SetNotificationServiceDelegate.Response)
	func presentAddNotification(_ response: Map.AddNotification.Response)
	func presentRemoveNotification(_ response: Map.RemoveNotification.Response)

	// Settings
	func presentGetCurrentRadius(_ response: Map.GetCurrentRadius.Response)
	func presentGetRangeRadius(_ response: Map.GetRangeRadius.Response)
	func presentGetMeasuringSystem(_ response: Map.GetMeasuringSystem.Response)
}

// MARK: - Class
final class MapPresenter
{
	// MARK: ...Internal properties
	weak var viewController: MapDisplayLogic?

	private func annotations(from targets: [SmartTarget]) -> [SmartTargetAnnotation] {
		targets.map { SmartTargetAnnotation(uid: $0.uid, title: $0.title, coordinate: $0.coordinates) }
	}
}

// MARK: - Map presentation logic
extension MapPresenter: MapPresentationLogic
{
	func presentSmartTargets(_ response: Map.FetchSmartTargets.Response) {
		let annotationArray = annotations(from: response.smartTargetCollection.smartTargets)
		let viewModel = Map.FetchSmartTargets.ViewModel(annotations: annotationArray)
		viewController?.displaySmartTargets(viewModel)
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
			.map { $0.response?.geoCollection?.featureMember?.first?.geo?.name ?? "Hello" }

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

	func presentAddNotification(_ response: Map.AddNotification.Response) {
		let viewModel = Map.AddNotification.ViewModel(completion: response.completion)
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.displayAddNotification(viewModel)
		}
	}

	func presentRemoveNotification(_ response: Map.RemoveNotification.Response) {
		let viewModel = Map.RemoveNotification.ViewModel(completion: response.completion)
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.displayRemoveNotification(viewModel)
		}
	}

	func presentUpdateSmartTarget(_ response: Map.UpdateSmartTarget.Response) {
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.displayUpdateSmartTarget(Map.UpdateSmartTarget.ViewModel(isUpdated: response.isUpdated))
		}
	}

	func presentUpdateSmartTargets(_ response: Map.UpdateSmartTargets.Response) {
		let viewModel =
			Map.UpdateSmartTargets.ViewModel(addedUIDs: response.addedSmartTargets.map { $0.uid },
											 removedUIDs: response.removedSmartTargets.map { $0.uid },
											 updatedUIDs: response.updatedSmartTargets.map { $0.uid })
		viewController?.displayUpdateSmartTargets(viewModel)
	}

	func presentGetCurrentRadius(_ response: Map.GetCurrentRadius.Response) {

		let radius: Double
		switch response.currentRadius {
		case ...response.userValues.lower: radius = response.userValues.lower
		case response.userValues.lower...response.userValues.upper: radius = response.currentRadius
		case ...response.userValues.lower: radius = response.currentRadius
		default: radius = response.userValues.upper
		}

		let viewModel = Map.GetCurrentRadius.ViewModel(radius: radius)
		viewController?.displayGetCurrentRadius(viewModel)
	}

	func presentGetRangeRadius(_ response: Map.GetRangeRadius.Response) {
		let viewModel = Map.GetRangeRadius.ViewModel(userValues: response.userValues)
		viewController?.displayGetRangeRadius(viewModel)
	}

	func presentGetMeasuringSystem(_ response: Map.GetMeasuringSystem.Response) {
		let symbol = response.measuringSystem.symbol
		let factor = response.measuringSystem.factor
		let viewModel = Map.GetMeasuringSystem.ViewModel(measuringSymbol: symbol,
														 measuringFactor: factor)
		viewController?.displayGetMeasuringSystem(viewModel)
	}
}
