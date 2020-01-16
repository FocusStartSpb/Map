//
//  SmartTargetListRouter.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

// MARK: - SmartTargetListRoutingLogic protocol
protocol SmartTargetListRoutingLogic
{
	func routeToDetail(indexPathAtRow: Int)
	func routeToMap(_ mapViewController: MapViewController)
}

// MARK: - SmartTargetListDataPassing protocol
protocol SmartTargetListDataPassing
{
	var dataStore: SmartTargetListDataStore? { get set }
}

// MARK: - Class
final class SmartTargetListRouter
{
	// MARK: ...Private properties
	private let factory: SceneBuilder

	// MARK: ...Internal properties
	weak var viewController: SmartTargetListViewController?
	var dataStore: SmartTargetListDataStore?

	// MARK: ...Initialization
	init(factory: SceneBuilder) {
		self.factory = factory
	}
}

// MARK: - Smart target list routing logic
extension SmartTargetListRouter: SmartTargetListRoutingLogic
{
	// MARK: ...Routing
	func routeToDetail(indexPathAtRow: Int) {
		guard
			let viewController = viewController,
			let smartTarget = dataStore?.smartTargetCollection.smartTargets[indexPathAtRow] else { return }

		let detailViewController = factory.getDetailTargetScene(smartTarget: smartTarget)
		navigateToDetail(source: viewController, destination: detailViewController)
	}

	func routeToMap(_ mapViewController: MapViewController) {
		guard
			let viewController = viewController,
			let sourceDataStore = dataStore,
			var destinationDataStore = mapViewController.router.dataStore else { return }

		passDataToMap(source: sourceDataStore, destination: &destinationDataStore)

		navigateToMap(source: viewController, destination: mapViewController)
	}

	// MARK: ...Navigation
	private func navigateToMap(source: SmartTargetListViewController, destination: MapViewController) {
		source.tabBarController?.selectedViewController = destination
	}

	private func navigateToDetail(source: SmartTargetListViewController,
								  destination: DetailTargetViewController) {
		source.navigationController?.pushViewController(destination, animated: true)
	}

	// MARK: ...Passing data
	private func passDataToMap(source: SmartTargetListDataStore, destination: inout MapDataStore) { }
}

// MARK: - Smart target list data passing
extension SmartTargetListRouter: SmartTargetListDataPassing { }
