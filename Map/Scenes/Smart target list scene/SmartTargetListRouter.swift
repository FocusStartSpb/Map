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
			let smartTarget = dataStore?.collection.smartTargets[indexPathAtRow] else { return }

		let detailViewController = factory.getDetailTargetScene(smartTarget: smartTarget)
		navigateToDetail(source: viewController, destination: detailViewController)
	}

	// MARK: ...Navigation
	private func navigateToDetail(source: SmartTargetListViewController,
								  destination: DetailTargetViewController) {
		source.navigationController?.pushViewController(destination, animated: true)
	}
}

// MARK: - Smart target list data passing
extension SmartTargetListRouter: SmartTargetListDataPassing { }
