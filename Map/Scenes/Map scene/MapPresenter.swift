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
	func beginLocationUpdates(response: Map.UpdateStatus.Response)
	func presentAddress(_ response: Map.Address.Response)
	func presentSaveSmartTarget(_ respose: Map.SaveSmartTarget.Response)
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

	func presentSaveSmartTarget(_ respose: Map.SaveSmartTarget.Response) {
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.displaySaveSmartTarget(Map.SaveSmartTarget.ViewModel(isSaved: respose.isSaved))
		}
	}
}
