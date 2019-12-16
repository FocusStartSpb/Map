//
//  SmartTargetListRouter.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

// MARK: - SmartTargetListRoutingLogic protocol
protocol SmartTargetListRoutingLogic
{
	func routeToDetail()
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
	private let factory: SceneFactory

	// MARK: ...Internal properties
	weak var viewController: SmartTargetListViewController?
	var dataStore: SmartTargetListDataStore?

	// MARK: ...Initialization
	init(factory: SceneFactory) {
		self.factory = factory
	}
}

// MARK: - Smart target list routing logic
extension SmartTargetListRouter: SmartTargetListRoutingLogic
{
	// MARK: ...Routing
	func routeToDetail() {
		// Создаем DetailViewController
		//passDataToDetail(source: homeDS, destination: &detailDS)
		//navigateToDetail(source: viewController, destination: detailVC)
	}

	// MARK: ...Navigation
//	private func navigateToSomewhere(source: SmartTargetListViewController, destination: SomewhereViewController) {
//		source.show(destination, sender: nil)
//	}

	// MARK: ...Passing data
//	private func passDataToDetail(source: SmartTargetListDataStore, destination: inout SomewhereDataStore) {
//		destination.name = source.name
//	}
}

// MARK: - Smart target list data passing
extension SmartTargetListRouter: SmartTargetListDataPassing { }
