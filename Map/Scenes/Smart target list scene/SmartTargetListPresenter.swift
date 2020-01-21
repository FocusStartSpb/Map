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
	func presentSaveSmartTargets(_ response: SmartTargetList.DeleteSmartTargets.Response) {
		let didSave: Bool
		let showAlertForceRemovePin: Bool
		switch response.result {
		case .success:
			didSave = true
			showAlertForceRemovePin = false
		case .failure:
			didSave = false
			showAlertForceRemovePin = false
		case .none:
			didSave = false
			showAlertForceRemovePin = true
		}
		let viewModel =
			SmartTargetList.DeleteSmartTargets.ViewModel(showAlertForceRemovePin: showAlertForceRemovePin,
														 didDelete: didSave,
														 removedIndexSet: response.removedIndexSet)
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.displayDeleteSmartTargets(viewModel)
		}
	}

	func presentUpdateSmartTargets(_ response: SmartTargetList.UpdateSmartTargets.Response) {
		var addedIndexSet = IndexSet()
		var removedIndexSet = IndexSet()
		var updatedIndexSet = IndexSet()

		defer {
			let viewModel = SmartTargetList.UpdateSmartTargets.ViewModel(needUpdate: response.difference.isEmpty == false,
																		 addedIndexSet: addedIndexSet,
																		 removedIndexSet: removedIndexSet,
																		 updatedIndexSet: updatedIndexSet)
			viewController?.displayUpdateSmartTargets(viewModel)
		}

		guard response.difference.isEmpty == false else { return }

		addedIndexSet = IndexSet(0..<response.difference.added.count)
		updatedIndexSet = IndexSet(response
			.collection
			.indexes(at: response.difference.updated))
		removedIndexSet = IndexSet(response
			.collection
			.indexes(at: response.difference.removed))
	}

	func presentUpdateSmartTarget(_ response: SmartTargetList.UpdateSmartTarget.Response) {
		var updateTargetIndexSet = IndexSet()
		let needUpdate = response.editedSmartTarget !== response.oldSmartTarget

		defer {
			let viewModel = SmartTargetList.UpdateSmartTarget.ViewModel(needUpdate: needUpdate,
																		updatedIndexSet: updateTargetIndexSet)
			DispatchQueue.main.async { [weak self] in
				self?.viewController?.updateEditedSmartTarget(viewModel)
			}
		}

		guard needUpdate else { return }
		updateTargetIndexSet = IndexSet(integer: response.editedSmartTargetIndex)
	}

	func presentEmptyView(_ response: SmartTargetList.ShowEmptyView.Response) {
		let viewModel = SmartTargetList.ShowEmptyView.ViewModel(showEmptyView: response.showEmptyView)
		viewController?.showEmptyView(viewModel)
	}
}
