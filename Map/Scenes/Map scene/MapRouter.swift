//
//  MapRoutingLogic.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 2.01.2020.
//

// MARK: - MapRoutingLogic protocol
protocol MapRoutingLogic
{
	func routeToSmartTargetList(_ smartTargetListViewController: SmartTargetListViewController)
}

// MARK: - MapDataPassing protocol
protocol MapDataPassing
{
	var dataStore: MapDataStore? { get }
}

final class MapRouter
{
	weak var viewController: MapViewController?
	var dataStore: MapDataStore?
}

// MARK: - Map routing logic
extension MapRouter: MapRoutingLogic
{
	// MARK: ...Routing
	func routeToSmartTargetList(_ smartTargetListViewController: SmartTargetListViewController) {
		guard
			let viewController = viewController,
			let sourceDataStore = dataStore,
			var destinationDataStore = smartTargetListViewController.router.dataStore else { return }
		passDataToSmartTargetList(source: sourceDataStore, destination: &destinationDataStore)

		navigateToSmartTargetList(source: viewController, destination: smartTargetListViewController)

		// Обновляем временный коллекшен
		dataStore?.temptSmartTargetCollection = sourceDataStore.smartTargetCollection?.copy()
	}

	// MARK: ...Navigation
	private func navigateToSmartTargetList(source: MapViewController, destination: SmartTargetListViewController) {
		source.tabBarController?.selectedViewController = destination.navigationController
	}

	// MARK: ...Passing data
	private func passDataToSmartTargetList(source: MapDataStore, destination: inout SmartTargetListDataStore) {
		destination.smartTargetCollection = source.smartTargetCollection
		destination.oldSmartTargetCollection = source.temptSmartTargetCollection?.copy()
		destination.didUpdateSmartTargets = false
	}
}

// MARK: - Map data passing
extension MapRouter: MapDataPassing { }
