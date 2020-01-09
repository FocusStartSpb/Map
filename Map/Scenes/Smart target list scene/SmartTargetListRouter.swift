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
	var dataStore: SmartTargetListDataStore? { get }
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
		guard let viewController = viewController else { return }
		guard let smartTarget = dataStore?.smartTargetCollection?.smartTargets[indexPathAtRow] else { return }
		let detailViewController = factory.getDetailTargetScene(smartTargetListViewController: viewController,
									 smartTarget: smartTarget)
		self.navigateToDetail(source: viewController, destination: detailViewController)
	}

	private func navigateToDetail(source: SmartTargetListViewController,
								  destination: DetailTargetViewController) {
		if source.isEditing {
			source.navigationController?.pushViewController(destination, animated: true)
		}
		else {
			source.present(destination, animated: true)
		}
	}

	func routeToMap(_ mapViewController: MapViewController) {
		guard
			let viewController = viewController,
			let sourceDataStore = dataStore,
			var destinationDataStore = mapViewController.router.dataStore else { return }

		passDataToMap(source: sourceDataStore, destination: &destinationDataStore)

		navigateToMap(source: viewController, destination: mapViewController)

		// Обнавляем временный коллекшен
		dataStore?.oldSmartTargetCollection = sourceDataStore.smartTargetCollection?.copy()
	}

	// MARK: ...Navigation
	private func navigateToMap(source: SmartTargetListViewController, destination: MapViewController) {
		source.tabBarController?.selectedViewController = destination
	}

	// MARK: ...Passing data
	private func passDataToMap(source: SmartTargetListDataStore, destination: inout MapDataStore) {
		destination.smartTargetCollection = source.smartTargetCollection
		destination.temptSmartTargetCollection = source.oldSmartTargetCollection
	}
}

// MARK: - Smart target list data passing
extension SmartTargetListRouter: SmartTargetListDataPassing { }
