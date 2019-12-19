//
//  MapPresenter.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

// MARK: - MapPresentationLogic protocol
protocol MapPresentationLogic
{
	func presentSmartTargets(response: Map.SmartTargets.Response)
	func takeCurrentCoordinate(response: Map.UpdateLocation.Response)
	func didChangeStatus(response: Map.UpdateStatus.Response)
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

	func takeCurrentCoordinate(response: Map.UpdateLocation.Response) {
		viewController?.showLocation(viewModel: Map.UpdateLocation.ViewModel(coordinate: response.coordinate))
	}

	func presentSmartTargets(response: Map.SmartTargets.Response) {
		let viewModel = Map.SmartTargets.ViewModel(smartTargets: response.smartTargets)
		viewController?.displaySmartTargets(viewModel: viewModel)
	}

	func didChangeStatus(response: Map.UpdateStatus.Response) {
		let viewModel = Map.UpdateStatus.ViewModel(manager: response.manager)
		viewController?.beginLocationUpdates(viewModel: viewModel.manager)
	}
}
