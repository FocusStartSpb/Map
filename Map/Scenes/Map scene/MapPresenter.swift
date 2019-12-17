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
		let viewModel = Map.SmartTargets.ViewModel(smartTargets: response.smartTargets)
		viewController?.displaySmartTargets(viewModel: viewModel)
	}
}
