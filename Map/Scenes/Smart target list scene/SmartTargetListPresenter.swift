//
//  SmartTargetListPresenter.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import Foundation

// MARK: - SmartTargetListPresentationLogic
protocol SmartTargetListPresentationLogic
{
	func presentLoadSmartTargets(_ response: SmartTargetList.LoadSmartTargets.Response)
	func presentSaveSmartTargets(_ response: SmartTargetList.SaveSmartTargets.Response)
	func presentUpdateSmartTargets(_ response: SmartTargetList.UpdateSmartTargets.Response)
}

// MARK: - Class
final class SmartTargetListPresenter
{
	// MARK: ...Internal properties
	weak var viewController: SmartTargetListDisplayLogic?
}

// MARK: - Smart target list presentation logic
extension SmartTargetListPresenter: SmartTargetListPresentationLogic
{
	func presentLoadSmartTargets(_ response: SmartTargetList.LoadSmartTargets.Response) {
		let didLoad: Bool
		switch response.result {
		case .success:
			didLoad = true
		case .failure(let error):
			didLoad = false
			print(error)
		}
		let viewModel = SmartTargetList.LoadSmartTargets.ViewModel(didLoad: didLoad)
		viewController?.displayLoadSmartTargets(viewModel)
	}

	func presentSaveSmartTargets(_ response: SmartTargetList.SaveSmartTargets.Response) {
		let didSave: Bool
		switch response.result {
		case .success:
			didSave = true
		case .failure(let error):
			didSave = false
			print(error)
		}
		let viewModel = SmartTargetList.SaveSmartTargets.ViewModel(didSave: didSave)
		viewController?.displaySaveSmartTargets(viewModel)
	}

	func presentUpdateSmartTargets(_ response: SmartTargetList.UpdateSmartTargets.Response) {
		let addedIndexPaths = response
			.addedSmartTargets
			.reduce(into: (counter: 0, indexPaths: [IndexPath]())) { result, _ in
				result.indexPaths.append(IndexPath(row: result.counter, section: 0))
				result.counter += 1
			}
			.indexPaths
		let removedIndexPaths = response
			.collection
			.indexes(at: response.removedSmartTargets)
			.map { IndexPath(row: $0, section: 0) }
		let updatedIndexPaths = response
			.collection
			.indexes(at: response.updatedSmartTargets)
			.map { IndexPath(row: $0, section: 0) }
		let viewModel =
			SmartTargetList.UpdateSmartTargets.ViewModel(addedIndexPaths: addedIndexPaths,
														 removedIndexPaths: removedIndexPaths,
														 updatedIndexPaths: updatedIndexPaths)
		viewController?.displayUpdateSmartTargets(viewModel)
	}
}
