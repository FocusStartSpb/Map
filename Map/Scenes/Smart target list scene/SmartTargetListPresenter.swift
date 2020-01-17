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
	func presentSaveSmartTargets(_ response: SmartTargetList.DeleteSmartTargets.Response)
	func presentUpdateSmartTargets(_ response: SmartTargetList.UpdateSmartTargets.Response)
	func presentUpdateSmartTarget(_ response: SmartTargetList.UpdateSmartTarget.Response)
	func presentEmptyView(_ response: SmartTargetList.ShowEmptyView.Response)
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

	func presentSaveSmartTargets(_ response: SmartTargetList.DeleteSmartTargets.Response) {
		let didSave: Bool
		switch response.result {
		case .success:
			didSave = true
		case .failure(let error):
			didSave = false
			print(error)
		}
		let viewModel = SmartTargetList.DeleteSmartTargets.ViewModel(didDelete: didSave)
		viewController?.displayDeleteSmartTargets(viewModel)
	}

	func presentUpdateSmartTargets(_ response: SmartTargetList.UpdateSmartTargets.Response) {
		let addedIndexSet = IndexSet(0..<response.addedSmartTargets.count)
		let updatedIndexSet = IndexSet(response
			.collection
			.indexes(at: response.updatedSmartTargets))
		let removedIndexSet = IndexSet(response
			.collection
			.indexes(at: response.removedSmartTargets))
		let viewModel = SmartTargetList.UpdateSmartTargets.ViewModel(addedIndexSet: addedIndexSet,
																	 removedIndexSet: removedIndexSet,
																	 updatedIndexSet: updatedIndexSet)
		viewController?.displayUpdateSmartTargets(viewModel)
	}

	func presentUpdateSmartTarget(_ response: SmartTargetList.UpdateSmartTarget.Response) {
		let updateTargetIndexSet = IndexSet(integer: response.editedSmartTargetIndex)
		let viewModel = SmartTargetList.UpdateSmartTarget.ViewModel(updatedIndexSet: updateTargetIndexSet)
		viewController?.updateEditedSmartTarget(viewModel)
	}

	func presentEmptyView(_ response: SmartTargetList.ShowEmptyView.Response) {
		let viewModel = SmartTargetList.ShowEmptyView.ViewModel(showEmptyView: response.showEmptyView)
		viewController?.showEmptyView(viewModel)
	}
}
