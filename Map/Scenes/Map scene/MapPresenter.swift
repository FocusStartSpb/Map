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
	func presentSmartTargets(response: Map.SmartTargets.Response)
	func beginLocationUpdates(response: Map.UpdateStatus.Response)
	func presentAddress(_ response: Map.Address.Response)
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
	func presentSmartTargets(response: Map.SmartTargets.Response) {
		let viewModel = Map.SmartTargets.ViewModel(smartTargetCollection: response.smartTargetCollection)
		viewController?.displaySmartTargets(viewModel: viewModel)
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
}
