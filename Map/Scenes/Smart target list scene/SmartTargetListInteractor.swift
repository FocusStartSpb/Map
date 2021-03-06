//
//  SmartTargetListInteractor.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

import Foundation

// MARK: - SmartTargetListBusinessLogic protocol
protocol SmartTargetListBusinessLogic
{
	func setupInitial(_ request: SmartTargetList.SetupInitial.Request)
	func deleteSmartTargets(_ request: SmartTargetList.DeleteSmartTargets.Request)
	func updateSmartTargets(_ request: SmartTargetList.UpdateSmartTargets.Request)
	func updateSmartTarget(_ request: SmartTargetList.UpdateSmartTarget.Request)
	func showEmptyView(_ request: SmartTargetList.ShowEmptyView.Request)
}

// MARK: - SmartTargetListDataStore protocol
protocol SmartTargetListDataStore
{
	var collection: ISmartTargetCollection { get }
	var editedSmartTarget: SmartTarget? { get set }
	var didUpdateAllSmartTargets: Bool { get set }
	var removedIndexSet: IndexSet? { get set }
}

// MARK: - Class
final class SmartTargetListInteractor<T: ISmartTargetRepository> where T.Element: ISmartTargetCollection
{
	// MARK: ...Private properties
	private let presenter: SmartTargetListPresentationLogic
	private let dataBaseWorker: DataBaseWorker<T>
	private let settingsWorker: SettingsWorker

	private let oldSmartTargetCollection: T.Element
	private let smartTargetCollection: T.Element

	// MARK: ...Map data store
	var didUpdateAllSmartTargets = false
	var editedSmartTarget: SmartTarget?
	var removedIndexSet: IndexSet?

	// MARK: ...Initialization
	init(presenter: SmartTargetListPresentationLogic,
		 dataBaseWorker: DataBaseWorker<T>,
		 settingsWorker: SettingsWorker,
		 collection: T.Element,
		 oldCollection: T.Element) {
		self.presenter = presenter
		self.dataBaseWorker = dataBaseWorker
		self.settingsWorker = settingsWorker
		self.smartTargetCollection = collection
		self.oldSmartTargetCollection = oldCollection
	}
}

// MARK: - Smart target list business logic
extension SmartTargetListInteractor: SmartTargetListBusinessLogic
{
	func setupInitial(_ request: SmartTargetList.SetupInitial.Request) {
		didUpdateAllSmartTargets = true
		oldSmartTargetCollection.replaceSmartTargets(with: smartTargetCollection.smartTargets)
		let response = SmartTargetList.SetupInitial.Response(isFinished: true)
		presenter.presentSetupInitial(response)
	}

	func deleteSmartTargets(_ request: SmartTargetList.DeleteSmartTargets.Request) {
		if removedIndexSet != request.removedIndexSet, settingsWorker.forceRemovePin ?? true {
			removedIndexSet = request.removedIndexSet
			let response =
				SmartTargetList.DeleteSmartTargets.Response(showAlertForceRemovePin: true,
															result: nil,
															removedIndexSet: nil)
			presenter.presentSaveSmartTargets(response)
			request.completionHandler(false)
		}
		else {
			removedIndexSet = nil
			request.smartTargetsIndexSet.forEach { index in
				let uuid = self.smartTargetCollection.smartTargets[Int(index)].uid
				self.smartTargetCollection.remove(atUID: uuid)
			}
			saveSmartTargetCollection { [weak self] result in
				let response =
					SmartTargetList.DeleteSmartTargets.Response(showAlertForceRemovePin: false,
																result: result,
																removedIndexSet: request.removedIndexSet)
				self?.presenter.presentSaveSmartTargets(response)
				request.completionHandler(true)
			}
		}
	}

	private func saveSmartTargetCollection(completion: @escaping (SmartTargetsResult) -> Void) {
		dataBaseWorker.saveSmartTargets(smartTargetCollection) { result in
			let result = result.map { $0 as ISmartTargetCollection }
			completion(result)
		}
	}

	func updateSmartTargets(_ request: SmartTargetList.UpdateSmartTargets.Request) {
		guard didUpdateAllSmartTargets == false else { return }
		let oldCollection = oldSmartTargetCollection.copy()

		let difference = smartTargetCollection.smartTargetsOfDifference(from: oldCollection)
		let response = SmartTargetList.UpdateSmartTargets.Response(collection: oldCollection,
																   difference: difference)

		oldSmartTargetCollection.replaceSmartTargets(with: smartTargetCollection.smartTargets)
		presenter.presentUpdateSmartTargets(response)
		didUpdateAllSmartTargets = true
	}

	func updateSmartTarget(_ request: SmartTargetList.UpdateSmartTarget.Request) {
		guard editedSmartTarget != nil,
			let editedSmartTarget = self.editedSmartTarget,
			let oldSmartTarget = self.smartTargetCollection[editedSmartTarget.uid] else { return }
		let smartTargetIndex = smartTargetCollection.put(editedSmartTarget)
		self.editedSmartTarget = nil
		self.saveSmartTargetCollection { [weak self] _ in
			let response = SmartTargetList.UpdateSmartTarget.Response(editedSmartTarget: editedSmartTarget,
																	  oldSmartTarget: oldSmartTarget,
																	  editedSmartTargetIndex: smartTargetIndex)
			self?.presenter.presentUpdateSmartTarget(response)
		}
	}

	func showEmptyView(_ request: SmartTargetList.ShowEmptyView.Request) {
		let response = SmartTargetList.ShowEmptyView.Response(showEmptyView: (self.smartTargetCollection.count == 0))
		presenter.presentEmptyView(response)
	}
}

// MARK: - Smart target list data store
extension SmartTargetListInteractor: SmartTargetListDataStore
{
	var collection: ISmartTargetCollection {
		smartTargetCollection.copy() as ISmartTargetCollection
	}
}
